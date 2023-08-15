local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Root = script
local Creator = require(Root.Creator)
local ElementsTable = require(Root.Elements)
local Acrylic = require(Root.Acrylic)
local Components = Root.Components
local ProtectInstance = require(Root.Packages.ProtectInstance)
local NotificationModule = require(Components.Notification)

local New = Creator.New

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);
local GUI = New("ScreenGui", {
    Parent = if RunService:IsStudio() then LocalPlayer.PlayerGui else game:GetService("CoreGui")
})
ProtectGui(GUI)

local Library = {
    Version = "1.0.0",

    OpenFrames = {},
    Options = {},
    Themes = require(Root.Themes).Names,

    Window = nil,
    WindowFrame = nil,
    Unloaded = false,

    Theme = "Dark",
    DialogOpen = false,
    UseAcrylic = true,
    Acrylic = true,
    Transparency = true,

    GUI = GUI,
}

function Library:SafeCallback(Function, ...)
    if (not Function) then
        return
    end

    local Success, Event = pcall(Function, ...);
    if not Success then
        local _, i = Event:find(":%d+: ");

        if not i then
            return Library:Notify({
                Title = "Interface",
                Content = "Callback error",
                SubContent = Event,
                Duration = 5
            })
        end

        return Library:Notify({
            Title = "Interface",
            Content = "Callback error",
            SubContent = Event:sub(i + 1),
            Duration = 5
        })
    end
end

function Library:Round(Number, Factor)
    if Factor == 0 then
        return math.floor(Number)
    end
    Number = tostring(Number)
    return Number:find('%.') and tonumber(Number:sub(1, Number:find('%.') + Factor)) or Number
end

local Icons = require(Root.Icons).assets
function Library:GetIcon(Name)
    if Name ~= nil and Icons["lucide-" .. Name] then
        return Icons["lucide-" .. Name]
    end
    return nil
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
    return Elements[Key](...)
end

for _, ElementComponent in ipairs(ElementsTable) do
    Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
        ElementComponent.Container = self.Container
        ElementComponent.Type = self.Type
        ElementComponent.ScrollFrame = self.ScrollFrame
        ElementComponent.Library = Library
        
        return ElementComponent:New(Idx, Config)
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

    Library.UseAcrylic = Config.Acrylic
    if Library.UseAcrylic then
        Acrylic.init()
    end

    Window.Frame = require(Components.Window)({
        Parent = GUI,
        Size = Config.Size,
        Title = Config.Title,
        SubTitle = Config.SubTitle,
        TabWidth = Config.TabWidth,
    })
    Library.WindowFrame = Window.Frame
    Library.Window = Window

    Library:SetTheme(Config.Theme)

    local TabModule = require(Components.Tab)
    TabModule.Window = Window
    Window.SelectTab = TabModule.SelectTab

    local DialogModule = require(Components.Dialog)
    DialogModule.Window = Window.Frame

    NotificationModule:Init(Library.GUI)

    function Window:AddTab(TabConfig)
        local Tab = {Type = "Tab"}

        if Library:GetIcon(TabConfig.Icon) then
            TabConfig.Icon = Library:GetIcon(TabConfig.Icon)
        end

        local TabFrame = TabModule:New(TabConfig.Title, TabConfig.Icon, Window.Frame.TabHolder)
        Tab.Container = TabFrame.Container
        Tab.ScrollFrame = Tab.Container
        Tab.Type = "Tab"

        function Tab:AddSection(SectionTitle)
            local Section = {}

            local SectionFrame = require(Components.Section)(SectionTitle, TabFrame.Container)
            Section.Container = SectionFrame.Container
            Section.ScrollFrame = Tab.Container
            Section.Type = "Section"

            setmetatable(Section, Elements)
            return Section
        end

        setmetatable(Tab, Elements)
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
    if Library.WindowFrame and table.find(Library.Themes, Value) then
        Library.Theme = Value
        Creator.UpdateTheme()
    end
end

function Library:Destroy()
    if Library.WindowFrame then
        if ProtectInstance then
            ProtectInstance.UnProtectInstance(Library.WindowFrame.AcrylicPaint.Model)
        end
        Library.Unloaded = true
        Library.WindowFrame.AcrylicPaint.Model:Destroy()
        Creator.Disconnect()
        Library.GUI:Destroy()
    end
end

function Library:ToggleAcrylic(Value)
    if Library.WindowFrame then
        if Library.UseAcrylic then
            Library.Acrylic = Value
            Library.WindowFrame.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
            if Value then Acrylic.Enable() else Acrylic.Disable() end
        end
    end
end

function Library:ToggleTransparency(Value)
    if Library.WindowFrame then
        Library.WindowFrame.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
    end
end

function Library:Notify(Config)
    return NotificationModule:New(Config)
end

if getgenv then
    getgenv().Fluent = Library
end

return Library