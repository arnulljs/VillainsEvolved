--!strict
-- Click to gain Infamy + auto-pad loop

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local trainEv = remotes:WaitForChild("Train") :: RemoteEvent

local lastClick: { [Player]: number } = {}

local function getHenchmenMult(player: Player): number
	local data = (_G :: any).VillainsData
	if not data then
		return 1
	end
	local d = data.Get(player)
	local mult = 1
	for _, hName in d.EquippedHenchmen do
		for _, egg in Config.HenchmenEggs do
			for _, h in egg.Henchmen do
				if h.Name == hName and h.Mult then
					mult *= h.Mult
				end
			end
		end
	end
	return mult
end

local function hasPass(player: Player, passName: string): boolean
	-- TODO: wire MarketplaceService:UserOwnsGamePassAsync after publishing passes
	-- For now checks attribute set by Shop when Robux granted
	return player:GetAttribute("Pass_" .. passName) == true
end

local function getPowerPerClick(player: Player): number
	local data = (_G :: any).VillainsData
	if not data then
		return Config.Training.ClickBase
	end
	local d = data.Get(player)
	local villainName = d.EquippedVillain
	local v = Config.GetVillainByName(villainName)
	local base = 1
	if v and v.PowerPerClick then
		base = v.PowerPerClick
	elseif v and v.IsBestMultiplier then
		-- find best owned non-robux power
		local best = 1
		for _, owned in d.OwnedVillains do
			local ov = Config.GetVillainByName(owned)
			if ov and ov.PowerPerClick and ov.PowerPerClick > best then
				best = ov.PowerPerClick
			end
		end
		base = best * 2
	end
	local henchMult = getHenchmenMult(player)
	local rebirthMult = 1 + (d.Rebirths * Config.Rebirth.MultiplierPerRebirth)
	local total = base * henchMult * rebirthMult
	if hasPass(player, "2x Infamy") then
		total *= 2
	end
	return math.floor(total)
end

trainEv.OnServerEvent:Connect(function(player: Player)
	local now = os.clock()
	local last = lastClick[player] or 0
	if now - last < Config.Training.ClickCooldown then
		return
	end
	lastClick[player] = now

	local amount = getPowerPerClick(player)
	local data = (_G :: any).VillainsData
	if data then
		data.AddInfamy(player, amount)
	end
end)

-- Auto-train pad in Workspace.TrainingPad (create if missing)
local function ensureTrainingPad()
	local pad = Workspace:FindFirstChild("TrainingPad")
	if not pad then
		pad = Instance.new("Part")
		pad.Name = "TrainingPad"
		pad.Size = Vector3.new(20, 1, 20)
		pad.Position = Vector3.new(0, 0.5, 0)
		pad.Anchored = true
		pad.Color = Color3.fromRGB(255, 0, 0)
		pad.Material = Enum.Material.Neon
		pad.Parent = Workspace
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Top
		sg.Parent = pad
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Text = "TRAINING PAD — auto Infamy"
		tl.TextScaled = true
		tl.TextColor3 = Color3.fromRGB(255, 255, 255)
		tl.Font = Enum.Font.GothamBold
		tl.Parent = sg
	end
	return pad :: BasePart
end

local pad = ensureTrainingPad()
local onPad: { [Player]: boolean } = {}

-- touch tracking ponytail: GetTouchingParts is flaky, use Region3 via Touched events
pad.Touched:Connect(function(hit)
	local plr = Players:GetPlayerFromCharacter(hit.Parent)
	if plr then
		onPad[plr] = true
	end
end)
pad.TouchEnded:Connect(function(hit)
	local plr = Players:GetPlayerFromCharacter(hit.Parent)
	if plr then
		onPad[plr] = false
	end
end)

-- fallback: distance check every second for mobile
task
	.spawn(function()
		while true do
			task.wait(1)
			for _, plr in Players:GetPlayers() do
				local char = plr.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hrp then
					local dist = (hrp.Position - pad.Position).Magnitude
					onPad[plr] = dist < 15
				end
			end
			for plr, active in onPad do
				if active then
					local amount = getPowerPerClick(plr) * Config.Training.AutoPadPerSecond
					-- if Auto-Train pass, also outside pad via Power.server? handled here as bonus ticks even outside pad
					local data = (_G :: any).VillainsData
					if data then
						data.AddInfamy(plr, amount)
					end
				end
			end
			-- grant Auto-Train pass users Infamy even outside pad (2x pad rate /2 = trickle)
			for _, plr in Players:GetPlayers() do
				if hasPass(plr, "Auto-Train") and not onPad[plr] then
					local amount = math.floor(getPowerPerClick(plr) * 2)
					local data = (_G :: any).VillainsData
					if data then
						data.AddInfamy(plr, amount)
					end
				end
			end
		end
	end)
	-- Expose for other scripts
	(_G :: any)
	.GetPowerPerClick =
	getPowerPerClick
