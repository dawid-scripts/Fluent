local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local function createAcrylic()
	local ProtectInstance = require(Root.Packages.ProtectInstance)

	local Part = Creator.New("Part", {
		Name = "Body",
		Color = Color3.new(0, 0, 0),
		Material = Enum.Material.Glass,
		Size = Vector3.new(1, 1, 0),
		Anchored = true,
		CanCollide = false,
		Locked = true,
		CastShadow = false,
		Transparency = 0.98,
	}, {
		Creator.New("SpecialMesh", {
			MeshType = Enum.MeshType.Brick,
			Offset = Vector3.new(0, 0, -0.000001),
		})
	})

	if ProtectInstance then
		ProtectInstance.ProtectInstance(Part)
	end

	return Part
end

return createAcrylic
