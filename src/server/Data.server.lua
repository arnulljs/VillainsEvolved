--!strict
-- Data management for Villains Evolved (Unlimited Infamy Growth, Grounded Leveling, and Rebirth)
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Morphs = require(ReplicatedStorage.Shared.Morphs)

local STORE_KEY = "VillainsEvolved_Profile_v3"
local profileStore = nil
pcall(function()
	profileStore = DataStoreService:GetDataStore(STORE_KEY)
end)

export type PlayerProfile = {
	Infamy: number,
	Loot: number,
	Heat: number,
	Rebirths: number,
	Level: number,
	LevelXp: number,
	District: number,
	HighestJob: number,
	OwnedVillains: { [string]: boolean },
	EquippedVillain: string,
	Henchmen: { string },
	EquippedHenchmen: { string },
	Items: { string },
	EquippedItems: { string },
	RedeemedCodes: { [string]: boolean },
	PlaytimeSeconds: number,
	LoginStreak: number,
	LastLoginDay: number,
	FirstPurchaseBonus: boolean,
	Stats: {
		TotalClicks: number,
		TotalJobs: number,
		JoinedAt: number,
	},
}

local defaultProfile: PlayerProfile = {
	Infamy = 0,
	Loot = 0,
	Heat = 0,
	Rebirths = 0,
	Level = 1,
	LevelXp = 0,
	District = 1,
	HighestJob = 0,
	OwnedVillains = { ["nobody"] = true },
	EquippedVillain = "nobody",
	Henchmen = {},
	EquippedHenchmen = {},
	Items = { "crowbar" },
	EquippedItems = { "crowbar" },
	RedeemedCodes = {},
	PlaytimeSeconds = 0,
	LoginStreak = 1,
	LastLoginDay = 0,
	FirstPurchaseBonus = false,
	Stats = {
		TotalClicks = 0,
		TotalJobs = 0,
		JoinedAt = 0,
	},
}

local sessionProfiles: { [Player]: PlayerProfile } = {}

local function deepCopy<T>(t: T): T
	return (game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(t)) :: any) :: T
end

local DataManager = {}

function DataManager.Get(player: Player): PlayerProfile
	return sessionProfiles[player] or deepCopy(defaultProfile)
end

function DataManager.Set(player: Player, profile: PlayerProfile)
	sessionProfiles[player] = profile
	DataManager.PushToClient(player)
	DataManager.UpdateLeaderstats(player)
end

function DataManager.PushToClient(player: Player)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return end
	local dataEv = remotes:FindFirstChild("DataUpdate") :: RemoteEvent?
	if not dataEv then return end

	local p = DataManager.Get(player)
	local maxLevel = Config.GetMaxLevel(p.Rebirths)
	local displayLevel = p.Level or 1
	local isMaxLevel = displayLevel >= maxLevel
	local nextLevelXp = Config.GetXpForLevel(displayLevel)
	local levelXp = p.LevelXp or 0
	local rebirthMult = Config.Rebirth.multiplier(p.Rebirths)
	local nextRebirthMult = Config.Rebirth.multiplier(p.Rebirths + 1)

	dataEv:FireClient(player, {
		Infamy = p.Infamy,
		Loot = p.Loot,
		Heat = p.Heat,
		Rebirths = p.Rebirths,
		District = p.District,
		HighestJob = p.HighestJob,
		OwnedVillains = p.OwnedVillains,
		EquippedVillain = p.EquippedVillain,
		Henchmen = p.Henchmen,
		EquippedHenchmen = p.EquippedHenchmen,
		Items = p.Items,
		EquippedItems = p.EquippedItems,
		Level = displayLevel,
		ReqLevel = maxLevel,
		LevelXp = levelXp,
		NextLevelXp = nextLevelXp,
		IsMaxLevel = isMaxLevel,
		CanRebirth = isMaxLevel,
		RebirthMult = rebirthMult,
		NextRebirthMult = nextRebirthMult,
		FirstPurchaseBonus = p.FirstPurchaseBonus,
	})
end

function DataManager.UpdateLeaderstats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats") :: Folder?
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local infamyVal = Instance.new("NumberValue")
		infamyVal.Name = "Infamy"
		infamyVal.Parent = leaderstats

		local lootVal = Instance.new("NumberValue")
		lootVal.Name = "Loot"
		lootVal.Parent = leaderstats

		local rapSheetVal = Instance.new("IntValue")
		rapSheetVal.Name = "Rebirths"
		rapSheetVal.Parent = leaderstats

		local heatVal = Instance.new("NumberValue")
		heatVal.Name = "Heat"
		heatVal.Parent = leaderstats
	end

	local p = DataManager.Get(player)
	local inf = leaderstats:FindFirstChild("Infamy") :: NumberValue?
	if inf then inf.Value = p.Infamy end
	local lt = leaderstats:FindFirstChild("Loot") :: NumberValue?
	if lt then lt.Value = p.Loot end
	local rs = leaderstats:FindFirstChild("Rebirths") :: IntValue?
	if rs then rs.Value = p.Rebirths end
	local ht = leaderstats:FindFirstChild("Heat") :: NumberValue?
	if ht then ht.Value = p.Heat end
end

-- Adds Infamy: UNLIMITED, never capped! Points feed experience bar to level up!
function DataManager.AddInfamy(player: Player, amount: number): number
	local p = DataManager.Get(player)
	p.Infamy += amount

	-- Points feed experience bar to level up (does not level up per click)
	local maxLevel = Config.GetMaxLevel(p.Rebirths)
	if p.Level < maxLevel then
		p.LevelXp = (p.LevelXp or 0) + amount
		local req = Config.GetXpForLevel(p.Level)
		while p.LevelXp >= req and p.Level < maxLevel do
			p.LevelXp -= req
			p.Level += 1
			req = Config.GetXpForLevel(p.Level)
		end
		if p.Level >= maxLevel then
			p.LevelXp = 0
		end
	end

	DataManager.Set(player, p)
	return amount
end

function DataManager.AddLoot(player: Player, amount: number)
	local p = DataManager.Get(player)
	p.Loot += amount
	DataManager.Set(player, p)
end

function DataManager.AddHeat(player: Player, amount: number)
	local p = DataManager.Get(player)
	p.Heat += amount
	DataManager.Set(player, p)
end

function DataManager.OwnsVillain(player: Player, villainId: string): boolean
	local p = DataManager.Get(player)
	return p.OwnedVillains[villainId] == true
end

function DataManager.GiveVillain(player: Player, villainId: string)
	local p = DataManager.Get(player)
	p.OwnedVillains[villainId] = true
	DataManager.Set(player, p)
end

function DataManager.EquipVillain(player: Player, villainId: string)
	local p = DataManager.Get(player)
	if p.OwnedVillains[villainId] then
		p.EquippedVillain = villainId
		DataManager.Set(player, p)

		Morphs.ApplyMorph(player, villainId)

		local v = Config.GetVillain(villainId)
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local noticeEv = remotes and remotes:FindFirstChild("FloatingNotice") :: RemoteEvent?
		if noticeEv and v then
			noticeEv:FireClient(player, {
				text = "EQUIPPED " .. v.name .. "! (+" .. Format.abbreviate(v.infamyPerClick) .. "/Click)",
				color = Color3.fromRGB(80, 220, 255),
			})
		end
	end
end

-- Rebirth: Resets power and level, raises multiplier by +2x, keeps villains/pets/items
-- NO RESPAWN OR TELEPORT: Player remains right where they are!
function DataManager.Rebirth(player: Player): (boolean, string)
	local p = DataManager.Get(player)
	local maxLevel = Config.GetMaxLevel(p.Rebirths)

	if p.Level < maxLevel then
		return false, string.format("Requires Level %d (Current: %d)", maxLevel, p.Level)
	end

	local keepRatio = 0.0
	for _, hId in p.EquippedHenchmen do
		if hId == "quantum_amoeba" then
			keepRatio = 0.25
			break
		end
	end

	p.Infamy = math.floor(p.Infamy * keepRatio)
	p.Level = 1
	p.LevelXp = 0
	p.Rebirths += 1
	DataManager.Set(player, p)

	return true, "Successfully Rebirthed!"
end

local function loadData(player: Player)
	local key = "Player_" .. tostring(player.UserId)
	local data = nil
	if profileStore then
		local success, result = pcall(function()
			return profileStore:GetAsync(key)
		end)
		if success and result then
			data = result
		end
	end

	if not data then
		data = deepCopy(defaultProfile)
	else
		for k, v in defaultProfile do
			if (data :: any)[k] == nil then
				(data :: any)[k] = deepCopy(v)
			end
		end
	end

	sessionProfiles[player] = data
	DataManager.UpdateLeaderstats(player)
	DataManager.PushToClient(player)

	task.defer(function()
		task.wait(1)
		DataManager.EquipVillain(player, data.EquippedVillain)
	end)
end

local function saveData(player: Player)
	local p = sessionProfiles[player]
	if not p or not profileStore then return end
	local key = "Player_" .. tostring(player.UserId)
	pcall(function()
		profileStore:SetAsync(key, p)
	end)
end

Players.PlayerAdded:Connect(function(player)
	loadData(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		local p = DataManager.Get(player)
		DataManager.EquipVillain(player, p.EquippedVillain)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player)
	sessionProfiles[player] = nil
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		saveData(player)
	end
end)

;(_G :: any).VillainsData = DataManager
;(shared :: any).VillainsData = DataManager
return DataManager
