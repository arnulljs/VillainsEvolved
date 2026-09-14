--!strict
-- Heist dungeon: levels with enemy NPCs, Escape Van cashout, death forfeits unbanked Heists
-- ponytail: one dungeon, levels scaled by Config, no per-world dungeon mesh — reuse same arena + recolor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local enterEv = remotes:WaitForChild("EnterDungeon") :: RemoteEvent
local cashOutEv = remotes:WaitForChild("CashOut") :: RemoteEvent

type Run = {
	player: Player,
	level: number,
	unbankedHeists: number,
	alive: boolean,
	enemies: { Model },
}

local runs: { [Player]: Run } = {}
local DUNGEON_POS = Vector3.new(0, 5, 100)
local HUB_POS = Vector3.new(0, 5, 0)
local VAN_POS = Vector3.new(15, 1, 100)

local function ensureDungeonParts()
	local folder = Workspace:FindFirstChild("Dungeon")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Dungeon"
		folder.Parent = Workspace
	end
	local arena = folder:FindFirstChild("Arena")
	if not arena then
		arena = Instance.new("Part")
		arena.Name = "Arena"
		arena.Size = Vector3.new(60, 1, 60)
		arena.Position = DUNGEON_POS - Vector3.new(0, 5, 0)
		arena.Anchored = true
		arena.Color = Color3.fromRGB(40, 40, 40)
		arena.Parent = folder
	end
	local van = folder:FindFirstChild("EscapeVan")
	if not van then
		van = Instance.new("Part")
		van.Name = "EscapeVan"
		van.Size = Vector3.new(8, 4, 12)
		van.Position = VAN_POS
		van.Anchored = true
		van.Color = Color3.fromRGB(255, 220, 0)
		van.Material = Enum.Material.Neon
		van.Parent = folder
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Top
		sg.Parent = van
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Text = "ESCAPE VAN — cash out Heists"
		tl.TextScaled = true
		tl.TextColor3 = Color3.new(0, 0, 0)
		tl.Font = Enum.Font.GothamBold
		tl.Parent = sg
		local prox = Instance.new("ProximityPrompt")
		prox.ObjectText = "Escape Van"
		prox.ActionText = "Cash Out"
		prox.HoldDuration = 0
		prox.MaxActivationDistance = 15
		prox.Parent = van
	end
	return folder
end

local dungeonFolder = ensureDungeonParts()

local function getInfamy(player: Player): number
	local data = (_G :: any).VillainsData
	if not data then
		return 0
	end
	return data.Get(player).Infamy
end

local function enemyHealthFor(level: number, worldId: number): number
	local base = Config.Dungeon.BaseEnemyHealth
	local growth = Config.Dungeon.HealthGrowth
	local worldMult = 1 + (worldId - 1) * 2
	return math.floor(base * (growth ^ (level - 1)) * worldMult)
end

local function heistsFor(level: number, worldId: number): number
	local base = Config.Dungeon.HeistsPerLevel
	local growth = Config.Dungeon.HeistsGrowth
	local worldMult = math.max(1, worldId * 0.8)
	return math.floor(base * (growth ^ (level - 1)) * worldMult)
end

local function spawnEnemies(player: Player, level: number, worldId: number): { Model }
	local folder = dungeonFolder :: Folder
	local enemies: { Model } = {}
	local count = Config.Dungeon.EnemiesPerLevel
	local health = enemyHealthFor(level, worldId)
	for i = 1, count do
		local m = Instance.new("Model")
		m.Name = "Enemy_L" .. tostring(level) .. "_" .. tostring(i)
		local part = Instance.new("Part")
		part.Name = "Torso"
		part.Size = Vector3.new(2, 3, 1)
		part.Position = DUNGEON_POS + Vector3.new(math.random(-15, 15), 2, math.random(-15, 15))
		part.Anchored = true
		part.Color = Color3.fromRGB(200, 40, 40)
		part.Parent = m
		m.PrimaryPart = part
		local hum = Instance.new("Humanoid")
		hum.MaxHealth = health
		hum.Health = health
		hum.Parent = m
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(100, 30)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.Parent = part
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Text = "HP " .. tostring(health)
		tl.TextScaled = true
		tl.TextColor3 = Color3.fromRGB(255, 255, 255)
		tl.Parent = billboard
		-- simple click-to-damage via ProximityPrompt (ponytail: no tool needed)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Attack"
		prompt.ObjectText = "Enemy Lv" .. tostring(level)
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 20
		prompt.Parent = part
		prompt.Triggered:Connect(function(triggeredBy: Player)
			if triggeredBy ~= player then
				return
			end
			local run = runs[player]
			if not run or not run.alive then
				return
			end
			local dmg = 0
			local gppc = (_G :: any).GetPowerPerClick
			if gppc then
				dmg = gppc(player)
			else
				dmg = getInfamy(player)
			end
			-- clamp dmg to 1 min
			dmg = math.max(1, dmg)
			hum.Health -= dmg
			tl.Text = "HP " .. tostring(math.max(0, math.floor(hum.Health)))
			if hum.Health <= 0 then
				-- check if all enemies dead
				local allDead = true
				for _, em in run.enemies do
					local eh = em:FindFirstChildOfClass("Humanoid") :: Humanoid?
					if eh and eh.Health > 0 then
						allDead = false
						break
					end
				end
				if allDead then
					run.unbankedHeists += heistsFor(level, worldId)
					run.level += 1
					-- auto-spawn next level or wait for cashout choice (ponytail: auto next, player must van to bank)
					task.wait(0.5)
					if runs[player] and runs[player].alive then
						-- clear old enemies
						for _, em in run.enemies do
							em:Destroy()
						end
						run.enemies = spawnEnemies(player, run.level, worldId)
					end
				end
			end
		end)
		m.Parent = folder
		table.insert(enemies, m)
	end
	return enemies
end

local function clearRun(player: Player, forfeit: boolean)
	local run = runs[player]
	if not run then
		return
	end
	for _, em in run.enemies do
		if em.Parent then
			em:Destroy()
		end
	end
	if forfeit then
		-- lose unbanked
	else
		-- already banked elsewhere
	end
	runs[player] = nil
end

local function teleportTo(player: Player, pos: Vector3)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then
		hrp.CFrame = CFrame.new(pos + Vector3.new(math.random(-5, 5), 3, math.random(-5, 5)))
	end
end

local function startRun(player: Player)
	if runs[player] then
		clearRun(player, true)
	end
	local data = (_G :: any).VillainsData
	if not data then
		return
	end
	local d = data.Get(player)
	local worldId = d.CurrentWorld
	local run: Run = {
		player = player,
		level = 1,
		unbankedHeists = 0,
		alive = true,
		enemies = {},
	}
	runs[player] = run
	run.enemies = spawnEnemies(player, 1, worldId)
	teleportTo(player, DUNGEON_POS)
	-- death listener for forfeit
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid") :: Humanoid?
		if hum then
			hum.Died:Connect(function()
				local r = runs[player]
				if r and r.alive then
					r.alive = false
					clearRun(player, true)
					task.wait(3)
					if player.Parent then
						teleportTo(player, HUB_POS)
					end
				end
			end)
		end
	end
end

enterEv.OnServerEvent:Connect(function(player: Player)
	-- gate check: need some Infamy
	if getInfamy(player) < 1 then
		return
	end
	startRun(player)
end)

cashOutEv.OnServerEvent:Connect(function(player: Player)
	local run = runs[player]
	if not run or not run.alive then
		return
	end
	-- must be near van (anti-exploit)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp and (hrp.Position - VAN_POS).Magnitude > 25 then
		return
	end
	local amount = run.unbankedHeists
	if amount <= 0 then
		amount = heistsFor(run.level - 1, 1)
	end -- at least 1 if cleared 1
	-- 2x Heists pass
	if player:GetAttribute("Pass_2x Heists") == true then
		amount *= 2
	end
	local data = (_G :: any).VillainsData
	if data then
		data.AddHeists(player, amount)
	end
	clearRun(player, false)
	teleportTo(player, HUB_POS)
end)

-- ProximityPrompt on van also triggers cashout
task.wait(1)
local van = dungeonFolder:FindFirstChild("EscapeVan")
if van then
	local prompt = van:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt?
	if prompt then
		prompt.Triggered:Connect(function(plr: Player)
			local run = runs[plr]
			if run and run.alive then
				local amount = run.unbankedHeists
				if amount == 0 then
					amount = 1
				end
				if plr:GetAttribute("Pass_2x Heists") == true then
					amount *= 2
				end
				local data = (_G :: any).VillainsData
				if data then
					data.AddHeists(plr, amount)
				end
				clearRun(plr, false)
				teleportTo(plr, HUB_POS)
			end
		end)
	end
end

Players.PlayerRemoving:Connect(function(p)
	clearRun(p, true)
end)
