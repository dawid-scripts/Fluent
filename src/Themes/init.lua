local Themes = {
	Names = {
		"Dark",
		"Darker",
		"Light",
		"Aqua",
		"Amethyst",
		"Rose"
	}
}

for _, Theme in next, Themes.Names do
	local Required = require(script[Theme])
	Themes[Theme] = Required
end

return Themes
