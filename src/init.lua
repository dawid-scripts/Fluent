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
ProtectGui(GUI)

local Library = {
    Version = "1.0.0",
    Theme = "Dark",
    OpenFrames = {},
    Acrylic = true,
    DialogOpen = false,
    GUI = GUI
}

function Library:SafeCallback(Function, ...)
    if (not Function) then
        return
    end

    local Success, Event = pcall(Function, ...);
    if not Success then
        local _, i = Event:find(":%d+: ");

        if not i then
            return print(Event)
        end

        return print(Event:sub(i + 1))
    end
end

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
    if Library.WindowFrame then
        print("You cannot create more than one window.")
        return
    end

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
    Window.SelectTab = TabModule.SelectTab

    local DialogModule = require(Components.Dialog)
    DialogModule.Window = Window.Frame

    function Window:Tab(TabConfig)
        local Tab = {Type = "Tab"}

        local TabFrame = TabModule:New(TabConfig.Title, TabConfig.Icon, Window.Frame.TabHolder)
        Tab.Container = TabFrame.Container

        setmetatable(Tab, Addons)
        return Tab
    end

    function Window:Dialog(Config)
        local Dialog = require(Components.Dialog):Create()
        Dialog.Title.Text = Config.Title

        local Content = New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = Config.Content,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.fromOffset(20, 60),
            BackgroundTransparency = 1,
            Parent = Dialog.Root,
            ClipsDescendants = false,
            ThemeTag = {
                TextColor3 = "Text"
            }
        })

        New("UISizeConstraint", {
            MinSize = Vector2.new(300, 165),
            MaxSize = Vector2.new(620, math.huge),
            Parent = Dialog.Root
        })

        Dialog.Root.Size = UDim2.fromOffset(Content.TextBounds.X + 40, 165)
        if Content.TextBounds.X + 40 > Window.Frame.Size.X.Offset - 120 then
            Dialog.Root.Size = UDim2.fromOffset(Window.Frame.Size.X.Offset - 120, 165)
            Content.TextWrapped = true
            Dialog.Root.Size = UDim2.fromOffset(Window.Frame.Size.X.Offset - 120, Content.TextBounds.Y + 150)
        end

        for _, Button in next, Config.Buttons do
            Dialog:Button(Button.Title, Button.Callback)
        end

        Dialog:Open()
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
        --Library.WindowFrame.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.4 or 0
        Library.WindowFrame.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
        if Value then Acrylic.Enable() else Acrylic.Disable() end
    end
end

return Library