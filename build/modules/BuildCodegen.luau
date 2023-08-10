-- MIT License | Copyright (c) 2023 Latte Softworks <latte.to> & Kotera <kotera.7kayoh.net>

local roblox = require("@lune/roblox")

local LuaEncode = require("LuaEncode")

-- Init script template for codegen (in this, we'll maintain 5.1 *syntax* compat)
local InitScriptTemplate = [[
-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds the actual DOM data
local ObjectTree = ${ObjectTree}

-- Holds direct closure data
local ClosureBindings = ${ClosureBindings} -- [RefId] = Closure

-- Set up from data
do
    -- Localizing certain libraries and built-ins for runtime efficiency
    local task, setmetatable, error, newproxy, getmetatable, next, table, unpack, coroutine, script, type, require, pcall, getfenv, setfenv, rawget= task, setmetatable, error, newproxy, getmetatable, next, table, unpack, coroutine, script, type, require, pcall, getfenv, setfenv, rawget

    local table_insert = table.insert
    local table_remove = table.remove

    -- lol
    local table_freeze = table.freeze or function(t) return t end

    -- If we're not running on Roblox or Lune runtime, we won't have a task library
    local Defer = task and task.defer or function(f, ...)
        local Thread = coroutine.create(f)
        coroutine.resume(Thread, ...)
        return Thread
    end

    -- `maui.Version` compat
    local Version = "0.0.0-venv"

    local RefBindings = {} -- [RefId] = RealObject

    local ScriptClosures = {}
    local StoredModuleValues = {}
    local ScriptsToRun = {}

    -- maui.Shared
    local SharedEnvironment = {}

    -- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
    -- It's meant to be as lazy as possible lol
    local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

    -- Implemented instance methods
    local InstanceMethods = {
        GetChildren = function(self)
            local Children = RefChildren[self]
            local ReturnArray = {}
    
            for Child in next, Children do
                table_insert(ReturnArray, Child)
            end
    
            return ReturnArray
        end,

        -- Not implementing `recursive` arg, as it isn't needed for us here
        FindFirstChild = function(self, name)
            if not name then
                error("Argument 1 missing or nil", 2)
            end

            for Child in next, RefChildren[self] do
                if Child.Name == name then
                    return Child
                end
            end

            return
        end,

        GetFullName = function(self)
            local Path = self.Name
            local ObjectPointer = self.Parent

            while ObjectPointer do
                Path = ObjectPointer.Name .. "." .. Path

                -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
                ObjectPointer = ObjectPointer.Parent
            end

            return "${EnvName}." .. Path
        end,
    }

    -- "Proxies" to instance methods, with err checks etc
    local InstanceMethodProxies = {}
    for MethodName, Method in next, InstanceMethods do
        InstanceMethodProxies[MethodName] = function(self, ...)
            if not RefChildren[self] then
                error("Expected ':' not '.' calling member function " .. MethodName, 1)
            end

            return Method(self, ...)
        end
    end

    local function CreateRef(className, name, parent)
        -- `name` and `parent` can also be set later by the init script if they're absent

        -- Extras
        local StringValue_Value

        -- Will be set to RefChildren later aswell
        local Children = setmetatable({}, {__mode = "k"})

        -- Err funcs
        local function InvalidMember(member)
            error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 1)
        end

        local function ReadOnlyProperty(property)
            error("Unable to assign (virtual) property " .. property .. ". Property is read only", 1)
        end

        local Ref = newproxy(true)
        local RefMetatable = getmetatable(Ref)

        RefMetatable.__index = function(_, index)
            if index == "ClassName" then -- First check "properties"
                return className
            elseif index == "Name" then
                return name
            elseif index == "Parent" then
                return parent
            elseif className == "StringValue" and index == "Value" then
                -- Supporting StringValue.Value for Rojo .txt file conv
                return StringValue_Value
            else -- Lastly, check "methods"
                local InstanceMethod = InstanceMethodProxies[index]

                if InstanceMethod then
                    return InstanceMethod
                end
            end

            -- Next we'll look thru child refs
            for Child in next, Children do
                if Child.Name == index then
                    return Child
                end
            end

            -- At this point, no member was found; this is the same err format as Roblox
            InvalidMember(index)
        end

        RefMetatable.__newindex = function(_, index, value)
            -- __newindex is only for props fyi
            if index == "ClassName" then
                ReadOnlyProperty(index)
            elseif index == "Name" then
                name = value
            elseif index == "Parent" then
                -- We'll just ignore the process if it's trying to set itself
                if value == Ref then
                    return
                end

                if parent ~= nil then
                    -- Remove this ref from the CURRENT parent
                    RefChildren[parent][Ref] = nil
                end

                parent = value

                if value ~= nil then
                    -- And NOW we're setting the new parent
                    RefChildren[value][Ref] = true
                end
            elseif className == "StringValue" and index == "Value" then
                -- Supporting StringValue.Value for Rojo .txt file conv
                StringValue_Value = value
            else
                -- Same err as __index when no member is found
                InvalidMember(index)
            end
        end

        RefMetatable.__tostring = function()
            return name
        end

        RefChildren[Ref] = Children

        if parent ~= nil then
            RefChildren[parent][Ref] = true
        end

        return Ref
    end

    -- Create real ref DOM from object tree
    local function CreateRefFromObject(object, parent)
        local RefId = object[1]
        local ClassName = object[2]
        local Properties = object[3]
        local Children = object[4] -- Optional

        local Name = table_remove(Properties, 1)

        local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
        RefBindings[RefId] = Ref

        if Properties then
            for PropertyName, PropertyValue in next, Properties do
                Ref[PropertyName] = PropertyValue
            end
        end

        if Children then
            for _, ChildObject in next, Children do
                CreateRefFromObject(ChildObject, Ref)
            end
        end

        return Ref
    end

    local RealObjectRoot = {}
    for _, Object in next, ObjectTree do
        table_insert(RealObjectRoot, CreateRefFromObject(Object))
    end

    -- Now we'll set script closure refs and check if they should be ran as a BaseScript
    for RefId, Closure in next, ClosureBindings do
        local Ref = RefBindings[RefId]

        ScriptClosures[Ref] = Closure

        local ClassName = Ref.ClassName
        if ClassName == "LocalScript" or ClassName == "Script" then
            table_insert(ScriptsToRun, Ref)
        end
    end

    local function LoadScript(scriptRef)
        local ScriptClassName = scriptRef.ClassName

        -- First we'll check for a cached module value (packed into a tbl)
        local StoredModuleValue = StoredModuleValues[scriptRef]
        if StoredModuleValue and ScriptClassName == "ModuleScript" then
            return unpack(StoredModuleValue)
        end

        local Closure = ScriptClosures[scriptRef]
        if not Closure then
            return
        end

        -- If it's a BaseScript, we'll just run it directly!
        if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
            Closure()
            return
        else
            local ClosureReturn = {Closure()}
            StoredModuleValues[scriptRef] = ClosureReturn
            return unpack(ClosureReturn)
        end
    end

    -- We'll assign the actual func from the top of this output for flattening user globals at runtime
    -- Returns (in a tuple order): maui, script, require, getfenv, setfenv
    function ImportGlobals(refId)
        local ScriptRef = RefBindings[refId]

        local Closure = ScriptClosures[ScriptRef]
        if not Closure then
            return
        end

        -- This will be set right after the other global funcs, it's for handling proper behavior when
        -- getfenv/setfenv is called and safeenv needs to be disabled
        local EnvHasBeenSet = false
        local RealEnv
        local VirtualEnv
        local SetEnv

        local Global_maui = table_freeze({
            Version = Version,
            Script = script, -- The actual script object for the script this is running on, not a fake ref
            Shared = SharedEnvironment,

            -- For compatibility purposes..
            GetScript = function()
                return script
            end,
            GetShared = function()
                return SharedEnvironment
            end,
        })

        local Global_script = ScriptRef

        local function Global_require(module, ...)
            if RefChildren[module] and module.ClassName == "ModuleScript" and ScriptClosures[module] then
                return LoadScript(module)
            end

            return require(module, ...)
        end

        -- Calling these flattened getfenv/setfenv functions will disable safeenv for the WHOLE SCRIPT
        local function Global_getfenv(stackLevel, ...)
            -- Now we have to set the env for the other variables used here to be valid
            if not EnvHasBeenSet then
                SetEnv()
            end

            if type(stackLevel) == "number" and stackLevel >= 0 then
                if stackLevel == 0 then
                    return VirtualEnv
                else
                    -- Offset by 1 for the actual env
                    stackLevel = stackLevel + 1

                    local GetOk, FunctionEnv = pcall(getfenv, stackLevel)
                    if GetOk and FunctionEnv == RealEnv then
                        return VirtualEnv
                    end
                end
            end

            return getfenv(stackLevel, ...)
        end

        local function Global_setfenv(stackLevel, newEnv, ...)
            if not EnvHasBeenSet then
                SetEnv()
            end

            if type(stackLevel) == "number" and stackLevel >= 0 then
                if stackLevel == 0 then
                    return setfenv(VirtualEnv, newEnv)
                else
                    stackLevel = stackLevel + 1

                    local GetOk, FunctionEnv = pcall(getfenv, stackLevel)
                    if GetOk and FunctionEnv == RealEnv then
                        return setfenv(VirtualEnv, newEnv)
                    end
                end
            end

            return setfenv(stackLevel, newEnv, ...)
        end

        -- From earlier, will ONLY be set if needed
        function SetEnv()
            RealEnv = getfenv(0)

            local GlobalEnvOverride = {
                ["maui"] = Global_maui,
                ["script"] = Global_script,
                ["require"] = Global_require,
                ["getfenv"] = Global_getfenv,
                ["setfenv"] = Global_setfenv,
            }

            VirtualEnv = setmetatable({}, {
                __index = function(_, index)
                    local IndexInVirtualEnv = rawget(VirtualEnv, index)
                    if IndexInVirtualEnv ~= nil then
                        return IndexInVirtualEnv
                    end

                    local IndexInGlobalEnvOverride = GlobalEnvOverride[index]
                    if IndexInGlobalEnvOverride ~= nil then
                        return IndexInGlobalEnvOverride
                    end

                    return RealEnv[index]
                end
            })

            setfenv(Closure, VirtualEnv)
            EnvHasBeenSet = true
        end

        -- Now, return flattened globals ready for direct runtime exec
        return Global_maui, Global_script, Global_require, Global_getfenv, Global_setfenv
    end

    for _, ScriptRef in next, ScriptsToRun do
        Defer(LoadScript, ScriptRef)
    end

    -- If there's a "MainModule" top-level modulescript, we'll return it from the output's closure directly
    do
        local MainModule
        for _, Ref in next, RealObjectRoot do
            if Ref.ClassName == "ModuleScript" and Ref.Name == "MainModule" then
                MainModule = Ref
                break
            end
        end

        if MainModule then
            return LoadScript(MainModule)
        end
    end

    -- If any scripts are currently running now from task scheduler, the scope won't close until all running threads are closed
    -- (thanks for coming to my ted talk)
end

]]

-- VERY simple function to interpolate a certain string with a set of replacements, following
-- Luau's basic variable syntax rules (used for codegen)
local function ReplaceString(inputString: string, replacements: {[string]: string}): string
    return string.gsub(inputString, "${([A-Za-z_][A-Za-z0-9_]*)}", replacements)
end

-- Building codegen directly from a model file path (.rbxm/.rbxmx) using Lune's Roblox library
local function BuildCodegen(modelData: string, minifyTables: boolean?, envName: string?): string
    minifyTables = if minifyTables == nil then true else minifyTables
    envName = envName or "VirtualEnv"

    local ModelRoot = roblox.deserializeModel(modelData)

    -- We'll track how long it takes for us to scrape the object tree
    local ScrapingStartTime = os.clock()
    
    -- We'll initialize the output object tree, then walk through what we need to
    local ObjectTree = {}
    local ClosureBindings = {} -- [RefId] = Closure

    local ScrapedInstanceTree = {} -- [RealRef] = {Child, ...}
    local RefIds = {} -- [RefId] =  RealRef

    -- Recursive function to actually walk through the real instance tree, and assign refs
    local function ScrapeInstanceChildren(instance)
        -- Add a reference id for this instance
        table.insert(RefIds, instance)

        local ScrapedChildren = {}
        for _, Child in instance:GetChildren() do
            ScrapedChildren[Child] = ScrapeInstanceChildren(Child)
        end

        return ScrapedChildren
    end

    -- Initialize the scraped instance tree and assign all refs from root
    for _, RealInstance in ModelRoot do
        ScrapedInstanceTree[RealInstance] = ScrapeInstanceChildren(RealInstance)
    end

    -- Now, we'll recursively create the fake object tree
    local function CreateObjectTree(instance, children)
        local RefId = table.find(RefIds, instance)
        local ClassName = instance.ClassName

        local InstanceIsABaseScript = ClassName == "LocalScript" or ClassName == "Script"
        local InstanceIsAScript = InstanceIsABaseScript or ClassName == "ModuleScript"

        --[[
            {
                [1] = RefId,
                [2] = ClassName,
                [3] = Properties,
                [4] = Children?
            }
        ]]

        local ObjectTree = {
            [1] = RefId,
            [2] = ClassName
        }

        -- If it's statically disabled, we just won't include the closure to run
        if InstanceIsAScript and not (InstanceIsABaseScript and instance.Disabled) then
            local ScriptSource = instance.Source

            local EndStatement = " end" do
                local SplitSource = string.split(ScriptSource, "\n")
                local LastLine = SplitSource[#SplitSource]

                -- If the last line has a comment NOT followed by at least a "[" character, it means
                -- that it's a full-line comment, and we need to call `end` on the next line
                if LastLine and string.match(LastLine, "%-%-[^%[]") then
                    EndStatement = "\nend"
                end
            end

            -- We can't compile check *yet* due to loadstring() being omitted, but soon we'll have a `luau` library

            -- We're using `FunctionsReturnRaw` on LuaEncode later, this will set the return
            -- to the rew value, which is the script closure
            ClosureBindings[RefId] = function()
                return "function()local maui,script,require,getfenv,setfenv=ImportGlobals(" .. RefId .. ")" .. ScriptSource .. EndStatement
            end
        end

        -- Add any properties
        local Properties = {[1] = instance.Name} -- For byte preservation (lol) the name is just set as the property index 1, and not "Name"

        if ClassName == "StringValue" then
            Properties.Value = instance.Value
        end

        ObjectTree[3] = Properties

        -- Recursively add children
        if next(children) then
            local ObjectChildren = {}

            for Child, ChildrenOfChild in children do
                table.insert(ObjectChildren, CreateObjectTree(Child, ChildrenOfChild))
            end

            ObjectTree[4] = ObjectChildren
        end

        return ObjectTree
    end

    for RealInstance, Children in ScrapedInstanceTree do
        table.insert(ObjectTree, CreateObjectTree(RealInstance, Children))
    end

    -- And we're done scraping everything!
    local ScrapingEndTime = os.clock()
    print(`Finished scraping object tree! Total build time: {string.format("%.4f", ScrapingEndTime - ScrapingStartTime)} (seconds)`)

    local Prettify = if minifyTables == false then true else false

    local SerializedObjectTree = LuaEncode(ObjectTree, {
        Prettify =  Prettify,
        StackLimit = math.huge,
    })

    local SerializedClosureBindings = LuaEncode(ClosureBindings, {
        Prettify =  Prettify,
        StackLimit = math.huge,
        FunctionsReturnRaw = true, -- For Script.Source function closures
    })

    local CodegenOutput = ReplaceString(InitScriptTemplate, {
        ObjectTree = SerializedObjectTree,
        ClosureBindings = SerializedClosureBindings,
        EnvName = envName,
    })

    return CodegenOutput
end

return BuildCodegen
