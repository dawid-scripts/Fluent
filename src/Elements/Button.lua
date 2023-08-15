local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Button"

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	Config.Callback = Config.Callback or function() end

	local ButtonFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)

	local ButtonIco = New("ImageLabel", {
		Image = "rbxassetid://10709791437",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = ButtonFrame.Frame,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
		self.Library:SafeCallback(Config.Callback)
	end)

	return ButtonFrame
end

return Element
