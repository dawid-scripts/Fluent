local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Config)
    local Library = self.Library
    
    assert(Config.Title, 'Toggle - Missing Title')

    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle"
    }

    local ToggleFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)
    ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

    local ToggleCircle = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        BackgroundTransparency = 0.4,
        ThemeTag = {
            BackgroundColor3 = "ToggleStroke"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 7)
        })
    })

    local ToggleStroke = New("UIStroke", {
        Transparency = 0.4,
        ThemeTag = {
            Color = "ToggleStroke"
        }
    })

    local ToggleSlider = New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = ToggleFrame.Frame,
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "Accent"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 9)
        }),
        ToggleStroke, 
        ToggleCircle
    })

    print(ToggleSlider)

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end

    function Toggle:SetValue(Value)
        Value = (not not Value);
        Toggle.Value = Value;

        Creator.OverrideTag(ToggleStroke, { Color = Toggle.Value and "Accent" or "ToggleStroke" })
        Creator.OverrideTag(ToggleCircle, { BackgroundColor3 = Toggle.Value and "ToggleToggled" or "ToggleStroke" })
        TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{ Position = UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0) }):Play()
        TweenService:Create(ToggleSlider, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{ BackgroundTransparency = Toggle.Value and 0 or 1 }):Play()
        ToggleCircle.BackgroundTransparency = Toggle.Value and 0 or 0.4

        Library:SafeCallback(Toggle.Callback, Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end


    Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle:SetValue(Toggle.Value)
    return Toggle
end

return Element