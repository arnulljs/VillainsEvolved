--!strict
-- Ponytail morphs: single R15 rig + palette + wedge/mesh accessories + decal
-- No Blender, no imported meshes. 90% likeness via colors/silhouette.
-- ponytail: palette rig, per-villain meshes if retention demands

local Morphs = {}

type PaletteDef = { Primary: Color3, Secondary: Color3, Accent: Color3, DecalId: string? }

local Palettes: { [string]: PaletteDef } = {
	Gray = {
		Primary = Color3.fromRGB(110, 110, 110),
		Secondary = Color3.fromRGB(70, 70, 70),
		Accent = Color3.fromRGB(40, 40, 40),
	},
	RedBlack = {
		Primary = Color3.fromRGB(200, 20, 20),
		Secondary = Color3.fromRGB(20, 20, 20),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	BlackRed = {
		Primary = Color3.fromRGB(20, 20, 20),
		Secondary = Color3.fromRGB(180, 20, 20),
		Accent = Color3.fromRGB(80, 80, 80),
	},
	PurpleGreen = {
		Primary = Color3.fromRGB(120, 40, 200),
		Secondary = Color3.fromRGB(40, 180, 70),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	GreenPurple = {
		Primary = Color3.fromRGB(40, 180, 70),
		Secondary = Color3.fromRGB(110, 40, 180),
		Accent = Color3.fromRGB(255, 220, 0),
	},
	OrangeBrown = {
		Primary = Color3.fromRGB(220, 140, 40),
		Secondary = Color3.fromRGB(90, 50, 20),
		Accent = Color3.fromRGB(255, 220, 150),
	},
	SilverBlue = {
		Primary = Color3.fromRGB(180, 190, 200),
		Secondary = Color3.fromRGB(40, 90, 180),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	GreenSilver = {
		Primary = Color3.fromRGB(40, 140, 60),
		Secondary = Color3.fromRGB(180, 180, 180),
		Accent = Color3.fromRGB(255, 215, 0),
	},
	YellowRed = {
		Primary = Color3.fromRGB(255, 220, 0),
		Secondary = Color3.fromRGB(200, 20, 20),
		Accent = Color3.fromRGB(40, 40, 40),
	},
	PurpleGold = {
		Primary = Color3.fromRGB(90, 40, 160),
		Secondary = Color3.fromRGB(255, 215, 0),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	BlackWhite = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(240, 240, 240),
		Accent = Color3.fromRGB(180, 0, 0),
	},
	IceBlue = {
		Primary = Color3.fromRGB(150, 220, 255),
		Secondary = Color3.fromRGB(40, 90, 180),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	YellowBlue = {
		Primary = Color3.fromRGB(255, 230, 0),
		Secondary = Color3.fromRGB(40, 90, 200),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	GreenGold = {
		Primary = Color3.fromRGB(40, 160, 60),
		Secondary = Color3.fromRGB(255, 215, 0),
		Accent = Color3.fromRGB(20, 20, 20),
	},
	BlackGreen = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(40, 160, 60),
		Accent = Color3.fromRGB(100, 255, 120),
	},
	RedGold = {
		Primary = Color3.fromRGB(180, 20, 20),
		Secondary = Color3.fromRGB(255, 215, 0),
		Accent = Color3.fromRGB(40, 40, 40),
	},
	PinkCyan = {
		Primary = Color3.fromRGB(255, 60, 140),
		Secondary = Color3.fromRGB(0, 220, 220),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	CyanYellow = {
		Primary = Color3.fromRGB(0, 220, 220),
		Secondary = Color3.fromRGB(255, 230, 0),
		Accent = Color3.fromRGB(20, 20, 20),
	},
	BlackPurple = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(90, 40, 160),
		Accent = Color3.fromRGB(200, 150, 255),
	},
	BlackBlue = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(40, 90, 180),
		Accent = Color3.fromRGB(100, 160, 255),
	},
	OrangeGray = {
		Primary = Color3.fromRGB(210, 120, 40),
		Secondary = Color3.fromRGB(120, 120, 120),
		Accent = Color3.fromRGB(60, 60, 60),
	},
	WhiteBlack = {
		Primary = Color3.fromRGB(240, 240, 240),
		Secondary = Color3.fromRGB(15, 15, 15),
		Accent = Color3.fromRGB(200, 0, 0),
	},
	RedYellow = {
		Primary = Color3.fromRGB(200, 20, 20),
		Secondary = Color3.fromRGB(255, 220, 0),
		Accent = Color3.fromRGB(40, 40, 40),
	},
	PurpleOrange = {
		Primary = Color3.fromRGB(120, 40, 180),
		Secondary = Color3.fromRGB(255, 140, 0),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	OrangeRed = {
		Primary = Color3.fromRGB(255, 100, 0),
		Secondary = Color3.fromRGB(200, 20, 20),
		Accent = Color3.fromRGB(255, 220, 0),
	},
	GrayOrange = {
		Primary = Color3.fromRGB(120, 120, 120),
		Secondary = Color3.fromRGB(255, 120, 0),
		Accent = Color3.fromRGB(40, 40, 40),
	},
	BlackOrange = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(255, 100, 0),
		Accent = Color3.fromRGB(255, 220, 0),
	},
	YellowBlack = {
		Primary = Color3.fromRGB(255, 220, 0),
		Secondary = Color3.fromRGB(15, 15, 15),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	BlackCyan = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(0, 220, 220),
		Accent = Color3.fromRGB(255, 255, 255),
	},
	BlueRed = {
		Primary = Color3.fromRGB(40, 90, 200),
		Secondary = Color3.fromRGB(200, 20, 20),
		Accent = Color3.fromRGB(255, 255, 255),
	},
}

local function applyColor(part: BasePart, c: Color3)
	part.Color = c
	part.Material = Enum.Material.SmoothPlastic
end

local function makePart(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = false
	p.CanCollide = false
	p.Massless = true
	applyColor(p, color)
	p.Parent = parent
	return p
end

-- Build a villain morph model around a HumanoidRootPart. Caller must weld to character.
function Morphs.BuildVillainModel(villainName: string, paletteName: string): Model
	local pal = Palettes[paletteName] or Palettes.Gray
	local model = Instance.new("Model")
	model.Name = villainName .. "_Morph"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.CanCollide = false
	root.Anchored = false
	root.Parent = model
	model.PrimaryPart = root

	-- Torso block
	local torso = makePart("Torso", Vector3.new(2, 2, 1), CFrame.new(0, 0, 0), pal.Primary, model)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = torso
	weld.Parent = torso

	-- Shoulders / cape wedge
	if string.find(paletteName, "Purple") or paletteName == "GreenSilver" or paletteName == "RedGold" then
		local cape = Instance.new("WedgePart")
		cape.Name = "Cape"
		cape.Size = Vector3.new(2, 2.5, 0.4)
		cape.CFrame = torso.CFrame * CFrame.new(0, -0.2, 0.7)
		applyColor(cape, pal.Secondary)
		cape.Anchored = false
		cape.CanCollide = false
		cape.Massless = true
		cape.Parent = model
		local w2 = Instance.new("WeldConstraint")
		w2.Part0 = torso
		w2.Part1 = cape
		w2.Parent = cape
	end

	-- Horns for Trickster / Tyrant silhouettes
	if paletteName == "GreenGold" or paletteName == "PurpleGold" then
		for _, side in { -1, 1 } do
			local horn = makePart(
				"Horn",
				Vector3.new(0.3, 0.9, 0.3),
				torso.CFrame * CFrame.new(side * 0.6, 1.4, 0),
				pal.Accent,
				model
			)
			local w = Instance.new("WeldConstraint")
			w.Part0 = torso
			w.Part1 = horn
			w.Parent = horn
		end
	end

	-- Mask / helmet block
	local head =
		makePart("Head", Vector3.new(1.1, 1.1, 1.1), torso.CFrame * CFrame.new(0, 1.6, 0), pal.Secondary, model)
	local hw = Instance.new("WeldConstraint")
	hw.Part0 = torso
	hw.Part1 = head
	hw.Parent = head

	-- Attach decal for face if needed (cheap 90% likeness)
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Front
	decal.Texture = "" -- leave empty for now, swap to rbxassetid when you upload villain faces
	decal.Parent = head

	-- Arms
	for _, side in { -1, 1 } do
		local arm =
			makePart("Arm", Vector3.new(0.5, 1.6, 0.5), torso.CFrame * CFrame.new(side * 1.3, 0, 0), pal.Primary, model)
		local aw = Instance.new("WeldConstraint")
		aw.Part0 = torso
		aw.Part1 = arm
		aw.Parent = arm
	end

	-- Legs
	for _, side in { -1, 1 } do
		local leg = makePart(
			"Leg",
			Vector3.new(0.6, 1.8, 0.6),
			torso.CFrame * CFrame.new(side * 0.5, -1.9, 0),
			pal.Secondary,
			model
		)
		local lw = Instance.new("WeldConstraint")
		lw.Part0 = torso
		lw.Part1 = leg
		lw.Parent = leg
	end

	return model
end

-- Equip morph on character: hide original, weld morph to HRP
function Morphs.ApplyToCharacter(character: Model, villainName: string, paletteName: string)
	-- cleanup old morph
	local old = character:FindFirstChild(villainName .. "_Morph")
	if old then
		old:Destroy()
	end
	for _, c in character:GetChildren() do
		if c.Name:find("_Morph$") then
			c:Destroy()
		end
	end

	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return
	end

	local morph = Morphs.BuildVillainModel(villainName, paletteName or "Gray")
	morph.Parent = character

	-- weld morph root to HRP
	local morphRoot = morph.PrimaryPart
	if morphRoot and hrp then
		local w = Instance.new("WeldConstraint")
		w.Part0 = hrp
		w.Part1 = morphRoot
		w.Parent = hrp
	end

	-- hide original parts (keep HRP visible for physics)
	for _, part in character:GetChildren() do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part:IsDescendantOf(morph) then
			part.Transparency = 1
			if part.Name ~= "Head" then
				part.CanCollide = false
			end
		end
		if part:IsA("Accessory") then
			part:Destroy()
		end
	end
end

function Morphs.ClearMorph(character: Model)
	for _, c in character:GetChildren() do
		if c.Name:find("_Morph$") then
			c:Destroy()
		end
	end
	for _, part in character:GetChildren() do
		if part:IsA("BasePart") then
			part.Transparency = 0
		end
	end
end

-- For Studio preview: build standalone model in Workspace.VillainPreview
function Morphs.PreviewInWorkspace(villainName: string, paletteName: string)
	local ws = game:GetService("Workspace")
	local folder = ws:FindFirstChild("VillainPreview")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "VillainPreview"
		folder.Parent = ws
	end
	folder:ClearAllChildren()
	local m = Morphs.BuildVillainModel(villainName, paletteName)
	m.Parent = folder
	m:PivotTo(CFrame.new(0, 5, 0))
	return m
end

function Morphs.ApplyMorph(player: Player, villainId: string)
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Config = require(ReplicatedStorage.Shared.Config)
	local Format = require(ReplicatedStorage.Shared.Format)
	local v = Config.GetVillain(villainId)
	if not v then return end

	-- Clean up previous villain accessories/auras/titles
	for _, c in char:GetChildren() do
		if c.Name == "VillainCape" or c.Name == "VillainTitle" or c.Name == "VillainAccessory" then
			c:Destroy()
		end
		-- Remove existing standard clothing so villain colors and costume are visible
		if c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") then
			c:Destroy()
		end
	end

	local torsoPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") :: BasePart?
	local headPart = char:FindFirstChild("Head") :: BasePart?
	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?

	-- Apply BodyColors
	local bodyColors = char:FindFirstChildOfClass("BodyColors")
	if not bodyColors then
		bodyColors = Instance.new("BodyColors")
		bodyColors.Parent = char
	end

	local bColor = v.morph.bodyColor or Color3.fromRGB(90, 90, 90)
	local hColor = v.morph.headColor or bColor
	local tColor = v.morph.torsoColor or bColor

	bodyColors.HeadColor3 = hColor
	bodyColors.TorsoColor3 = tColor
	bodyColors.LeftArmColor3 = bColor
	bodyColors.RightArmColor3 = bColor
	bodyColors.LeftLegColor3 = tColor
	bodyColors.RightLegColor3 = tColor

	-- Direct Part Color Tinting & Material
	for _, part in char:GetChildren() do
		if part:IsA("BasePart") then
			if part.Name == "Head" then
				part.Color = hColor
				part.Material = Enum.Material.SmoothPlastic
			elseif part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Torso" then
				part.Color = tColor
				part.Material = Enum.Material.SmoothPlastic
			elseif part.Name ~= "HumanoidRootPart" then
				part.Color = bColor
				part.Material = Enum.Material.SmoothPlastic
			end
		end
	end

	-- Avatar Scaling (R15 scale properties)
	local scale = v.morph.scale or 1.0
	local scales = { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }
	for _, sName in scales do
		local val = humanoid:FindFirstChild(sName) :: NumberValue?
		if val then
			val.Value = scale
		end
	end

	-- Procedural Villain Cape (Screenshot 1 & 2 aesthetic: flowing dark cape)
	if torsoPart then
		local cape = Instance.new("Part")
		cape.Name = "VillainCape"
		cape.Size = Vector3.new(2.4 * scale, 3.4 * scale, 0.15)
		cape.Color = tColor
		cape.Material = Enum.Material.Fabric
		cape.CanCollide = false
		cape.Massless = true
		cape.Parent = char

		local cframeOffset = CFrame.new(0, -0.2 * scale, 0.7 * scale) * CFrame.Angles(math.rad(12), 0, 0)
		cape.CFrame = torsoPart.CFrame * cframeOffset

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torsoPart
		weld.Part1 = cape
		weld.Parent = cape

		-- Cape Gold/Accent Trim
		local trim = Instance.new("Part")
		trim.Name = "VillainAccessory"
		trim.Size = Vector3.new(2.5 * scale, 0.3 * scale, 0.2)
		trim.Color = v.morph.auraColor or Color3.fromRGB(240, 200, 50)
		trim.Material = Enum.Material.Neon
		trim.CanCollide = false
		trim.Massless = true
		trim.Parent = char
		trim.CFrame = cape.CFrame * CFrame.new(0, 1.6 * scale, 0)

		local trimWeld = Instance.new("WeldConstraint")
		trimWeld.Part0 = cape
		trimWeld.Part1 = trim
		trimWeld.Parent = trim
	end

	-- Particle Aura on HumanoidRootPart
	if hrp then
		local oldAura = hrp:FindFirstChild("VillainAura")
		if oldAura then oldAura:Destroy() end

		if v.morph.auraColor then
			local pe = Instance.new("ParticleEmitter")
			pe.Name = "VillainAura"
			pe.Color = ColorSequence.new(v.morph.auraColor)
			pe.LightEmission = 0.7
			pe.Size = NumberSequence.new(1.2 * scale, 0)
			pe.Rate = 18
			pe.Lifetime = NumberRange.new(0.6, 1.2)
			pe.Speed = NumberRange.new(2, 4)
			pe.SpreadAngle = Vector2.new(180, 180)
			pe.Parent = hrp
		end
	end

	-- Overhead Title Billboard
	if headPart then
		local oldTitle = headPart:FindFirstChild("VillainTitle")
		if oldTitle then oldTitle:Destroy() end

		local titleBb = Instance.new("BillboardGui")
		titleBb.Name = "VillainTitle"
		titleBb.Size = UDim2.fromScale(6, 1.5)
		titleBb.StudsOffset = Vector3.new(0, 2.5 * scale, 0)
		titleBb.AlwaysOnTop = true
		titleBb.Parent = headPart

		local tLabel = Instance.new("TextLabel")
		tLabel.Size = UDim2.fromScale(1, 0.6)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = string.format("【 %s 】", v.name)
		tLabel.TextColor3 = v.morph.auraColor or Color3.fromRGB(255, 215, 0)
		tLabel.Font = Enum.Font.GothamBold
		tLabel.TextScaled = true
		tLabel.Parent = titleBb

		local subLabel = Instance.new("TextLabel")
		subLabel.Size = UDim2.fromScale(1, 0.4)
		subLabel.Position = UDim2.fromScale(0, 0.6)
		subLabel.BackgroundTransparency = 1
		subLabel.Text = string.format("+%s/Click", Format.abbreviate(v.infamyPerClick))
		subLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		subLabel.Font = Enum.Font.GothamBold
		subLabel.TextScaled = true
		subLabel.Parent = titleBb
	end
end

;(_G :: any).VillainsMorphs = Morphs
;(shared :: any).VillainsMorphs = Morphs
return Morphs

