local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local New = Creator.New

local Spring = Flipper.Spring.new

return function(Theme, Parent)
    local Button = {}

    Button.Title = New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ThemeTag = {
            TextColor3 = "ElementTitle"
        }
    })

    Button.HoverFrame = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "ElementBackground"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    Button.Frame = New("TextButton", {
        Size = UDim2.new(0, 0, 0, 32),
        Parent = Parent,
        ThemeTag = {
            BackgroundColor3 = "DialogBackground"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Transparency = 0.65,
            ThemeTag = {
                Color = "DialogStroke"
            }
        }),
        Button.HoverFrame,
        Button.Title
    })

    local Motor, SetTransparency = Creator.SpringMotor(1, Button.HoverFrame, "BackgroundTransparency")
    Creator.AddSignal(Button.Frame.MouseEnter, function() SetTransparency(0.97) end)
    Creator.AddSignal(Button.Frame.MouseLeave, function() SetTransparency(1) end)
    Creator.AddSignal(Button.Frame.MouseButton1Down, function() SetTransparency(1) end)
    Creator.AddSignal(Button.Frame.MouseButton1Up, function()  SetTransparency(0.97) end)

    return Button
end