--!strict
-- Seamless Physical Canyon Heist Stages (Screenshots 1, 2, 3)
-- Features:
-- 1. Translucent entrance you walk through (no click required)
-- 2. Square canyon arena triggering enemy spawns (3 simultaneous Zombie enemies)
-- 3. Impassable red wall across the room with billboard 'Defeat the enemies!'
-- 4. Auto-combat loop dealing damage per tick based on player Infamy
-- 5. Upon defeat: wall turns passable ('Stage N+1 | Recommended Power: X')
-- 6. Dual cashout pads: Left (Magenta 10x Wins) & Right (Yellow Proportionate Wins Return)
-- 7. Player can either cash out or walk directly into the next stage!

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Workspace = game:GetService('Workspace')

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)

local remotes = ReplicatedStorage:WaitForChild('Remotes')
local noticeEv = remotes:WaitForChild('FloatingNotice') :: RemoteEvent

local function getDataManager()
	return (_G :: any).VillainsData
end

local function ensureFolder(name: string, parent: Instance): Folder
	local f = parent:FindFirstChild(name) :: Folder?
	if not f then
		f = Instance.new('Folder')
		f.Name = name
		f.Parent = parent
	end
	return f
end

local dungeonFolder = ensureFolder('CanyonDungeon', Workspace)

type EnemyData = {
	model: Model,
	rootPart: BasePart,
	humanoid: Humanoid,
	rightShoulder: Motor6D?,
	currentHp: number,
	maxHp: number,
	fillFrame: Frame,
	hpLabel: TextLabel,
	lastAttackTime: number,
}

type StageState = {
	stageIndex: number,
	roomFolder: Folder,
	entrancePart: BasePart,
	exitWall: BasePart,
	exitBillboard: BillboardGui,
	exitText: TextLabel,
	padFree: BasePart,
	padVan: BasePart,
	enemies: { EnemyData },
	isCleared: boolean,
	clearedTime: number?,
}

local stageStates: { [number]: StageState } = {}

-- Spawns active Humanoid zombie rig inside canyon room
local function spawnEnemy(parent: Folder, name: string, pos: Vector3, hp: number): EnemyData
	local model = Instance.new('Model')
	model.Name = name
	model.Parent = parent

	-- HumanoidRootPart for unanchored movement & pathfinding
	local hrp = Instance.new('Part')
	hrp.Name = 'HumanoidRootPart'
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Position = pos + Vector3.new(0, 3, 0)
	hrp.Transparency = 1
	hrp.CanCollide = false
	hrp.Anchored = false
	hrp.Parent = model
	model.PrimaryPart = hrp

	local humanoid = Instance.new('Humanoid')
	humanoid.MaxHealth = math.max(100, hp)
	humanoid.Health = math.max(100, hp)
	humanoid.WalkSpeed = 13
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model

	-- Torso
	local torso = Instance.new('Part')
	torso.Name = 'Torso'
	torso.Size = Vector3.new(2.6, 2.6, 1.3)
	torso.Position = hrp.Position
	torso.Color = Color3.fromRGB(45, 60, 75)
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = false
	torso.CanCollide = false
	torso.Parent = model

	local torsoWeld = Instance.new('WeldConstraint')
	torsoWeld.Part0 = hrp
	torsoWeld.Part1 = torso
	torsoWeld.Parent = torso

	-- Head
	local head = Instance.new('Part')
	head.Name = 'Head'
	head.Size = Vector3.new(1.4, 1.4, 1.4)
	head.Position = hrp.Position + Vector3.new(0, 1.9, 0)
	head.Color = Color3.fromRGB(115, 160, 140) -- Zombie green skin
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = false
	head.CanCollide = false
	head.Parent = model

	local headWeld = Instance.new('WeldConstraint')
	headWeld.Part0 = torso
	headWeld.Part1 = head
	headWeld.Parent = head

	-- Left Arm
	local armL = Instance.new('Part')
	armL.Name = 'LeftArm'
	armL.Size = Vector3.new(1, 2.2, 1)
	armL.Position = hrp.Position + Vector3.new(-1.8, 0, 0.4)
	armL.Color = Color3.fromRGB(115, 160, 140)
	armL.Material = Enum.Material.SmoothPlastic
	armL.Anchored = false
	armL.CanCollide = false
	armL.Parent = model

	local armLWeld = Instance.new('WeldConstraint')
	armLWeld.Part0 = torso
	armLWeld.Part1 = armL
	armLWeld.Parent = armL

	-- Right Arm (Motor6D for attack swing)
	local armR = Instance.new('Part')
	armR.Name = 'RightArm'
	armR.Size = Vector3.new(1, 2.2, 1)
	armR.Position = hrp.Position + Vector3.new(1.8, 0, 0.4)
	armR.Color = Color3.fromRGB(115, 160, 140)
	armR.Material = Enum.Material.SmoothPlastic
	armR.Anchored = false
	armR.CanCollide = false
	armR.Parent = model

	local rightShoulder = Instance.new('Motor6D')
	rightShoulder.Name = 'RightShoulder'
	rightShoulder.Part0 = torso
	rightShoulder.Part1 = armR
	rightShoulder.C0 = CFrame.new(1.8, 0, 0.4)
	rightShoulder.Parent = torso

	-- Legs
	local legs = Instance.new('Part')
	legs.Name = 'Legs'
	legs.Size = Vector3.new(2.4, 2.2, 1.2)
	legs.Position = hrp.Position + Vector3.new(0, -1.5, 0)
	legs.Color = Color3.fromRGB(35, 45, 55)
	legs.Material = Enum.Material.SmoothPlastic
	legs.Anchored = false
	legs.CanCollide = false
	legs.Parent = model

	local legsWeld = Instance.new('WeldConstraint')
	legsWeld.Part0 = torso
	legsWeld.Part1 = legs
	legsWeld.Parent = legs

	-- Health GUI (Screenshot 2: Name + HP Bar)
	local bb = Instance.new('BillboardGui')
	bb.Name = 'HealthGui'
	bb.Size = UDim2.fromScale(4.5, 1.4)
	bb.StudsOffset = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head

	local nLabel = Instance.new('TextLabel')
	nLabel.Size = UDim2.fromScale(1, 0.45)
	nLabel.BackgroundTransparency = 1
	nLabel.Text = name
	nLabel.TextColor3 = Color3.new(1, 1, 1)
	nLabel.Font = Enum.Font.GothamBold
	nLabel.TextScaled = true
	nLabel.Parent = bb

	local barBg = Instance.new('Frame')
	barBg.Name = 'BarBg'
	barBg.Size = UDim2.fromScale(1, 0.45)
	barBg.Position = UDim2.fromScale(0, 0.5)
	barBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	barBg.BorderSizePixel = 0
	barBg.Parent = bb

	local fill = Instance.new('Frame')
	fill.Name = 'Fill'
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(240, 40, 40)
	fill.BorderSizePixel = 0
	fill.Parent = barBg

	local hpLabel = Instance.new('TextLabel')
	hpLabel.Name = 'HpLabel'
	hpLabel.Size = UDim2.fromScale(1, 1)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = string.format('%s/%s', Format.abbreviate(hp), Format.abbreviate(hp))
	hpLabel.TextColor3 = Color3.new(1, 1, 1)
	hpLabel.Font = Enum.Font.GothamBold
	hpLabel.TextScaled = true
	hpLabel.Parent = barBg

	return {
		model = model,
		rootPart = hrp,
		humanoid = humanoid,
		rightShoulder = rightShoulder,
		currentHp = hp,
		maxHp = hp,
		fillFrame = fill,
		hpLabel = hpLabel,
		lastAttackTime = 0,
	}
end

-- Builds the continuous canyon corridor with 15 stages extending North
local ROOM_LENGTH = 70
local ROOM_WIDTH = 46
local START_Z = -75

local function buildPhysicalStages()
	dungeonFolder:ClearAllChildren()

	for stageIdx = 1, 15 do
		local stageCfg = Config.Jobs[1][stageIdx]
		local zEntrance = START_Z - ((stageIdx - 1) * ROOM_LENGTH)
		local zExit = zEntrance - ROOM_LENGTH
		local zCenter = (zEntrance + zExit) / 2

		local roomFolder = Instance.new('Folder')
		roomFolder.Name = 'Stage_' .. tostring(stageIdx)
		roomFolder.Parent = dungeonFolder

		-- Canyon Floor
		local floor = Instance.new('Part')
		floor.Name = 'Floor'
		floor.Size = Vector3.new(ROOM_WIDTH, 1, ROOM_LENGTH)
		floor.Position = Vector3.new(0, 0.5, zCenter)
		floor.Color = Color3.fromRGB(120, 195, 70)
		floor.Material = Enum.Material.Grass
		floor.Anchored = true
		floor.Parent = roomFolder

		-- Stepping stone path down center
		local stonePath = Instance.new('Part')
		stonePath.Size = Vector3.new(12, 1.05, ROOM_LENGTH)
		stonePath.Position = Vector3.new(0, 0.52, zCenter)
		stonePath.Color = Color3.fromRGB(215, 215, 220)
		stonePath.Material = Enum.Material.Concrete
		stonePath.Anchored = true
		stonePath.Parent = roomFolder

		-- Brown Stud Canyon Walls (Screenshots 1, 2, 3)
		local wallL = Instance.new('Part')
		wallL.Size = Vector3.new(12, 24, ROOM_LENGTH)
		wallL.Position = Vector3.new(-(ROOM_WIDTH / 2 + 6), 12, zCenter)
		wallL.Color = Color3.fromRGB(160, 95, 55)
		wallL.Material = Enum.Material.Brick
		wallL.Anchored = true
		wallL.Parent = roomFolder

		local wallR = Instance.new('Part')
		wallR.Size = Vector3.new(12, 24, ROOM_LENGTH)
		wallR.Position = Vector3.new(ROOM_WIDTH / 2 + 6, 12, zCenter)
		wallR.Color = Color3.fromRGB(160, 95, 55)
		wallR.Material = Enum.Material.Brick
		wallR.Anchored = true
		wallR.Parent = roomFolder

		-- Entrance Translucent Barrier (Walk through, CanCollide = false)
		local entrance = Instance.new('Part')
		entrance.Name = 'EntranceGate'
		entrance.Size = Vector3.new(ROOM_WIDTH, 20, 1)
		entrance.Position = Vector3.new(0, 10, zEntrance)
		entrance.Color = Color3.fromRGB(80, 220, 255)
		entrance.Material = Enum.Material.Neon
		entrance.Transparency = 0.75
		entrance.CanCollide = false
		entrance.Anchored = true
		entrance.Parent = roomFolder

		-- Entrance Arch Pillars
		local pilL = Instance.new('Part')
		pilL.Size = Vector3.new(4, 22, 4)
		pilL.Position = Vector3.new(-ROOM_WIDTH / 2 + 2, 11, zEntrance)
		pilL.Color = Color3.fromRGB(140, 80, 45)
		pilL.Material = Enum.Material.Brick
		pilL.Anchored = true
		pilL.Parent = roomFolder

		local pilR = Instance.new('Part')
		pilR.Size = Vector3.new(4, 22, 4)
		pilR.Position = Vector3.new(ROOM_WIDTH / 2 - 2, 11, zEntrance)
		pilR.Color = Color3.fromRGB(140, 80, 45)
		pilR.Material = Enum.Material.Brick
		pilR.Anchored = true
		pilR.Parent = roomFolder

		-- Entrance Billboard (Screenshot 1: 'Stage X | Recommended Power: Y')
		local entBb = Instance.new('BillboardGui')
		entBb.Size = UDim2.fromScale(12, 4.5)
		entBb.StudsOffset = Vector3.new(0, 8, 0)
		entBb.AlwaysOnTop = true
		entBb.Parent = entrance

		local entTitle = Instance.new('TextLabel')
		entTitle.Size = UDim2.fromScale(1, 0.45)
		entTitle.BackgroundTransparency = 1
		entTitle.Text = 'Stage ' .. tostring(stageIdx)
		entTitle.TextColor3 = Color3.new(1, 1, 1)
		entTitle.Font = Enum.Font.GothamBold
		entTitle.TextScaled = true
		entTitle.Parent = entBb

		local entRec = Instance.new('TextLabel')
		entRec.Size = UDim2.fromScale(1, 0.25)
		entRec.Position = UDim2.fromScale(0, 0.45)
		entRec.BackgroundTransparency = 1
		entRec.Text = 'Recommended'
		entRec.TextColor3 = Color3.fromRGB(80, 220, 255)
		entRec.Font = Enum.Font.GothamBold
		entRec.TextScaled = true
		entRec.Parent = entBb

		local entReq = Instance.new('TextLabel')
		entReq.Size = UDim2.fromScale(1, 0.3)
		entReq.Position = UDim2.fromScale(0, 0.7)
		entReq.BackgroundTransparency = 1
		entReq.Text = 'Power: ' .. Format.abbreviate(stageCfg.requiredInfamy)
		entReq.TextColor3 = Color3.fromRGB(80, 220, 255)
		entReq.Font = Enum.Font.GothamBold
		entReq.TextScaled = true
		entReq.Parent = entBb

		-- Impassable Exit Wall at far end (Screenshot 2: 'Defeat the enemies!', CanCollide = true initially)
		local exitWall = Instance.new('Part')
		exitWall.Name = 'ExitWall'
		exitWall.Size = Vector3.new(ROOM_WIDTH, 20, 1)
		exitWall.Position = Vector3.new(0, 10, zExit)
		exitWall.Color = Color3.fromRGB(240, 50, 50)
		exitWall.Material = Enum.Material.Neon
		exitWall.Transparency = 0.5
		exitWall.CanCollide = true
		exitWall.Anchored = true
		exitWall.Parent = roomFolder

		local exitBb = Instance.new('BillboardGui')
		exitBb.Size = UDim2.fromScale(12, 4)
		exitBb.StudsOffset = Vector3.new(0, 8, 0)
		exitBb.AlwaysOnTop = true
		exitBb.Parent = exitWall

		local exitText = Instance.new('TextLabel')
		exitText.Size = UDim2.fromScale(1, 0.8)
		exitText.BackgroundTransparency = 1
		exitText.Text = 'Defeat the enemies!'
		exitText.TextColor3 = Color3.fromRGB(255, 60, 60)
		exitText.Font = Enum.Font.GothamBold
		exitText.TextScaled = true
		exitText.Parent = exitBb

		-- Cash-out Pads (Screenshot 3: Left Magenta 10x, Right Yellow Return)
		local padZ = zExit + 8

		-- Left Pad: Magenta 10x Wins Pad
		local padVan = Instance.new('Part')
		padVan.Name = 'Pad_10x'
		padVan.Size = Vector3.new(9, 0.4, 7)
		padVan.Position = Vector3.new(-8, 1.05, padZ)
		padVan.Color = Color3.fromRGB(220, 40, 255)
		padVan.Material = Enum.Material.Neon
		padVan.Anchored = true
		padVan.Parent = roomFolder

		local vBb = Instance.new('BillboardGui')
		vBb.Size = UDim2.fromScale(6, 2)
		vBb.StudsOffset = Vector3.new(0, 2.5, 0)
		vBb.AlwaysOnTop = true
		vBb.Parent = padVan

		local vTxt = Instance.new('TextLabel')
		vTxt.Size = UDim2.fromScale(1, 1)
		vTxt.BackgroundTransparency = 1
		vTxt.Text = string.format('%s Wins\n10x Wins', Format.abbreviate(stageCfg.lootPayout * 10))
		vTxt.TextColor3 = Color3.fromRGB(240, 80, 255)
		vTxt.Font = Enum.Font.GothamBold
		vTxt.TextScaled = true
		vTxt.Parent = vBb

		-- Right Pad: Yellow Standard Rate Return Pad
		local padFree = Instance.new('Part')
		padFree.Name = 'Pad_Return'
		padFree.Size = Vector3.new(9, 0.4, 7)
		padFree.Position = Vector3.new(8, 1.05, padZ)
		padFree.Color = Color3.fromRGB(255, 230, 40)
		padFree.Material = Enum.Material.Neon
		padFree.Anchored = true
		padFree.Parent = roomFolder

		local fBb = Instance.new('BillboardGui')
		fBb.Size = UDim2.fromScale(6, 2)
		fBb.StudsOffset = Vector3.new(0, 2.5, 0)
		fBb.AlwaysOnTop = true
		fBb.Parent = padFree

		local fTxt = Instance.new('TextLabel')
		fTxt.Size = UDim2.fromScale(1, 1)
		fTxt.BackgroundTransparency = 1
		fTxt.Text = string.format('%s Wins\nReturn', Format.abbreviate(stageCfg.lootPayout))
		fTxt.TextColor3 = Color3.fromRGB(255, 225, 40)
		fTxt.Font = Enum.Font.GothamBold
		fTxt.TextScaled = true
		fTxt.Parent = fBb

		-- Register State
		local state: StageState = {
			stageIndex = stageIdx,
			roomFolder = roomFolder,
			entrancePart = entrance,
			exitWall = exitWall,
			exitBillboard = exitBb,
			exitText = exitText,
			padFree = padFree,
			padVan = padVan,
			enemies = {},
			isCleared = false,
			clearedTime = nil,
		}
		stageStates[stageIdx] = state

		-- Wire Cashout Pad Touches
		local targetStageIdx = stageIdx
		local targetPayout = stageCfg.lootPayout

		padFree.Touched:Connect(function(hit)
			local char = hit.Parent
			local plr = char and Players:GetPlayerFromCharacter(char)
			if plr and state.isCleared then
				local data = getDataManager()
				if data then
					data.AddLoot(plr, targetPayout)
					local p = data.Get(plr)
					if targetStageIdx > p.HighestJob then
						p.HighestJob = targetStageIdx
						data.Set(plr, p)
					end
				end

				noticeEv:FireClient(plr, {
					text = '+' .. Format.abbreviate(targetPayout) .. ' Wins!',
					color = Color3.fromRGB(255, 215, 0),
				})

				-- Teleport to Hideout spawn
				local hrp = char:FindFirstChild('HumanoidRootPart') :: BasePart?
				if hrp then
					hrp.CFrame = CFrame.new(0, 5, 0)
				end
			end
		end)

		padVan.Touched:Connect(function(hit)
			local char = hit.Parent
			local plr = char and Players:GetPlayerFromCharacter(char)
			if plr and state.isCleared then
				local data = getDataManager()
				local p = data and data.Get(plr)
				local payout10x = targetPayout * 10

				if data then
					data.AddLoot(plr, payout10x)
					if p and targetStageIdx > p.HighestJob then
						p.HighestJob = targetStageIdx
						data.Set(plr, p)
					end
				end

				noticeEv:FireClient(plr, {
					text = '+' .. Format.abbreviate(payout10x) .. ' Wins! (10x Pad)',
					color = Color3.fromRGB(240, 80, 255),
				})

				local hrp = char:FindFirstChild('HumanoidRootPart') :: BasePart?
				if hrp then
					hrp.CFrame = CFrame.new(0, 5, 0)
				end
			end
		end)
	end
end

buildPhysicalStages()

-- Game Loop: Checks player positions in canyon stages, triggers spawns and auto-combat
task.spawn(function()
	while true do
		task.wait(0.4)

		for stageIdx = 1, 15 do
			local state = stageStates[stageIdx]
			if not state then continue end
			local stageCfg = Config.Jobs[1][stageIdx]
			local zEntrance = START_Z - ((stageIdx - 1) * ROOM_LENGTH)
			local zExit = zEntrance - ROOM_LENGTH
			local zCenter = (zEntrance + zExit) / 2

			-- Check which players are inside this room
			local playersInRoom: { Player } = {}
			for _, plr in Players:GetPlayers() do
				local char = plr.Character
				if char and char:FindFirstChild('HumanoidRootPart') then
					local root = char.HumanoidRootPart :: BasePart
					local pos = root.Position
					if math.abs(pos.X) <= (ROOM_WIDTH / 2) and pos.Z <= zEntrance and pos.Z >= zExit then
						table.insert(playersInRoom, plr)
					end
				end
			end

			-- When room is empty: reset after players have moved on
			if #playersInRoom == 0 then
				if state.isCleared and state.clearedTime and (os.clock() - state.clearedTime) > 6 then
					state.isCleared = false
					state.clearedTime = nil
					state.exitWall.CanCollide = true
					state.exitWall.Color = Color3.fromRGB(240, 50, 50)
					state.exitWall.Transparency = 0.5
					state.exitText.Text = 'Defeat the enemies!'
					state.exitText.TextColor3 = Color3.fromRGB(255, 60, 60)
					for _, e in state.enemies do
						if e.model then e.model:Destroy() end
					end
					table.clear(state.enemies)
				end
				continue
			end

			-- Player entered room: Spawn 3 simultaneous enemies (Screenshot 2)
			if #state.enemies == 0 and not state.isCleared then
				local enemyName = (stageIdx == 15 and stageCfg.bossName) or 'Zombie'
				local perHp = math.max(1, math.floor(stageCfg.enemyHp / 3))

				local offsets = {
					Vector3.new(-7, 0, zCenter),
					Vector3.new(0, 0, zCenter + 2),
					Vector3.new(7, 0, zCenter),
				}

				for _, off in offsets do
					local e = spawnEnemy(state.roomFolder, enemyName, off, perHp)
					table.insert(state.enemies, e)
				end

				-- Ensure impassable red wall is active
				state.exitWall.CanCollide = true
				state.exitWall.Color = Color3.fromRGB(240, 50, 50)
				state.exitWall.Transparency = 0.5
				state.exitText.Text = 'Defeat the enemies!'
				state.exitText.TextColor3 = Color3.fromRGB(255, 60, 60)
			end

			-- 1. Enemy AI: Chase and Attack Players
			if #state.enemies > 0 and not state.isCleared and #playersInRoom > 0 then
				for _, e in state.enemies do
					if e.rootPart and e.humanoid and e.humanoid.Health > 0 then
						-- Find closest player in this room
						local nearestPlr: Player? = nil
						local nearestDist = math.huge
						local nearestHrp: BasePart? = nil

						for _, plr in playersInRoom do
							local char = plr.Character
							local pHrp = char and char:FindFirstChild('HumanoidRootPart') :: BasePart?
							if pHrp then
								local d = (pHrp.Position - e.rootPart.Position).Magnitude
								if d < nearestDist then
									nearestDist = d
									nearestPlr = plr
									nearestHrp = pHrp
								end
							end
						end

						-- Chase player
						if nearestHrp then
							e.humanoid:MoveTo(nearestHrp.Position)

							-- Attack in melee range (<= 6 studs)
							if nearestDist <= 6.0 and (os.clock() - e.lastAttackTime >= 1.2) then
								e.lastAttackTime = os.clock()

								-- Punch arm swing
								if e.rightShoulder then
									local shoulder = e.rightShoulder
									task.spawn(function()
										shoulder.C0 = CFrame.new(1.8, 0, 0.4) * CFrame.Angles(math.rad(75), math.rad(-20), 0)
										task.wait(0.2)
										if shoulder and shoulder.Parent then
											shoulder.C0 = CFrame.new(1.8, 0, 0.4)
										end
									end)
								end

								-- Damage player
								if nearestPlr and nearestPlr.Character then
									local pHum = nearestPlr.Character:FindFirstChildOfClass('Humanoid')
									if pHum and pHum.Health > 0 then
										pHum:TakeDamage(5)
									end
								end
							end
						end
					end
				end

				-- 2. Players Auto-Attack Enemies & Gain Infamy / Level XP
				local data = getDataManager()
				local pwrEngine = (_G :: any).VillainsPower or (shared :: any).VillainsPower

				for _, plr in playersInRoom do
					local pChar = plr.Character
					local pHrp = pChar and pChar:FindFirstChild('HumanoidRootPart') :: BasePart?
					if not pHrp then continue end

					local target = state.enemies[1]
					if target and target.currentHp > 0 then
						local mult = (pwrEngine and pwrEngine.ComputeMultiplierStack and pwrEngine.ComputeMultiplierStack(plr)) or 1
						local dmg = math.max(1, mult)

						target.currentHp = math.max(0, target.currentHp - dmg)
						local ratio = math.clamp(target.currentHp / target.maxHp, 0, 1)
						target.fillFrame.Size = UDim2.fromScale(ratio, 1)
						target.hpLabel.Text = string.format('%s/%s', Format.abbreviate(target.currentHp), Format.abbreviate(target.maxHp))

						-- Award Infamy to Player (Directly feeds Level XP bar!)
						if data then
							local combatGain = math.max(1, math.floor(mult * 1.5))
							data.AddInfamy(plr, combatGain)
						end

						-- Visual hit spark on enemy
						local spark = Instance.new('Part')
						spark.Size = Vector3.new(0.8, 0.8, 0.8)
						spark.Position = target.rootPart.Position + Vector3.new(math.random(-1, 1), math.random(0, 2), math.random(-1, 1))
						spark.Color = Color3.fromRGB(255, 100, 30)
						spark.Material = Enum.Material.Neon
						spark.CanCollide = false
						spark.Anchored = true
						spark.Parent = Workspace
						task.delay(0.15, function() spark:Destroy() end)
					end
				end

				-- Clean up dead enemies
				for i = #state.enemies, 1, -1 do
					local e = state.enemies[i]
					if e.currentHp <= 0 then
						if e.model then e.model:Destroy() end
						table.remove(state.enemies, i)
					end
				end

				-- Stage Cleared Check
				if #state.enemies == 0 then
					state.isCleared = true
					state.clearedTime = os.clock()

					state.exitWall.CanCollide = false
					state.exitWall.Color = Color3.fromRGB(80, 220, 255)
					state.exitWall.Transparency = 0.8

					local nextCfg = Config.Jobs[1][stageIdx + 1]
					if nextCfg then
						state.exitText.Text = string.format('Stage %d\nRecommended\nPower: %s', stageIdx + 1, Format.abbreviate(nextCfg.requiredInfamy))
						state.exitText.TextColor3 = Color3.fromRGB(80, 220, 255)
					else
						state.exitText.Text = 'District 1 Cleared!'
						state.exitText.TextColor3 = Color3.fromRGB(80, 255, 120)
					end

					for _, plr in playersInRoom do
						noticeEv:FireClient(plr, {
							text = 'STAGE ' .. tostring(stageIdx) .. ' CLEARED!',
							color = Color3.fromRGB(80, 255, 120),
						})
					end
				end
			end
		end
	end
end)

local DungeonManager = {}

function DungeonManager.OnPlayerPunch(player: Player)
	local char = player.Character
	local root = char and char:FindFirstChild('HumanoidRootPart') :: BasePart?
	if not root then return end
	local pos = root.Position

	for stageIdx = 1, 15 do
		local state = stageStates[stageIdx]
		if not state or state.isCleared or #state.enemies == 0 then continue end
		local zEntrance = START_Z - ((stageIdx - 1) * ROOM_LENGTH)
		local zExit = zEntrance - ROOM_LENGTH
		if math.abs(pos.X) <= (ROOM_WIDTH / 2) and pos.Z <= zEntrance and pos.Z >= zExit then
			local nearestEnemy: EnemyData? = nil
			local minDist = 20
			for _, e in state.enemies do
				local d = (e.rootPart.Position - pos).Magnitude
				if d < minDist then
					minDist = d
					nearestEnemy = e
				end
			end

			if nearestEnemy and nearestEnemy.currentHp > 0 then
				local pwrEngine = (_G :: any).VillainsPower or (shared :: any).VillainsPower
				local mult = (pwrEngine and pwrEngine.ComputeMultiplierStack and pwrEngine.ComputeMultiplierStack(player)) or 1
				local critDmg = math.max(1, mult * 2)

				nearestEnemy.currentHp = math.max(0, nearestEnemy.currentHp - critDmg)
				local ratio = math.clamp(nearestEnemy.currentHp / nearestEnemy.maxHp, 0, 1)
				nearestEnemy.fillFrame.Size = UDim2.fromScale(ratio, 1)
				nearestEnemy.hpLabel.Text = string.format('%s/%s', Format.abbreviate(nearestEnemy.currentHp), Format.abbreviate(nearestEnemy.maxHp))

				local data = getDataManager()
				if data then
					data.AddInfamy(player, mult)
				end

				noticeEv:FireClient(player, {
					text = string.format('DIRECT HIT! -%s HP 💥', Format.abbreviate(critDmg)),
					color = Color3.fromRGB(255, 80, 80),
				})

				if nearestEnemy.currentHp <= 0 then
					for i, e in state.enemies do
						if e == nearestEnemy then
							if e.model then e.model:Destroy() end
							table.remove(state.enemies, i)
							break
						end
					end
				end
			end
			break
		end
	end
end

;(_G :: any).VillainsDungeon = DungeonManager
;(shared :: any).VillainsDungeon = DungeonManager

print('✓ Villains Evolved Seamless Physical Stages initialized.')
