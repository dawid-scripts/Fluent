local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local New = Creator.New

local Spring = Flipper.Spring.new

return function(Title, Desc, Parent, Hover)
    local Element = {}

    Element.TitleLabel = New("TextLabel", {
        FontFace = Font.new(
            "rbxasset://fonts/families/GothamSSm.json",
            Enum.FontWeight.Medium,
            Enum.FontStyle.Normal
        ),
        Text = Title,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "ElementTitle"
        }
    })

    Element.DescLabel = New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = Desc,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        ThemeTag = {
            TextColor3 = "ElementDesc"
        }
    })

    Element.LabelHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 0, 0),
    }, {
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
        }),
        Element.TitleLabel,
        Element.DescLabel,
    })

    Element.Frame = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 0.89,
        BackgroundColor3 = Color3.fromRGB(130, 130, 130),
        Parent = Parent,
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = "",
        ThemeTag = {
            BackgroundColor3 = "ElementBackground"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        New("UIStroke", {
            Transparency = 0.85,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(0, 0, 0),
            ThemeTag = {
                Color = "ElementStroke"
            }
        }),
        Element.LabelHolder
    })

    function Element:SetTitle(Set)
        Element.TitleLabel.Text = Set
    end

    function Element:SetDesc(Set)
        if Set == nil then Set = "" end
        if Set == "" then
            Element.DescLabel.Visible = false
        else
            Element.DescLabel.Visible = true
        end
        Element.DescLabel.Text = Set
    end

    Element:SetTitle(Title)
    Element:SetDesc(Desc)

    local Motor, SetTransparency = Creator.SpringMotor(0.89, Element.Frame, "BackgroundTransparency")

    if Hover then
        Creator.AddSignal(Element.Frame.MouseEnter, function() SetTransparency(0.83) end)
        Creator.AddSignal(Element.Frame.MouseLeave, function() SetTransparency(0.87) end)
        Creator.AddSignal(Element.Frame.MouseButton1Down, function() SetTransparency(0.90) end)
        Creator.AddSignal(Element.Frame.MouseButton1Up, function()  SetTransparency(0.83) end)
    end

    return Element
end