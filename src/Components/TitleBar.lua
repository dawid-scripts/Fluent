local Root = script.Parent.Parent
local Assets = require(script.Parent.Assets)
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local AddSignal = Creator.AddSignal

return function(Config)
	local TitleBar = {}

	local Library = require(Root)

	local function BarButton(Icon, Pos, Parent, Callback)
		local Button = {
			Callback = Callback or function() end,
		}

		Button.Frame = New("TextButton", {
			Size = UDim2.new(0, 34, 1, -8),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Parent = Parent,
			Position = Pos,
			Text = "",
			ThemeTag = {
				BackgroundColor3 = "Text",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 7),
			}),
			New("ImageLabel", {
				Image = Icon,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Name = "Icon",
				ThemeTag = {
					ImageColor3 = "Text",
				},
			}),
		})

		local Motor, SetTransparency = Creator.SpringMotor(1, Button.Frame, "BackgroundTransparency")

		AddSignal(Button.Frame.MouseEnter, function()
			SetTransparency(0.94)
		end)
		AddSignal(Button.Frame.MouseLeave, function()
			SetTransparency(1, true)
		end)
		AddSignal(Button.Frame.MouseButton1Down, function()
			SetTransparency(0.96)
		end)
		AddSignal(Button.Frame.MouseButton1Up, function()
			SetTransparency(0.94)
		end)
		AddSignal(Button.Frame.MouseButton1Click, Button.Callback)

		Button.SetCallback = function(Func)
			Button.Callback = Func
		end

		return Button
	end

	TitleBar.Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Parent = Config.Parent,
	}, {
		New("Frame", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			New("TextLabel", {
				RichText = true,
				Text = Config.Title,
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				TextSize = 12,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			New("TextLabel", {
				RichText = true,
				Text = Config.SubTitle,
				TextTransparency = 0.4,
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				TextSize = 12,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
		}),
		New("Frame", {
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			ThemeTag = {
				BackgroundColor3 = "TitleBarLine",
			},
		}),
	})

	TitleBar.CloseButton = BarButton(Assets.Close, UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
		Library.Window:Dialog({
			Title = "Close",
			Content = "Are you sure you want to unload the interface?",
			Buttons = {
				{
					Title = "Yes",
					Callback = function()
						Library:Destroy()
					end,
				},
				{
					Title = "No",
				},
			},
		})
	end)
	TitleBar.MaxButton = BarButton(Assets.Max, UDim2.new(1, -40, 0, 4), TitleBar.Frame, function()
		Config.Window.Maximize(not Config.Window.Maximized)
	end)
	TitleBar.MinButton = BarButton(Assets.Min, UDim2.new(1, -80, 0, 4), TitleBar.Frame, function()
		Library.Window:Minimize()
	end)

	return TitleBar
end
