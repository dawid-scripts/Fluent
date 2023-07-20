local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Root = script

local Creator = require(Root.Creator)
local Elements = require(Root.Elements)
local Acrylic = require(Root.Acrylic)
local Components = Root.Components

local New = Creator.New

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);
local GUI = New("ScreenGui", {
    Parent = if RunService:IsStudio() then LocalPlayer.PlayerGui else game:GetService("CoreGui")
})
ProtectGui(GUI);

local Library = {
    Theme = "Dark",
    Acrylic = true,
    OpenFrames = {},
    GUI = GUI
}

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);

    if not success then
        local _, i = event:find(":%d+: ");

        if not i then
            return print(event);
        end;

        return print(event:sub(i + 1));
    end;
end;

function Library:Round(Number, Factor)
    if Factor == 0 then
        return math.floor(Number)
    end
    Number = tostring(Number)
    return Number:find('%.') and tonumber(Number:sub(1, Number:find('%.') + Factor)) or Number
end

local Addons = {}
Addons.__index = Addons;
Addons.__namecall = function(Table, Key, ...)
    return Addons[Key](...)
end

for _, ElementComponent in ipairs(Elements) do
    Addons["Add" .. ElementComponent.__type] = function(self, Config)
        ElementComponent.Container = self.Container
        ElementComponent.Type = self.Type
        ElementComponent.Library = Library
        
        return ElementComponent:New(Config)
    end
end

function Library:CreateWindow(Config)
    local Window = {
        Tabs = {},
        Containers = {},
        SelectedTab = 0,
        CurrentPos = 17,
        TabCount = 0
    }

    Window.Frame = require(Components.Window)({
        Parent = GUI,
        Size = Config.Size,
        Title = Config.Title,
        SubTitle = Config.SubTitle,
        TabWidth = Config.TabWidth,
    })
    Library.WindowFrame = Window.Frame

    local TabModule = require(Components.Tab)
    TabModule.Window = Window

    function Window:Tab(TabConfig)
        local Tab = {Type = "Tab"}

        local TabFrame = TabModule:New(TabConfig.Title, TabConfig.Icon, Window.Frame.TabHolder)
        Tab.Container = TabFrame.Container

        setmetatable(Tab, Addons);
        return Tab
    end

    return Window
end

function Library:SetTheme(Value)
    if Library.WindowFrame then
        Library.Theme = Value
        Creator.UpdateTheme()
    end
end

function Library:Destroy()
    if Library.WindowFrame then
        Library.WindowFrame.AcrylicPaint.Model:Destroy()
        Creator.Disconnect()
        GUI:Destroy()
    end
end

function Library:ToggleAcrylic(Value)
    if Library.WindowFrame then
        Library.Acrylic = Value
        Library.WindowFrame.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.4 or 0
        Library.WindowFrame.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
        if Value then Acrylic.Enable() else Acrylic.Disable() end
    end
end

return Library