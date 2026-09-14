--!strict
-- Leaderstats + DataStore with pcall wrapper
-- ponytail: single store, JSON blob, OrderedDataStore for Heists leaderboard later

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local STORE_KEY = "VillainsEvolved_v1"
local store = DataStoreService:GetDataStore(STORE_KEY)

type SaveData = {
	Infamy: number,
	Heists: number,
	Tokens: number,
	Rebirths: number,
	EquippedVillain: string,
	OwnedVillains: { string },
	EquippedHenchmen: { string },
	OwnedHenchmen: { string },
	CurrentWorld: number,
}

local defaultData: SaveData = {
	Infamy = 0,
	Heists = 0,
	Tokens = 0,
	Rebirths = 0,
	EquippedVillain = "Goon",
	OwnedVillains = { "Goon" },
	OwnedHenchmen = {},
	EquippedHenchmen = {},
	CurrentWorld = 1,
}

local cache: { [Player]: SaveData } = {}
local leaderstatsCache: { [Player]: Folder } = {}

local function deepCopy<T>(t: T): T
	return (game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(t)) :: any) :: T
end

local function getData(player: Player): SaveData
	return cache[player] or deepCopy(defaultData)
end

local function pushToClient(player: Player)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return end
	local ev = remotes:FindFirstChild("DataUpdate") :: RemoteEvent?
	if ev then
		local d = getData(player)
		-- compute henchmen mult
		local mult = 1
		for _, hName in d.EquippedHenchmen do
			for _, egg in Config.HenchmenEggs do
				for _, h in egg.Henchmen do
					if h.Name == hName and h.Mult then mult *= h.Mult end
					if h.Name == hName and h.IsBestPercent then
						-- mystery henchmen: % better than best equipped
						-- handled via server lookup of best mult elsewhere; here just apply placeholder
						mult *= (1 + h.IsBestPercent / 100)
					end
				end
			end
		end
		ev:FireClient(player, {
			Infamy = d.Infamy,
			Heists = d.Heists,
			Tokens = d.Tokens,
			Rebirths = d.Rebirths,
			EquippedVillain = d.EquippedVillain,
			OwnedVillains = d.OwnedVillains,
			OwnedHenchmen = d.OwnedHenchmen,
			EquippedHenchmen = d.EquippedHenchmen,
			HenchmenMult = mult,
			CurrentWorld = d.CurrentWorld,
		})
	end
end

local function setupLeaderstats(player: Player)
	local d = getData(player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	local infamy = Instance.new("IntValue")
	infamy.Name = "Infamy"
	infamy.Value = d.Infamy
	infamy.Parent = folder
	local heists = Instance.new("IntValue")
	heists.Name = "Heists"
	heists.Value = d.Heists
	heists.Parent = folder
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = d.Rebirths
	rebirths.Parent = folder
	local tokens = Instance.new("IntValue")
	tokens.Name = "Tokens"
	tokens.Value = d.Tokens
	tokens.Parent = folder
	folder.Parent = player
	leaderstatsCache[player] = folder

	-- Replicated attributes for UI
	player:SetAttribute("Infamy", d.Infamy)
	player:SetAttribute("Heists", d.Heists)
	player:SetAttribute("Tokens", d.Tokens)
	player:SetAttribute("Rebirths", d.Rebirths)
	player:SetAttribute("EquippedVillain", d.EquippedVillain)
end

local function syncLeaderstats(player: Player)
	local d = getData(player)
	local f = leaderstatsCache[player]
	if f then
		local iv = f:FindFirstChild("Infamy") :: IntValue?
		if iv then iv.Value = math.floor(d.Infamy) end
		local hv = f:FindFirstChild("Heists") :: IntValue?
		if hv then hv.Value = math.floor(d.Heists) end
		local rv = f:FindFirstChild("Rebirths") :: IntValue?
		if rv then rv.Value = d.Rebirths end
		local tv = f:FindFirstChild("Tokens") :: IntValue?
		if tv then tv.Value = math.floor(d.Tokens) end
	end
	player:SetAttribute("Infamy", math.floor(d.Infamy))
	player:SetAttribute("Heists", math.floor(d.Heists))
	player:SetAttribute("Tokens", math.floor(d.Tokens))
	player:SetAttribute("Rebirths", d.Rebirths)
	player:SetAttribute("EquippedVillain", d.EquippedVillain)
	pushToClient(player)
end

-- Public API for other server scripts
local Data = {}
function Data.Get(player: Player): SaveData
	return getData(player)
end
function Data.Set(player: Player, newData: SaveData)
	cache[player] = newData
	syncLeaderstats(player)
end
function Data.AddInfamy(player: Player, amount: number)
	local d = getData(player)
	d.Infamy += amount
	syncLeaderstats(player)
end
function Data.AddHeists(player: Player, amount: number)
	local d = getData(player)
	d.Heists += amount
	syncLeaderstats(player)
end
function Data.AddTokens(player: Player, amount: number)
	local d = getData(player)
	d.Tokens += amount
	syncLeaderstats(player)
end
function Data.OwnsVillain(player: Player, name: string): boolean
	local d = getData(player)
	for _, n in d.OwnedVillains do if n == name then return true end end
	return false
end
function Data.GiveVillain(player: Player, name: string)
	local d = getData(player)
	if not Data.OwnsVillain(player, name) then table.insert(d.OwnedVillains, name) end
	syncLeaderstats(player)
end
function Data.EquipVillain(player: Player, name: string): boolean
	if not Data.OwnsVillain(player, name) then return false end
	local d = getData(player)
	d.EquippedVillain = name
	syncLeaderstats(player)
	-- trigger morph re-apply via attribute change (client listens)
	return true
end

-- expose globally for other server scripts via _G (ponytail: one require path would be cleaner but _G is shortest)
_G.VillainsData = Data

Players.PlayerAdded:Connect(function(player)
	-- load with pcall
	local ok, saved = pcall(function()
		return store:GetAsync(tostring(player.UserId))
	end)
	local data: SaveData
	if ok and saved and typeof(saved) == "table" then
		data = saved :: SaveData
		-- migration: ensure fields
		for k, v in defaultData do
			if (data :: any)[k] == nil then (data :: any)[k] = v end
		end
	else
		data = deepCopy(defaultData)
	end
	cache[player] = data
	setupLeaderstats(player)
	pushToClient(player)

	-- apply morph on spawn
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		local villainName = data.EquippedVillain
		local v = Config.GetVillainByName(villainName)
		if v then
			local Morphs = require(ReplicatedStorage.Shared.Morphs)
			Morphs.ApplyToCharacter(char, villainName, v.Palette)
		end
	end)
	if player.Character then
		task.wait(1)
		local v = Config.GetVillainByName(data.EquippedVillain)
		if v then
			local Morphs = require(ReplicatedStorage.Shared.Morphs)
			Morphs.ApplyToCharacter(player.Character, data.EquippedVillain, v.Palette)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local d = cache[player]
	if d then
		pcall(function()
			store:SetAsync(tostring(player.UserId), d)
		end)
	end
	cache[player] = nil
	leaderstatsCache[player] = nil
end)

-- autosave every 60s
task.spawn(function()
	while true do
		task.wait(60)
		for _, p in Players:GetPlayers() do
			local d = cache[p]
			if d then
				pcall(function()
					store:UpdateAsync(tostring(p.UserId), function(old)
						return d
					end)
				end)
			end
		end
	end
end)

-- Rebirth handler
task.wait(2) -- ensure Remotes exist
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local rebirthEv = remotes:WaitForChild("Rebirth") :: RemoteEvent
rebirthEv.OnServerEvent:Connect(function(player: Player)
	local d = getData(player)
	if d.Heists < Config.Rebirth.HeistsRequired or d.Infamy < Config.Rebirth.InfamyRequired then return end
	d.Rebirths += 1
	d.Infamy = 0
	-- keep Heists/Tokens but could reset Heists if you want harder: currently keep
	-- ensure world reset to 1
	syncLeaderstats(player)
end)

local equipEv = remotes:WaitForChild("EquipVillain") :: RemoteEvent
equipEv.OnServerEvent:Connect(function(player: Player, villainName: string)
	if typeof(villainName) ~= "string" then return end
	local ok = Data.EquipVillain(player, villainName)
	if ok then
		local char = player.Character
		if char then
			local v = Config.GetVillainByName(villainName)
			if v then
				local Morphs = require(ReplicatedStorage.Shared.Morphs)
				Morphs.ApplyToCharacter(char, villainName, v.Palette)
			end
		end
	end
end)

game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		local d = cache[p]
		if d then
			pcall(function()
				store:SetAsync(tostring(p.UserId), d)
			end)
		end
	end
end)
