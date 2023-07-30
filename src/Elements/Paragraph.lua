local Root = script.Parent.Parent
local Components = Root.Components
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local Paragraph = {}
Paragraph.__index = Paragraph
Paragraph.__type = "Paragraph"

function Paragraph:New(Config)
    assert(Config.Title, 'Paragraph - Missing Title')
    Config.Content = Config.Content or ""
    
    local Paragrah = require(Components.Element)(Config.Title, Config.Content, Paragraph.Container, false)
    Paragrah.Frame.BackgroundTransparency = 0.92
    Paragrah.Border.Transparency = 0.6

    return Paragraph
end

return Paragraph