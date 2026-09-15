--!strict
-- WorldBuilder: Authentic 3D Map Layout Grounded in Live Reference Screenshots
-- Constructs:
-- 1. Central Spawn Plaza with star emblem and stone pathing
-- 2. Stepped 3-Tier Villain Purchase Stadium (5 / 5 / 3 Pedestals + Mad Titan Overlord)
-- 3. The Training Zone (Gallows cranes with hanging punching bags & element pads)
-- 4. The Recruitment Crates / Eggs Area with District 2 Archway Portal & Leaderboards
-- 5. District 1 Heist Entrance Gate

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyVillainFn = remotes:WaitForChild("BuyVillain") :: RemoteFunction
local enterJobEv = remotes:WaitForChild("EnterJob") :: RemoteEvent

local function ensureFolder(name: string): Folder
	local f = Workspace:FindFirstChild(name) :: Folder?
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = Workspace
	end
	return f
end

local mapFolder = ensureFolder("VillainsEvolvedMap")
local pedestalsFolder = ensureFolder("Pedestals")
local stationsFolder = ensureFolder("TrainingStations")

-- Clear previous procedural parts
mapFolder:ClearAllChildren()
pedestalsFolder:ClearAllChildren()
stationsFolder:ClearAllChildren()

-- ========================================================
-- 1. CENTRAL SPAWN PLAZA & TERRAIN BASE
-- ========================================================
-- Large green grass baseplate
local baseplate = Instance.new("Part")
baseplate.Name = "GrassBaseplate"
baseplate.Size = Vector3.new(600, 2, 600)
baseplate.Position = Vector3.new(0, -1, 0)
baseplate.Color = Color3.fromRGB(115, 190, 60)
baseplate.Material = Enum.Material.Grass
baseplate.Anchored = true
baseplate.Parent = mapFolder

-- Central stone plaza
local spawnFloor = Instance.new("Part")
spawnFloor.Name = "CenterPlaza"
spawnFloor.Size = Vector3.new(48, 1, 48)
spawnFloor.Position = Vector3.new(0, 0.5, 0)
spawnFloor.Color = Color3.fromRGB(225, 225, 230)
spawnFloor.Material = Enum.Material.Concrete
spawnFloor.Anchored = true
spawnFloor.Parent = mapFolder

-- Black star / villain emblem on floor (Directly from Screenshot 1 & 3!)
local starEmblem = Instance.new("Part")
starEmblem.Name = "StarEmblem"
starEmblem.Size = Vector3.new(18, 0.1, 18)
starEmblem.Position = Vector3.new(0, 1.06, 0)
starEmblem.Color = Color3.fromRGB(30, 30, 35)
starEmblem.Material = Enum.Material.SmoothPlastic
starEmblem.Anchored = true
starEmblem.CanCollide = false
starEmblem.Parent = mapFolder

-- Spawn location
local spawnLoc = Instance.new("SpawnLocation")
spawnLoc.Size = Vector3.new(16, 1, 16)
spawnLoc.Position = Vector3.new(0, 1, 0)
spawnLoc.Transparency = 1
spawnLoc.Anchored = true
spawnLoc.Duration = 0
spawnLoc.Parent = mapFolder

-- Stone path going North towards the Heist / Stage 1
local northPath = Instance.new("Part")
northPath.Size = Vector3.new(14, 1, 60)
northPath.Position = Vector3.new(0, 0.5, -45)
northPath.Color = Color3.fromRGB(215, 215, 220)
northPath.Material = Enum.Material.Concrete
northPath.Anchored = true
northPath.Parent = mapFolder

-- Stone path going South towards the Villain Stadium
local southPath = Instance.new("Part")
southPath.Size = Vector3.new(14, 1, 50)
southPath.Position = Vector3.new(0, 0.5, 45)
southPath.Color = Color3.fromRGB(215, 215, 220)
southPath.Material = Enum.Material.Concrete
southPath.Anchored = true
southPath.Parent = mapFolder

-- Stone path going West towards the Training Zone
local westPath = Instance.new("Part")
westPath.Size = Vector3.new(60, 1, 14)
westPath.Position = Vector3.new(-50, 0.5, 0)
westPath.Color = Color3.fromRGB(215, 215, 220)
westPath.Material = Enum.Material.Concrete
westPath.Anchored = true
westPath.Parent = mapFolder

-- Stone path going East towards the Eggs / Crates Area
local eastPath = Instance.new("Part")
eastPath.Size = Vector3.new(60, 1, 14)
eastPath.Position = Vector3.new(50, 0.5, 0)
eastPath.Color = Color3.fromRGB(215, 215, 220)
eastPath.Material = Enum.Material.Concrete
eastPath.Anchored = true
eastPath.Parent = mapFolder

-- ========================================================
-- 2. STEPPED 3-TIER VILLAIN STADIUM (Screenshot 3)
-- ========================================================
-- Stepped stadium base (3 tiers of stairs)
local stadiumCenter = Vector3.new(0, 0.5, 95)

-- Tier 1 Base (Front Row)
local tier1 = Instance.new("Part")
tier1.Size = Vector3.new(70, 2, 18)
tier1.Position = stadiumCenter + Vector3.new(0, 1, -14)
tier1.Color = Color3.fromRGB(190, 195, 205)
tier1.Material = Enum.Material.Concrete
tier1.Anchored = true
tier1.Parent = mapFolder

-- Tier 2 Base (Middle Row - 2.5 studs higher)
local tier2 = Instance.new("Part")
tier2.Size = Vector3.new(66, 4.5, 18)
tier2.Position = stadiumCenter + Vector3.new(0, 2.25, 4)
tier2.Color = Color3.fromRGB(175, 180, 190)
tier2.Material = Enum.Material.Concrete
tier2.Anchored = true
tier2.Parent = mapFolder

-- Tier 3 Base (Top Row - 5 studs higher)
local tier3 = Instance.new("Part")
tier3.Size = Vector3.new(50, 7, 18)
tier3.Position = stadiumCenter + Vector3.new(0, 3.5, 22)
tier3.Color = Color3.fromRGB(160, 165, 175)
tier3.Material = Enum.Material.Concrete
tier3.Anchored = true
tier3.Parent = mapFolder

-- Stairs flanking left and right
local stairL = Instance.new("Part")
stairL.Size = Vector3.new(10, 5, 54)
stairL.Position = stadiumCenter + Vector3.new(-40, 2.5, 4)
stairL.Color = Color3.fromRGB(140, 145, 155)
stairL.Material = Enum.Material.Concrete
stairL.Anchored = true
stairL.Parent = mapFolder

local stairR = Instance.new("Part")
stairR.Size = Vector3.new(10, 5, 54)
stairR.Position = stadiumCenter + Vector3.new(40, 2.5, 4)
stairR.Color = Color3.fromRGB(140, 145, 155)
stairR.Material = Enum.Material.Concrete
stairR.Anchored = true
stairR.Parent = mapFolder

-- District 1 Villains List
local d1List = {}
for _, v in Config.Villains do
	if v.district == 1 and v.costType == "Loot" then
		table.insert(d1List, v)
	end
end

-- Helper to spawn each villain pedestal matching Screenshot 3
local function spawnVillainPedestal(v: Config.Villain, pos: Vector3)
	-- Cyan neon glowing standing pad
	local pad = Instance.new("Part")
	pad.Name = "Pad_" .. v.id
	pad.Size = Vector3.new(5, 0.4, 5)
	pad.Position = pos
	pad.Color = Color3.fromRGB(40, 220, 255)
	pad.Material = Enum.Material.Neon
	pad.Anchored = true
	pad.Parent = pedestalsFolder

	-- Character Statue Rig
	local statue = Instance.new("Model")
	statue.Name = "Statue_" .. v.id
	statue.Parent = pad

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = pos + Vector3.new(0, 1.4, 0)
	torso.Color = v.morph.torsoColor or v.morph.bodyColor
	torso.Anchored = true
	torso.CanCollide = false
	torso.Parent = statue

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Position = pos + Vector3.new(0, 2.8, 0)
	head.Color = v.morph.headColor or v.morph.bodyColor
	head.Shape = Enum.PartType.Ball
	head.Anchored = true
	head.CanCollide = false
	head.Parent = statue

	-- Overhead Billboard (Screenshot 3: Trophy Cost, Buy/Equip, +Power)
	local bb = Instance.new("BillboardGui")
	bb.Name = "InfoGui"
	bb.Size = UDim2.fromScale(5, 2.4)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head

	-- Cost Row (Yellow Trophy)
	local costRow = Instance.new("TextLabel")
	costRow.Size = UDim2.fromScale(1, 0.35)
	costRow.BackgroundTransparency = 1
	costRow.Text = (v.cost == 0) and "🏆 0" or ("🏆 " .. Format.abbreviate(v.cost))
	costRow.TextColor3 = Color3.fromRGB(255, 220, 40)
	costRow.Font = Enum.Font.GothamBold
	costRow.TextScaled = true
	costRow.Parent = bb

	-- Action: Buy or Equip
	local actionLabel = Instance.new("TextLabel")
	actionLabel.Size = UDim2.fromScale(1, 0.32)
	actionLabel.Position = UDim2.fromScale(0, 0.34)
	actionLabel.BackgroundTransparency = 1
	actionLabel.Text = (v.cost == 0) and "Equip" or "Buy"
	actionLabel.TextColor3 = (v.cost == 0) and Color3.fromRGB(80, 240, 120) or Color3.fromRGB(255, 200, 60)
	actionLabel.Font = Enum.Font.GothamBold
	actionLabel.TextScaled = true
	actionLabel.Parent = bb

	-- Power Per Click Row
	local powerLabel = Instance.new("TextLabel")
	powerLabel.Size = UDim2.fromScale(1, 0.32)
	powerLabel.Position = UDim2.fromScale(0, 0.68)
	powerLabel.BackgroundTransparency = 1
	powerLabel.Text = "+" .. Format.abbreviate(v.infamyPerClick) .. "/Power"
	powerLabel.TextColor3 = Color3.new(1, 1, 1)
	powerLabel.Font = Enum.Font.GothamBold
	powerLabel.TextScaled = true
	powerLabel.Parent = bb

	-- Proximity Prompt (Screenshot 3: [E] [Name] Equip / Buy)
	local prox = Instance.new("ProximityPrompt")
	prox.ObjectText = v.name
	prox.ActionText = (v.cost == 0) and "Equip" or ("Buy (" .. Format.abbreviate(v.cost) .. " Loot)")
	prox.HoldDuration = 0
	prox.MaxActivationDistance = 8
	prox.Parent = pad

	local targetId = v.id
	prox.Triggered:Connect(function(player)
		local data = (_G :: any).VillainsData or (shared :: any).VillainsData
		if data then
			if data.OwnsVillain(player, targetId) then
				data.EquipVillain(player, targetId)
			else
				local shop = (_G :: any).VillainsShop or (shared :: any).VillainsShop
				if shop and shop.BuyVillain then
					shop.BuyVillain(player, targetId)
				end
			end
		end
	end)
end

-- Tier 1 (5 Villains: 1 to 5)
local t1Spacing = 12
for i = 1, 5 do
	local v = d1List[i]
	if v then
		local x = (i - 3) * t1Spacing
		local pos = stadiumCenter + Vector3.new(x, 2.2, -14)
		spawnVillainPedestal(v, pos)
	end
end

-- Tier 2 (5 Villains: 6 to 10)
for i = 1, 5 do
	local v = d1List[i + 5]
	if v then
		local x = (i - 3) * t1Spacing
		local pos = stadiumCenter + Vector3.new(x, 4.7, 4)
		spawnVillainPedestal(v, pos)
	end
end

-- Tier 3 (3 Villains: 11 to 13)
for i = 1, 3 do
	local v = d1List[i + 10]
	if v then
		local x = (i - 2) * 14
		local pos = stadiumCenter + Vector3.new(x, 7.2, 22)
		spawnVillainPedestal(v, pos)
	end
end

-- The Overlord (Mad Titan) on the side with Limited Stock sign (Screenshot 3 & 4!)
local overlordBase = Instance.new("Part")
overlordBase.Size = Vector3.new(12, 1.5, 12)
overlordBase.Position = stadiumCenter + Vector3.new(46, 1, -14)
overlordBase.Color = Color3.fromRGB(30, 30, 35)
overlordBase.Material = Enum.Material.DiamondPlate
overlordBase.Anchored = true
overlordBase.Parent = mapFolder

local overlordPad = Instance.new("Part")
overlordPad.Size = Vector3.new(8, 0.5, 8)
overlordPad.Position = overlordBase.Position + Vector3.new(0, 1, 0)
overlordPad.Color = Color3.fromRGB(220, 40, 255)
overlordPad.Material = Enum.Material.Neon
overlordPad.Anchored = true
overlordPad.Parent = mapFolder

local titanStatue = Instance.new("Part")
titanStatue.Size = Vector3.new(4, 6, 3)
titanStatue.Position = overlordPad.Position + Vector3.new(0, 3.5, 0)
titanStatue.Color = Color3.fromRGB(120, 60, 160)
titanStatue.Anchored = true
titanStatue.Parent = mapFolder

local overlordGui = Instance.new("BillboardGui")
overlordGui.Size = UDim2.fromScale(10, 4)
overlordGui.StudsOffset = Vector3.new(0, 5.5, 0)
overlordGui.AlwaysOnTop = true
overlordGui.Parent = titanStatue

local stockLabel = Instance.new("TextLabel")
stockLabel.Size = UDim2.fromScale(1, 0.3)
stockLabel.BackgroundTransparency = 1
stockLabel.Text = "STOCK: 3245 / 10000"
stockLabel.TextColor3 = Color3.new(1, 1, 1)
stockLabel.Font = Enum.Font.GothamBold
stockLabel.TextScaled = true
stockLabel.Parent = overlordGui

local betterLabel = Instance.new("TextLabel")
betterLabel.Size = UDim2.fromScale(1, 0.3)
betterLabel.Position = UDim2.fromScale(0, 0.32)
betterLabel.BackgroundTransparency = 1
betterLabel.Text = "ALWAYS +100% OVER BEST"
betterLabel.TextColor3 = Color3.fromRGB(255, 60, 220)
betterLabel.Font = Enum.Font.GothamBold
betterLabel.TextScaled = true
betterLabel.Parent = overlordGui

local priceLabel = Instance.new("TextLabel")
priceLabel.Size = UDim2.fromScale(1, 0.35)
priceLabel.Position = UDim2.fromScale(0, 0.65)
priceLabel.BackgroundTransparency = 1
priceLabel.Text = "Mad Titan: Only 179 R$"
priceLabel.TextColor3 = Color3.fromRGB(255, 220, 40)
priceLabel.Font = Enum.Font.GothamBold
priceLabel.TextScaled = true
priceLabel.Parent = overlordGui

-- ========================================================
-- 3. THE TRAINING ZONE (Screenshot 4)
-- ========================================================
local trainCenter = Vector3.new(-95, 0.5, 0)

-- Billboard sign: TRAINING ZONE
local signPost = Instance.new("Part")
signPost.Size = Vector3.new(2, 16, 2)
signPost.Position = trainCenter + Vector3.new(0, 8, 32)
signPost.Color = Color3.fromRGB(80, 80, 85)
signPost.Anchored = true
signPost.Parent = mapFolder

local trainSign = Instance.new("Part")
trainSign.Size = Vector3.new(24, 8, 1)
trainSign.Position = trainCenter + Vector3.new(0, 16, 32)
trainSign.Color = Color3.fromRGB(255, 255, 255)
trainSign.Anchored = true
trainSign.Parent = mapFolder

local signGui = Instance.new("SurfaceGui")
signGui.Face = Enum.NormalId.Back
signGui.Parent = trainSign

local signText = Instance.new("TextLabel")
signText.Size = UDim2.fromScale(1, 1)
signText.BackgroundTransparency = 1
signText.Text = "TRAINING\nZONE"
signText.TextColor3 = Color3.fromRGB(30, 30, 30)
signText.Font = Enum.Font.GothamBold
signText.TextScaled = true
signText.Parent = signGui

-- Helper to spawn each crane gallows with punching bag & pool pad (Screenshot 4)
local function spawnTrainingGallows(name: string, pos: Vector3, padColor: Color3, mult: number, minRebirth: number)
	-- Element Pool Pad (lava, water, slime, acid, gold)
	local pad = Instance.new("Part")
	pad.Name = name .. "_Pad"
	pad.Size = Vector3.new(16, 1, 16)
	pad.Position = pos
	pad.Color = padColor
	pad.Material = Enum.Material.Neon
	pad.Anchored = true
	pad:SetAttribute("Multiplier", mult)
	pad:SetAttribute("MinRebirth", minRebirth)
	pad.Parent = stationsFolder

	-- Gallows Crane Structure
	local gallows = Instance.new("Model")
	gallows.Name = name .. "_Gallows"
	gallows.Parent = pad

	local pole = Instance.new("Part")
	pole.Size = Vector3.new(2, 14, 2)
	pole.Position = pos + Vector3.new(-7, 7, 0)
	pole.Color = Color3.fromRGB(60, 60, 65)
	pole.Anchored = true
	pole.Parent = gallows

	local arm = Instance.new("Part")
	arm.Size = Vector3.new(10, 2, 2)
	arm.Position = pos + Vector3.new(-3, 14, 0)
	arm.Color = Color3.fromRGB(60, 60, 65)
	arm.Anchored = true
	arm.Parent = gallows

	-- Punching Bag
	local bag = Instance.new("Part")
	bag.Size = Vector3.new(3.5, 6, 3.5)
	bag.Position = pos + Vector3.new(1, 8, 0)
	bag.Color = Color3.fromRGB(130, 70, 40)
	bag.Shape = Enum.PartType.Cylinder
	bag.Orientation = Vector3.new(0, 0, 90)
	bag.Anchored = true
	bag.Parent = gallows

	-- Station Billboard: [Rebirth X Unlocked] Yx Power
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromScale(6, 2)
	bb.StudsOffset = Vector3.new(0, 6, 0)
	bb.AlwaysOnTop = true
	bb.Parent = bag

	local statusTxt = Instance.new("TextLabel")
	statusTxt.Size = UDim2.fromScale(1, 0.45)
	statusTxt.BackgroundTransparency = 1
	statusTxt.Text = (minRebirth == 0) and "Unlocked" or string.format("Rebirth %d", minRebirth)
	statusTxt.TextColor3 = (minRebirth == 0) and Color3.fromRGB(80, 240, 120) or Color3.fromRGB(255, 80, 80)
	statusTxt.Font = Enum.Font.GothamBold
	statusTxt.TextScaled = true
	statusTxt.Parent = bb

	local multTxt = Instance.new("TextLabel")
	multTxt.Size = UDim2.fromScale(1, 0.5)
	multTxt.Position = UDim2.fromScale(0, 0.48)
	multTxt.BackgroundTransparency = 1
	multTxt.Text = tostring(mult) .. "x Power"
	multTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
	multTxt.Font = Enum.Font.GothamBold
	multTxt.TextScaled = true
	multTxt.Parent = bb
end

-- 6 Gallows Stations matching Screenshot 4
spawnTrainingGallows("Station_1x", trainCenter + Vector3.new(-22, 0.5, 14), Color3.fromRGB(120, 130, 140), 1, 0)
spawnTrainingGallows("Station_4x", trainCenter + Vector3.new(0, 0.5, 14), Color3.fromRGB(40, 160, 240), 4, 2)
spawnTrainingGallows("Station_10x_Fire", trainCenter + Vector3.new(22, 0.5, 14), Color3.fromRGB(255, 60, 20), 10, 4)
spawnTrainingGallows("Station_10x_Gold", trainCenter + Vector3.new(-22, 0.5, -14), Color3.fromRGB(255, 215, 0), 10, 8)
spawnTrainingGallows("Station_50x_Toxic", trainCenter + Vector3.new(0, 0.5, -14), Color3.fromRGB(40, 220, 80), 50, 15)
spawnTrainingGallows("Station_100x_Void", trainCenter + Vector3.new(22, 0.5, -14), Color3.fromRGB(160, 40, 220), 100, 25)

-- ========================================================
-- 4. EGGS & CRATES AREA (Screenshot 5)
-- ========================================================
local eggCenter = Vector3.new(95, 0.5, 0)

-- Billboard sign: EGGS
local eggSignPost = Instance.new("Part")
eggSignPost.Size = Vector3.new(2, 16, 2)
eggSignPost.Position = eggCenter + Vector3.new(0, 8, 32)
eggSignPost.Color = Color3.fromRGB(80, 80, 85)
eggSignPost.Anchored = true
eggSignPost.Parent = mapFolder

local eggSign = Instance.new("Part")
eggSign.Size = Vector3.new(20, 8, 1)
eggSign.Position = eggCenter + Vector3.new(0, 16, 32)
eggSign.Color = Color3.fromRGB(255, 255, 255)
eggSign.Anchored = true
eggSign.Parent = mapFolder

local eSignGui = Instance.new("SurfaceGui")
eSignGui.Face = Enum.NormalId.Back
eSignGui.Parent = eggSign

local eSignText = Instance.new("TextLabel")
eSignText.Size = UDim2.fromScale(1, 1)
eSignText.BackgroundTransparency = 1
eSignText.Text = "EGGS &\nCRATES"
eSignText.TextColor3 = Color3.fromRGB(30, 30, 30)
eSignText.Font = Enum.Font.GothamBold
eSignText.TextScaled = true
eSignText.Parent = eSignGui

-- District 2 Blue Archway Portal (Screenshot 5!)
local portalArch = Instance.new("Part")
portalArch.Size = Vector3.new(16, 22, 4)
portalArch.Position = eggCenter + Vector3.new(25, 11, -5)
portalArch.Color = Color3.fromRGB(30, 140, 220)
portalArch.Material = Enum.Material.Concrete
portalArch.Anchored = true
portalArch.Parent = mapFolder

local portalInside = Instance.new("Part")
portalInside.Size = Vector3.new(10, 16, 1)
portalInside.Position = portalArch.Position
portalInside.Color = Color3.fromRGB(40, 220, 255)
portalInside.Material = Enum.Material.Neon
portalInside.Anchored = true
portalInside.Parent = mapFolder

local pGui = Instance.new("BillboardGui")
pGui.Size = UDim2.fromScale(8, 2.5)
pGui.StudsOffset = Vector3.new(0, 8, 0)
pGui.AlwaysOnTop = true
pGui.Parent = portalInside

local pText = Instance.new("TextLabel")
pText.Size = UDim2.fromScale(1, 1)
pText.BackgroundTransparency = 1
pText.Text = "World 2\n[Req: 350K Loot]"
pText.TextColor3 = Color3.fromRGB(255, 255, 255)
pText.Font = Enum.Font.GothamBold
pText.TextScaled = true
pText.Parent = pGui

-- Egg / Crate Stands in a row
local eggTypes = {
	{ name = "Common Crate", cost = "10 Loot", mult = "+15% Power", color = Color3.fromRGB(240, 240, 240) },
	{ name = "Slums Egg", cost = "250 Loot", mult = "+50% Power", color = Color3.fromRGB(240, 220, 60) },
	{ name = "Shadow Crate", cost = "2.5K Loot", mult = "+165% Power", color = Color3.fromRGB(180, 50, 220) },
	{ name = "Mythic Crate", cost = "65 R$", mult = "+350% Power", color = Color3.fromRGB(40, 220, 120) },
}

for i, egg in ipairs(eggTypes) do
	local x = -24 + (i * 12)
	local eggPos = eggCenter + Vector3.new(x, 1, -5)

	-- Stand
	local stand = Instance.new("Part")
	stand.Size = Vector3.new(6, 1.5, 6)
	stand.Position = eggPos
	stand.Color = Color3.fromRGB(40, 45, 50)
	stand.Material = Enum.Material.DiamondPlate
	stand.Anchored = true
	stand.Parent = mapFolder

	-- Egg Model
	local eggPart = Instance.new("Part")
	eggPart.Size = Vector3.new(4, 5.5, 4)
	eggPart.Position = eggPos + Vector3.new(0, 3.5, 0)
	eggPart.Color = egg.color
	eggPart.Shape = Enum.PartType.Ball
	eggPart.Material = Enum.Material.SmoothPlastic
	eggPart.Anchored = true
	eggPart.Parent = stand

	-- Overhead Egg Info
	local eBb = Instance.new("BillboardGui")
	eBb.Size = UDim2.fromScale(6, 2.2)
	eBb.StudsOffset = Vector3.new(0, 3.5, 0)
	eBb.AlwaysOnTop = true
	eBb.Parent = eggPart

	local eName = Instance.new("TextLabel")
	eName.Size = UDim2.fromScale(1, 0.35)
	eName.BackgroundTransparency = 1
	eName.Text = egg.name
	eName.TextColor3 = Color3.new(1, 1, 1)
	eName.Font = Enum.Font.GothamBold
	eName.TextScaled = true
	eName.Parent = eBb

	local eMult = Instance.new("TextLabel")
	eMult.Size = UDim2.fromScale(1, 0.3)
	eMult.Position = UDim2.fromScale(0, 0.34)
	eMult.BackgroundTransparency = 1
	eMult.Text = egg.mult
	eMult.TextColor3 = Color3.fromRGB(80, 240, 120)
	eMult.Font = Enum.Font.GothamBold
	eMult.TextScaled = true
	eMult.Parent = eBb

	local eCost = Instance.new("TextLabel")
	eCost.Size = UDim2.fromScale(1, 0.3)
	eCost.Position = UDim2.fromScale(0, 0.68)
	eCost.BackgroundTransparency = 1
	eCost.Text = egg.cost
	eCost.TextColor3 = Color3.fromRGB(255, 215, 0)
	eCost.Font = Enum.Font.GothamBold
	eCost.TextScaled = true
	eCost.Parent = eBb

	local prox = Instance.new("ProximityPrompt")
	prox.ObjectText = egg.name
	prox.ActionText = "Hatch (" .. egg.cost .. ")"
	prox.HoldDuration = 0
	prox.MaxActivationDistance = 8
	prox.Parent = stand

	prox.Triggered:Connect(function(player)
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local buyCrateFn = remotes and remotes:FindFirstChild("BuyCrate") :: RemoteFunction?
		if buyCrateFn then
			buyCrateFn:InvokeServer("crate_slums")
		end
	end)
end

-- Physical Heist Stages (1 to 15) are dynamically managed by Dungeon.server.lua

print("✓ Villains Evolved WorldBuilder: Completed 3D Stadium, Training Zone, and Eggs Area.")
