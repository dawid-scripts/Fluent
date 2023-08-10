local Themes = {
	Names = {}
}

for _, Theme in next, script:GetChildren() do
	local Required = require(Theme)
	Themes[Required.Name] = Required
	table.insert(Themes.Names, Required.Name)
end

return Themes
