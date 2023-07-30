local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local New = Creator.New

local Spring = Flipper.Spring.new

return function(Parent)
    local Textbox = {}

    Textbox.Input = New("TextBox", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromOffset(10, 0),
        ThemeTag = {
            TextColor3 = "Text"
        }
    })

    Textbox.Indicator = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        ThemeTag = {
            BackgroundColor3 = "SubText"
        }
    })

    Textbox.Frame = New("CanvasGroup", {
        Size = UDim2.new(0, 0, 0, 32),
        Parent = Parent,
        ThemeTag = {
            BackgroundColor3 = "Foreground"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Transparency = 0.65,
            ThemeTag = {
                Color = "Border"
            }
        }),
        Textbox.Indicator,
        Textbox.Input
    })

    return Textbox
end