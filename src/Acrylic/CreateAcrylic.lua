local Creator = require(script.Parent.Parent.Creator)

local function createAcrylic()
    return Creator.New("Part", {
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
end

return createAcrylic