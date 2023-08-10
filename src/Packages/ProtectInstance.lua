local ProtectedInstances = {};
local Connections = getconnections or get_connections;
local HookFunction = HookFunction or hookfunction or hook_function or detour_function;
local GetNCMethod = getnamecallmethod or get_namecall_method;
local CheckCaller = checkcaller or check_caller;
local GetRawMT = get_raw_metatable or getrawmetatable or getraw_metatable;

if not HookFunction and not GetNCMethod and not CheckCaller and not Connections then
    print("ProtectInstance not supported.")
    return nil
end

local function HookMetaMethod(Object, MetaMethod, Function)
    return HookFunction(assert(GetRawMT(Object)[MetaMethod], "Invalid Method"), Function);
end 

local TblDataCache = {};
local FindDataCache = {};
local PropertyChangedData = {};
local InstanceConnections = {};
local NameCall, NewIndex;

local EventMethods = {
    "ChildAdded",
    "ChildRemoved",
    "DescendantRemoving",
    "DescendantAdded",
    "childAdded",
    "childRemoved",
    "descendantRemoving",
    "descendantAdded",
}
local TableInstanceMethods = {
    GetChildren = game.GetChildren,
    GetDescendants = game.GetDescendants,
    getChildren = game.getChildren,
    getDescendants = game.getDescendants,
    children = game.children,
}
local FindInstanceMethods = {
    FindFirstChild = game.FindFirstChild,
    FindFirstChildWhichIsA = game.FindFirstChildWhichIsA,
    FindFirstChildOfClass = game.FindFirstChildOfClass,
    findFirstChild = game.findFirstChild,
    findFirstChildWhichIsA = game.findFirstChildWhichIsA,
    findFirstChildOfClass = game.findFirstChildOfClass,
}
local NameCallMethods = {
    Remove = game.Remove;
    Destroy = game.Destroy;
    remove = game.remove;
    destroy = game.destroy;
}

for MethodName, MethodFunction in next, TableInstanceMethods do
    TblDataCache[MethodName] = HookFunction(MethodFunction, function(...)
        if not CheckCaller() then
            local ReturnedTable = TblDataCache[MethodName](...);
            
            if ReturnedTable then
                table.foreach(ReturnedTable, function(_, Inst)
                    if table.find(ProtectedInstances, Inst) then
                        table.remove(ReturnedTable, _);
                    end
                end)

                return ReturnedTable;
            end
        end

        return TblDataCache[MethodName](...);
    end)
end

for MethodName, MethodFunction in next, FindInstanceMethods do
    FindDataCache[MethodName] = HookFunction(MethodFunction, function(...)
        if not CheckCaller() then
            local FindResult = FindDataCache[MethodName](...);

            if table.find(ProtectedInstances, FindResult) then
                FindResult = nil
            end
            for _, Object in next, ProtectedInstances do
                if Object == FindResult then
                    FindResult = nil
                end
            end
        end
        return FindDataCache[MethodName](...);
    end)
end

local function GetParents(Object)
    local Parents = { Object.Parent };

    local CurrentParent = Object.Parent;

    while CurrentParent ~= game and CurrentParent ~= nil do
        CurrentParent = CurrentParent.Parent;
        table.insert(Parents, CurrentParent)
    end

    return Parents;
end

NameCall = HookMetaMethod(game, "__namecall", function(...)
    if not CheckCaller() then
        local ReturnedData = NameCall(...);
        local NCMethod = GetNCMethod();
        local self, Args = ...;

        if typeof(self) ~= "Instance" then return ReturnedData end
        if not ReturnedData then return nil; end;

        if TableInstanceMethods[NCMethod] then
            if typeof(ReturnedData) ~= "table" then return ReturnedData end;

            table.foreach(ReturnedData, function(_, Inst)
                if table.find(ProtectedInstances, Inst) then
                    table.remove(ReturnedData, _);
                end
            end)

            return ReturnedData;
        end
        
        if FindInstanceMethods[NCMethod] then
            if typeof(ReturnedData) ~= "Instance" then return ReturnedData end;
            
            if table.find(ProtectedInstances, ReturnedData) then
                return nil;
            end
        end
    elseif CheckCaller() then
        local self, Args = ...;
        local Method = GetNCMethod();

        if NameCallMethods[Method] then
            if typeof(self) ~= "Instance" then return NewIndex(...) end

            if table.find(ProtectedInstances, self) and not PropertyChangedData[self] then
                local Parent = self.Parent;
                InstanceConnections[self] = {}

                if tostring(Parent) ~= "nil" then
                    for _, ConnectionType in next, EventMethods do
                        for _, Connection in next, Connections(Parent[ConnectionType]) do
                            table.insert(InstanceConnections[self], Connection);
                            Connection:Disable();
                        end
                    end
                end
                for _, Connection in next, Connections(game.ItemChanged) do
                    table.insert(InstanceConnections[self], Connection);
                    Connection:Disable();
                end
                for _, Connection in next, Connections(game.itemChanged) do
                    table.insert(InstanceConnections[self], Connection);
                    Connection:Disable();
                end
                for _, ParentObject in next, GetParents(self) do
                    if tostring(ParentObject) ~= "nil" then
                        for _, ConnectionType in next, EventMethods do
                            for _, Connection in next, Connections(ParentObject[ConnectionType]) do
                                table.insert(InstanceConnections[self], Connection);
                                Connection:Disable();
                            end
                        end
                    end
                end

                PropertyChangedData[self] = true;
                self[Method](self);
                PropertyChangedData[self] = false;

                table.foreach(InstanceConnections[self], function(_,Connect) 
                    Connect:Enable();
                end)
            end
        end
    end
    return NameCall(...);
end)
NewIndex = HookMetaMethod(game , "__newindex", function(...)
    if CheckCaller() then
        local self, Property, Value, UselessArgs = ...
        
        if typeof(self) ~= "Instance" then return NewIndex(...) end

        if table.find(ProtectedInstances, self) and not PropertyChangedData[self] then
            if rawequal(Property, "Parent") then
                local NewParent = Value;
                local OldParent = self.Parent;
                InstanceConnections[self] = {}

                for _, ConnectionType in next, EventMethods do
                    if NewParent and NewParent.Parent ~= nil then
                        for _, Connection in next, Connections(NewParent[ConnectionType]) do
                            table.insert(InstanceConnections[self], Connection);
                            Connection:Disable();
                        end
                    end
                    if OldParent and OldParent ~= nil then
                        for _, Connection in next, Connections(OldParent[ConnectionType]) do
                            table.insert(InstanceConnections[self], Connection);
                            Connection:Disable();
                        end
                    end
                end

                for _, ParentObject in next, GetParents(self) do
                    if ParentObject and ParentObject.Parent ~= nil then
                        for _, ConnectionType in next, EventMethods do
                            for _, Connection in next, Connections(ParentObject[ConnectionType]) do
                                table.insert(InstanceConnections[self], Connection);
                                Connection:Disable();
                            end
                        end
                    end
                end

                for _, ParentObject in next, GetParents(NewParent) do
                    if ParentObject and ParentObject.Parent ~= nil then
                        for _, ConnectionType in next, EventMethods do
                            for _, Connection in next, Connections(ParentObject[ConnectionType]) do
                                table.insert(InstanceConnections[self], Connection);
                                Connection:Disable();
                            end
                        end
                    end
                end

                for _, Connection in next, Connections(game.ItemChanged) do
                    table.insert(InstanceConnections[self], Connection);
                    Connection:Disable();
                end
                for _, Connection in next, Connections(game.itemChanged) do
                    table.insert(InstanceConnections[self], Connection);
                    Connection:Disable();
                end

                PropertyChangedData[self] = true;
                self.Parent = NewParent;
                PropertyChangedData[self] = false;

               
                table.foreach(InstanceConnections[self], function(_,Connect) 
                    Connect:Enable();
                end)

            end
        end
    end
    return NewIndex(...)
end)

return {
    ProtectInstance = function(NewInstance)
        table.insert(ProtectedInstances, NewInstance)
    end,
    UnProtectInstance = function(NewInstance)
        table.remove(ProtectedInstances, table.find(ProtectedInstances, NewInstance));
    end
}