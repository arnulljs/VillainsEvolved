--!strict
-- Hourly City Rampage — rewards Tokens (ponytail: reuses Dungeon arena, no new map)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local raidActive = false
local raidEndsAt = 0

local function ensureRaidBoard()
	local folder = Workspace:FindFirstChild("Dungeon")
	if not folder then return end
	local board = folder:FindFirstChild("RaidBoard")
	if not board then
		board = Instance.new("Part")
		board.Name = "RaidBoard"
		board.Size = Vector3.new(12, 8, 1)
		board.Position = Vector3.new(0, 8, 10)
		board.Anchored = true
		board.Color = Color3.fromRGB(30, 30, 30)
		board.Parent = folder
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Front
		sg.Parent = board
		local tl = Instance.new("TextLabel")
		tl.Name = "Label"
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Text = "City Rampage: waiting for XX:30"
		tl.TextScaled = true
		tl.TextColor3 = Color3.fromRGB(255, 255, 255)
		tl.Font = Enum.Font.GothamBold
		tl.Parent = sg
	end
	return board
end

local board = ensureRaidBoard()

local function getNextRaidTime(): number
	local now = os.time()
	local t = os.date("*t", now) :: any
	-- next XX:30
	local targetMin = 30
	if t.min >= 30 then
		-- next hour
		return os.time({ year = t.year, month = t.month, day = t.day, hour = t.hour + 1, min = 30, sec = 0 } :: any)
	else
		return os.time({ year = t.year, month = t.month, day = t.day, hour = t.hour, min = 30, sec = 0 } :: any)
	end
end

local nextRaid = getNextRaidTime()

local function startRaid()
	raidActive = true
	raidEndsAt = os.time() + 600 -- 10 min raid window
	if board then
		local tl = board:FindFirstChild("SurfaceGui", true) :: SurfaceGui?
		local label = tl and tl:FindFirstChild("Label") :: TextLabel?
		if label then label.Text = "CITY RAMPAGE ACTIVE — Go!" end
	end
	-- give participants Tokens for stage clears — handled via Dungeon.server adding Tokens on cashout during raid
	task.wait(600)
	raidActive = false
	nextRaid = getNextRaidTime()
end

task.spawn(function()
	while true do
		task.wait(1)
		local now = os.time()
		if not raidActive and now >= nextRaid then
			startRaid()
		end
		if board then
			local label = board:FindFirstChild("SurfaceGui", true) and board.FindFirstChild(board:FindFirstChild("SurfaceGui", true) :: Instance, "Label") :: TextLabel?
			-- fallback find
			local sg = board:FindFirstChild("SurfaceGui") :: SurfaceGui?
			local tl = sg and sg:FindFirstChild("Label") :: TextLabel?
			if tl and not raidActive then
				local remain = nextRaid - now
				local m = math.floor(remain / 60)
				local s = remain % 60
				tl.Text = string.format("City Rampage in %02d:%02d (XX:30 hourly)", m, s)
			end
		end
	end
end)

-- Expose state for Dungeon to grant Tokens during raid
(_G :: any).IsRaidActive = function(): boolean
	return raidActive
end
