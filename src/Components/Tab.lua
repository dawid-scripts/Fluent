local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local New = Creator.New
local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new


local TabModule = {
    Window = nil
}

function TabModule:New(Title, Icon, Parent)
    local Window = TabModule.Window
    
    Window.TabCount = Window.TabCount + 1
    local TabIndex = Window.TabCount

    local Tab = {
        Selected = false,
        Name = Title
    }

    if Icon == "" or nil then
        Icon = nil
    end

    Tab.Frame = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = Parent,
        ThemeTag = {
            BackgroundColor3 = "Tab"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = if Icon then UDim2.new(0, 30, 0.5, 0) else UDim2.new(0, 12, 0.5, 0),
            Text = Title,
            RichText = true,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextTransparency = 0,
            FontFace = Font.new(
                "rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.Regular,
                Enum.FontStyle.Normal
            ),
            TextSize = 12,
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            Size = UDim2.new(1, -12, 1, 0),
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text"
            }
        }),
        New("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(0, 8, 0.5, 0),
            BackgroundTransparency = 1,
            Image = if Icon then Icon else nil,
            ThemeTag = {
                ImageColor3 = "Text"
            }
        })
    })

    local ContainerLayout = New("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Tab.Container = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = Window.Frame.ContainerHolder,
        Visible = false,
        BottomImage = "rbxassetid://6889812791",
        MidImage = "rbxassetid://6889812721",
        TopImage = "rbxassetid://6276641225",
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollBarImageTransparency = 0.95,
        ScrollBarThickness = 3,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0)
    }, {
        ContainerLayout,
        New("UIPadding", {
            PaddingRight = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 1),
            PaddingTop = UDim.new(0, 1),
            PaddingBottom = UDim.new(0, 1)
        })
    })

    Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Tab.Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 2) 
    end)

    Tab.Motor, Tab.SetTransparency = Creator.SpringMotor(1, Tab.Frame, "BackgroundTransparency")

    Creator.AddSignal(Tab.Frame.MouseEnter, function() Tab.SetTransparency(if Tab.Selected then 0.85 else 0.89) end)
    Creator.AddSignal(Tab.Frame.MouseLeave, function() Tab.SetTransparency(if Tab.Selected then 0.89 else 1) end)
    Creator.AddSignal(Tab.Frame.MouseButton1Down, function() Tab.SetTransparency(0.92) end)
    Creator.AddSignal(Tab.Frame.MouseButton1Up, function() Tab.SetTransparency(if Tab.Selected then 0.85 else 0.89) end)
    Creator.AddSignal(Tab.Frame.MouseButton1Click, function() TabModule:SelectTab(TabIndex) end)

    Window.Containers[TabIndex] = Tab.Container
    Window.Tabs[TabIndex] = Tab

    return Tab
end

function TabModule:SelectTab(Tab)
    local Window = TabModule.Window

    Window.SelectedTab = Tab
    Window.CurrentPos = Tab * 17 + ((Tab - 1) * 21)

    for _, TabObject in next, Window.Tabs do 
        TabObject.SetTransparency(1)
        TabObject.Selected = false
    end
    Window.Tabs[Tab].SetTransparency(0.89)
    Window.Tabs[Tab].Selected = true

    Window.Frame.TabDisplay.Text = Window.Tabs[Tab].Name
    Window.Frame.SelectorPosMotor:setGoal(Spring(Window.CurrentPos, { frequency = 6 }))

    task.spawn(function()
        Window.Frame.ContainerPosMotor:setGoal(Spring(110, { frequency = 10 }))
        Window.Frame.ContainerBackMotor:setGoal(Spring(1, { frequency = 10 }))
        task.wait(0.15)
        for _, Container in next, Window.Containers do
            Container.Visible = false
        end
        Window.Containers[Tab].Visible = true
        Window.Frame.ContainerPosMotor:setGoal(Spring(94, { frequency = 5 }))
        Window.Frame.ContainerBackMotor:setGoal(Spring(0, { frequency = 8 }))
    end)
end


return TabModule