--!strict
-- Power Engine: Uncapped Infamy Growth, Multiplier Stack, and Anti-Exploit Rate Limiting
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local trainEv = remotes:WaitForChild("Train") :: RemoteEvent
local noticeEv = remotes:WaitForChild("FloatingNotice") :: RemoteEvent

type RateTrack = {
	lastSecond: number,
	clicksThisSecond: number,
}
local clickTrackers: { [Player]: RateTrack } = {}

local function getDataManager()
	return (_G :: any).VillainsData
end

local function computeMultiplierStack(player: Player): number
	local data = getDataManager()
	if not data then return 1 end
	local p = data.Get(player)

	-- 1. Base villain infamy
	local v = Config.GetVillain(p.EquippedVillain)
	local base = 1
	if v then
		if v.id == "mad_titan_d1" then
			local best = 1
			for ownedId, _ in p.OwnedVillains do
				local ov = Config.GetVillain(ownedId)
				if ov and ov.id ~= "mad_titan_d1" and ov.infamyPerClick > best then
					best = ov.infamyPerClick
				end
			end
			base = best * 2
		else
			base = math.max(1, v.infamyPerClick)
		end
	end

	-- 2. Henchmen multiplier
	local henchMult = 0
	for _, hId in p.EquippedHenchmen do
		for _, h in Config.Henchmen do
			if h.id == hId then
				henchMult += h.multipliers.infamy
				break
			end
		end
	end

	-- 3. Rebirth multiplier (+2x per rebirth, matching live screenshots)
	local rebirthMult = Config.Rebirth.multiplier(p.Rebirths)

	-- 4. Gamepasses & bonuses
	local passMult = 1
	if player:GetAttribute("Pass_2x Infamy") == true then
		passMult *= 2
	end
	if player:GetAttribute("Pass_VIP Kingpin") == true then
		passMult *= 1.5
	end
	if p.FirstPurchaseBonus then
		passMult *= 1.25
	end

	return math.floor(base * (1 + henchMult) * rebirthMult * passMult)
end

trainEv.OnServerEvent:Connect(function(player: Player, payload: any)
	local count = 1
	if typeof(payload) == "table" and typeof(payload.count) == "number" then
		count = math.clamp(math.floor(payload.count), 1, 10)
	end

	-- Rate limiting: Max 25 clicks per second
	local now = os.time()
	local track = clickTrackers[player]
	if not track or track.lastSecond ~= now then
		track = { lastSecond = now, clicksThisSecond = 0 }
		clickTrackers[player] = track
	end

	if track.clicksThisSecond + count > 25 then
		return
	end
	track.clicksThisSecond += count

	local gainPerClick = computeMultiplierStack(player)
	local totalGain = gainPerClick * count

	local data = getDataManager()
	if not data then return end

	-- Uncapped: Infamy always increases!
	data.AddInfamy(player, totalGain)

	-- Direct punch hit on dungeon enemies if player is inside a stage
	local dungeon = (_G :: any).VillainsDungeon or (shared :: any).VillainsDungeon
	if dungeon and dungeon.OnPlayerPunch then
		dungeon.OnPlayerPunch(player)
	end

	noticeEv:FireClient(player, {
		text = "+" .. Format.abbreviate(totalGain) .. " Infamy",
		color = Color3.fromRGB(190, 60, 230),
	})
end)

-- Training Station auto-gain: ticks every second for players standing on stations
task.spawn(function()
	while true do
		task.wait(1)
		local data = getDataManager()
		if not data then continue end

		for _, player in Players:GetPlayers() do
			local char = player.Character
			if not char then continue end
			local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then continue end

			local p = data.Get(player)
			local stationsFolder = Workspace:FindFirstChild("TrainingStations")
			if stationsFolder then
				for _, station in stationsFolder:GetChildren() do
					if station:IsA("BasePart") then
						local dist = (station.Position - root.Position).Magnitude
						if dist <= (station.Size.X / 2) + 2 then
							local mult = station:GetAttribute("Multiplier") or 1
							local minRebirth = station:GetAttribute("MinRebirth") or 0
							if p.Rebirths >= minRebirth then
								local gain = computeMultiplierStack(player) * mult
								data.AddInfamy(player, gain)
							end
						end
					end
				end
			end
		end
	end
end)

local PowerEngine = {
	ComputeMultiplierStack = computeMultiplierStack,
}
;(_G :: any).VillainsPower = PowerEngine
;(shared :: any).VillainsPower = PowerEngine

print("✓ Villains Evolved Uncapped Power Engine initialized.")