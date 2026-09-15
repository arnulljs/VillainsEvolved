--!strict
-- Retention Engine: 10-Minute Hero Raids, Hourly XX:30 Big Score, and The Grind Endless Room
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local timerUpdateEv = remotes:WaitForChild("TimerUpdate") :: RemoteEvent
local noticeEv = remotes:WaitForChild("FloatingNotice") :: RemoteEvent
local enterRaidEv = remotes:WaitForChild("EnterRaid") :: RemoteEvent

local heroRaidTimer = Config.Raids.HeroRaid.intervalSeconds
local heroRaidActive = false
local heroRaidParticipants: { [Player]: boolean } = {}
local activeBossModel: Model? = nil
local bossHp = 0
local maxBossHp = 0

local function getDataManager()
	return (_G :: any).VillainsData
end

-- Timer Broadcast Loop (Runs every second)
task.spawn(function()
	while true do
		task.wait(1)

		-- 1. Hero Raid Timer (10-minute cycle)
		if not heroRaidActive then
			heroRaidTimer -= 1
			if heroRaidTimer <= 0 then
				heroRaidActive = true
				heroRaidTimer = Config.Raids.HeroRaid.intervalSeconds

				-- Broadcast 30s prep window
				for _, player in Players:GetPlayers() do
					noticeEv:FireClient(player, {
						text = "⚠️ HERO RAID STARTING! Join in the Plaza!",
						color = Color3.fromRGB(255, 60, 40),
					})
				end

				-- Start Boss Encounter after 10s prep
				task.defer(function()
					task.wait(10)
					maxBossHp = Config.Raids.HeroRaid.baseBossHealth * math.max(1, #Players:GetPlayers())
					bossHp = maxBossHp

					-- Spawn Boss Model in Hideout Plaza
					local plazaPos = Vector3.new(0, 5, -80)
					local model = Instance.new("Model")
					model.Name = "HeroBoss_TheRookieCape"
					model.Parent = Workspace

					local torso = Instance.new("Part")
					torso.Name = "Torso"
					torso.Size = Vector3.new(4, 6, 2)
					torso.Position = plazaPos
					torso.Color = Color3.fromRGB(220, 200, 40)
					torso.Anchored = true
					torso.Parent = model

					local head = Instance.new("Part")
					head.Name = "Head"
					head.Size = Vector3.new(2, 2, 2)
					head.Position = plazaPos + Vector3.new(0, 4.5, 0)
					head.Color = Color3.fromRGB(240, 240, 240)
					head.Anchored = true
					head.Parent = model

					local bb = Instance.new("BillboardGui")
					bb.Size = UDim2.fromScale(6, 1.5)
					bb.StudsOffset = Vector3.new(0, 4, 0)
					bb.AlwaysOnTop = true
					bb.Parent = head

					local tl = Instance.new("TextLabel")
					tl.Size = UDim2.fromScale(1, 1)
					tl.BackgroundTransparency = 1
					tl.Text = "THE ROOKIE CAPE [HERO RAID]\n" .. Format.abbreviate(bossHp) .. " HP"
					tl.TextColor3 = Color3.fromRGB(255, 220, 40)
					tl.Font = Enum.Font.GothamBold
					tl.TextScaled = true
					tl.Parent = bb

					activeBossModel = model

					-- Boss combat tick
					while heroRaidActive and bossHp > 0 do
						task.wait(1)
						-- Anyone near the boss deals damage
						for _, player in Players:GetPlayers() do
							local char = player.Character
							if char and char:FindFirstChild("HumanoidRootPart") then
								local root = char.HumanoidRootPart :: BasePart
								if (root.Position - plazaPos).Magnitude <= 40 then
									heroRaidParticipants[player] = true
									local data = getDataManager()
									local p = data and data.Get(player)
									local dmg = p and math.max(10, p.Infamy) or 10
									bossHp = math.max(0, bossHp - dmg)

									-- Check Enrage at 40%
									if bossHp <= maxBossHp * 0.4 then
										torso.Color = Color3.fromRGB(255, 40, 40)
									end

									tl.Text = "THE ROOKIE CAPE\n" .. Format.abbreviate(bossHp) .. " / " .. Format.abbreviate(maxBossHp) .. " HP"
								end
							end
						end
					end

					-- Boss Defeated!
					if model then model:Destroy() end
					heroRaidActive = false

					-- Payout RNG drops to all participants
					local dataMgr = getDataManager()
					for player, _ in heroRaidParticipants do
						if player.Parent and dataMgr then
							local heatReward = math.random(500, 2000)
							dataMgr.AddHeat(player, heatReward)
							noticeEv:FireClient(player, {
								text = "HERO RAID CLEARED! +" .. Format.comma(heatReward) .. " Heat!",
								color = Color3.fromRGB(255, 140, 0),
							})
						end
					end
					table.clear(heroRaidParticipants)
				end)
			end
		end

		-- 2. The Big Score Timer (Hourly anchored to XX:30)
		local date = os.date("*t")
		local currentMinute = date.min
		local currentSecond = date.sec
		local targetMinute = 30
		local minutesUntil = 0
		if currentMinute < targetMinute then
			minutesUntil = targetMinute - currentMinute
		else
			minutesUntil = (60 - currentMinute) + targetMinute
		end
		local bigScoreSecondsRemaining = (minutesUntil * 60) - currentSecond

		-- Broadcast to all clients
		timerUpdateEv:FireAllClients({
			heroRaidSeconds = heroRaidTimer,
			heroRaidActive = heroRaidActive,
			bigScoreSeconds = bigScoreSecondsRemaining,
		})
	end
end)

-- The Grind (Endless AFK Waves in side room)
task.spawn(function()
	local grindPos = Vector3.new(-100, 5, 0)
	while true do
		task.wait(Config.Raids.TheGrind.waveInterval)
		for _, player in Players:GetPlayers() do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart :: BasePart
				if (root.Position - grindPos).Magnitude <= 25 then
					local data = getDataManager()
					if data then
						data.AddHeat(player, Config.Raids.TheGrind.heatPerKill)
						noticeEv:FireClient(player, {
							text = "+ " .. tostring(Config.Raids.TheGrind.heatPerKill) .. " Heat [The Grind]",
							color = Color3.fromRGB(255, 120, 0),
						})
					end
				end
			end
		end
	end
end)

print("✓ Villains Evolved Raids & Retention Timers initialized.")