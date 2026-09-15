--!strict
-- Authentic UI for Villains Evolved (Matched directly to Reference Game Screenshots)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local dataEv = remotes:WaitForChild("DataUpdate") :: RemoteEvent
local timerEv = remotes:WaitForChild("TimerUpdate") :: RemoteEvent
local trainEv = remotes:WaitForChild("Train") :: RemoteEvent
local requestRebirthFn = remotes:WaitForChild("RequestRebirth") :: RemoteFunction
local redeemCodeFn = remotes:WaitForChild("RedeemCode") :: RemoteFunction
local buyVillainFn = remotes:WaitForChild("BuyVillain") :: RemoteFunction
local equipVillainEv = remotes:WaitForChild("EquipVillain") :: RemoteEvent

local localPlayerData: any = nil

local pGui = player:WaitForChild("PlayerGui")
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "VillainsEvolvedHUD"
mainGui.ResetOnSpawn = false
mainGui.Parent = pGui

-- Helper UI builders
local function makeCorner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function makeStroke(parent: Instance, color: Color3, thickness: number)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Parent = parent
	return s
end

-- ========================================================
-- 1. TOP TIMERS (Screenshot 1: Next Thanos Boss & Next Raid)
-- ========================================================
local topTimerContainer = Instance.new("Frame")
topTimerContainer.Name = "TopTimers"
topTimerContainer.Size = UDim2.fromScale(0.45, 0.08)
topTimerContainer.Position = UDim2.fromScale(0.275, 0.015)
topTimerContainer.BackgroundTransparency = 1
topTimerContainer.Parent = mainGui

-- Hero Raid / Thanos Timer
local heroTimerRow = Instance.new("Frame")
heroTimerRow.Size = UDim2.fromScale(1, 0.48)
heroTimerRow.BackgroundTransparency = 1
heroTimerRow.Parent = topTimerContainer

local heroTimerLabel = Instance.new("TextLabel")
heroTimerLabel.Size = UDim2.fromScale(0.8, 1)
heroTimerLabel.BackgroundTransparency = 1
heroTimerLabel.Text = "Next HERO RAID in: 10:00"
heroTimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
heroTimerLabel.Font = Enum.Font.GothamBold
heroTimerLabel.TextScaled = true
heroTimerLabel.Parent = heroTimerRow

local heroSkipBtn = Instance.new("TextButton")
heroSkipBtn.Size = UDim2.fromScale(0.18, 0.9)
heroSkipBtn.Position = UDim2.fromScale(0.82, 0.05)
heroSkipBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 220)
heroSkipBtn.Text = "SKIP"
heroSkipBtn.TextColor3 = Color3.new(1, 1, 1)
heroSkipBtn.Font = Enum.Font.GothamBold
heroSkipBtn.TextScaled = true
heroSkipBtn.Parent = heroTimerRow
makeCorner(heroSkipBtn, 4)

-- Hourly Big Score Raid Timer
local raidTimerRow = Instance.new("Frame")
raidTimerRow.Size = UDim2.fromScale(1, 0.48)
raidTimerRow.Position = UDim2.fromScale(0, 0.52)
raidTimerRow.BackgroundTransparency = 1
raidTimerRow.Parent = topTimerContainer

local raidTimerLabel = Instance.new("TextLabel")
raidTimerLabel.Size = UDim2.fromScale(0.8, 1)
raidTimerLabel.BackgroundTransparency = 1
raidTimerLabel.Text = "Next RAID in: --:--"
raidTimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
raidTimerLabel.Font = Enum.Font.GothamBold
raidTimerLabel.TextScaled = true
raidTimerLabel.Parent = raidTimerRow

local raidSkipBtn = Instance.new("TextButton")
raidSkipBtn.Size = UDim2.fromScale(0.18, 0.9)
raidSkipBtn.Position = UDim2.fromScale(0.82, 0.05)
raidSkipBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 220)
raidSkipBtn.Text = "SKIP"
raidSkipBtn.TextColor3 = Color3.new(1, 1, 1)
raidSkipBtn.Font = Enum.Font.GothamBold
raidSkipBtn.TextScaled = true
raidSkipBtn.Parent = raidTimerRow
makeCorner(raidSkipBtn, 4)

-- Top Right: Playtime Reward
local playtimeBtn = Instance.new("ImageButton")
playtimeBtn.Name = "PlaytimeReward"
playtimeBtn.Size = UDim2.fromScale(0.06, 0.1)
playtimeBtn.Position = UDim2.fromScale(0.75, 0.015)
playtimeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
playtimeBtn.Parent = mainGui
makeCorner(playtimeBtn, 8)
makeStroke(playtimeBtn, Color3.fromRGB(255, 220, 100), 2)

local playLabel = Instance.new("TextLabel")
playLabel.Size = UDim2.fromScale(1, 0.4)
playLabel.Position = UDim2.fromScale(0, 1.05)
playLabel.BackgroundTransparency = 1
playLabel.Text = "PLAYTIME\nREWARD"
playLabel.TextColor3 = Color3.new(1, 1, 1)
playLabel.Font = Enum.Font.GothamBold
playLabel.TextScaled = true
playLabel.Parent = playtimeBtn

-- ========================================================
-- 2. LEFT RAIL (Store, World, Rebirth %, Pets, Heros, Items)
-- ========================================================
local leftRail = Instance.new("Frame")
leftRail.Name = "LeftRail"
leftRail.Size = UDim2.fromScale(0.06, 0.55)
leftRail.Position = UDim2.fromScale(0.015, 0.22)
leftRail.BackgroundTransparency = 1
leftRail.Parent = mainGui

local railLayout = Instance.new("UIListLayout")
railLayout.FillDirection = Enum.FillDirection.Vertical
railLayout.Padding = UDim.new(0, 8)
railLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
railLayout.Parent = leftRail

-- Modals forward declarations
local toggleBackpack: (tab: string) -> ()
local toggleRebirthModal: () -> ()

local function makeRailButton(name: string, label: string, color: Color3, badgeText: string?, onClick: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.fromScale(0.9, 0.14)
	btn.BackgroundColor3 = color
	btn.Text = ""
	btn.Parent = leftRail
	makeCorner(btn, 8)
	makeStroke(btn, Color3.fromRGB(30, 30, 30), 2)

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.fromScale(1, 0.9)
	txt.BackgroundTransparency = 1
	txt.Text = label
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.Font = Enum.Font.GothamBold
	txt.TextScaled = true
	txt.Parent = btn

	if badgeText then
		local badge = Instance.new("TextLabel")
		badge.Name = "Badge"
		badge.Size = UDim2.fromScale(0.55, 0.35)
		badge.Position = UDim2.fromScale(0.55, -0.15)
		badge.BackgroundColor3 = Color3.fromRGB(240, 40, 40)
		badge.Text = badgeText
		badge.TextColor3 = Color3.new(1, 1, 1)
		badge.Font = Enum.Font.GothamBold
		badge.TextScaled = true
		badge.Parent = btn
		makeCorner(badge, 4)
	end

	btn.MouseButton1Click:Connect(onClick)
	return btn
end

makeRailButton("StoreBtn", "🛒\nStore", Color3.fromRGB(240, 140, 20), nil, function()
	toggleBackpack("Boosts")
end)

makeRailButton("WorldBtn", "🌍\nWorld", Color3.fromRGB(60, 180, 220), nil, function()
	-- Teleport / world quick menu
end)

local rebirthRailBtn = makeRailButton("RebirthRailBtn", "🔄\nRebirth", Color3.fromRGB(240, 40, 70), "0%", function()
	toggleRebirthModal()
end)

makeRailButton("PetsBtn", "🐾\nPets", Color3.fromRGB(180, 90, 40), nil, function()
	toggleBackpack("Pets")
end)

makeRailButton("HerosBtn", "🎭\nVillains", Color3.fromRGB(220, 30, 30), nil, function()
	toggleBackpack("Heros")
end)

makeRailButton("ItemsBtn", "🎒\nItems", Color3.fromRGB(200, 50, 40), nil, function()
	toggleBackpack("Items")
end)

-- ========================================================
-- 3. BOTTOM LEFT STAT PILLAR (Rebirths, Heat, Wins/Loot)
-- ========================================================
local statPillar = Instance.new("Frame")
statPillar.Name = "StatPillar"
statPillar.Size = UDim2.fromScale(0.18, 0.16)
statPillar.Position = UDim2.fromScale(0.015, 0.81)
statPillar.BackgroundTransparency = 1
statPillar.Parent = mainGui

local function makeStatRow(name: string, iconStr: string, textColor: Color3, yPos: number): TextLabel
	local row = Instance.new("Frame")
	row.Size = UDim2.fromScale(1, 0.28)
	row.Position = UDim2.fromScale(0, yPos)
	row.BackgroundTransparency = 1
	row.Parent = statPillar

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromScale(0.2, 1)
	icon.BackgroundTransparency = 1
	icon.Text = iconStr
	icon.TextColor3 = textColor
	icon.Font = Enum.Font.GothamBold
	icon.TextScaled = true
	icon.Parent = row

	local val = Instance.new("TextLabel")
	val.Name = "Value"
	val.Size = UDim2.fromScale(0.8, 1)
	val.Position = UDim2.fromScale(0.22, 0)
	val.BackgroundTransparency = 1
	val.Text = "0"
	val.TextColor3 = textColor
	val.Font = Enum.Font.GothamBold
	val.TextXAlignment = Enum.TextXAlignment.Left
	val.TextScaled = true
	val.Parent = row
	makeStroke(val, Color3.new(0, 0, 0), 2)
	return val
end

local rebirthValLabel = makeStatRow("Rebirths", "🔄", Color3.fromRGB(255, 100, 100), 0)
local heatValLabel = makeStatRow("Heat", "⚔️", Color3.fromRGB(255, 60, 60), 0.32)
local lootValLabel = makeStatRow("Loot", "🏆", Color3.fromRGB(255, 215, 0), 0.64)

-- ========================================================
-- 4. BOTTOM CENTER POWER & LEVEL BAR (Screenshot 1)
-- ========================================================
local powerCenter = Instance.new("Frame")
powerCenter.Name = "PowerCenter"
powerCenter.Size = UDim2.fromScale(0.36, 0.18)
powerCenter.Position = UDim2.fromScale(0.32, 0.80)
powerCenter.BackgroundTransparency = 1
powerCenter.Parent = mainGui

-- Big Bicep Infamy counter
local infamyBigLabel = Instance.new("TextLabel")
infamyBigLabel.Size = UDim2.fromScale(1, 0.35)
infamyBigLabel.BackgroundTransparency = 1
infamyBigLabel.Text = "💪 1"
infamyBigLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
infamyBigLabel.Font = Enum.Font.GothamBold
infamyBigLabel.TextScaled = true
infamyBigLabel.Parent = powerCenter
makeStroke(infamyBigLabel, Color3.new(0, 0, 0), 2)

-- Multiplier readout
local multLabel = Instance.new("TextLabel")
multLabel.Size = UDim2.fromScale(0.6, 0.18)
multLabel.Position = UDim2.fromScale(0.01, 0.36)
multLabel.BackgroundTransparency = 1
multLabel.Text = "Multiplier: 1x"
multLabel.TextColor3 = Color3.new(1, 1, 1)
multLabel.Font = Enum.Font.GothamBold
multLabel.TextScaled = true
multLabel.TextXAlignment = Enum.TextXAlignment.Left
multLabel.Parent = powerCenter

-- Level Bar
local levelBarFrame = Instance.new("Frame")
levelBarFrame.Size = UDim2.fromScale(1, 0.22)
levelBarFrame.Position = UDim2.fromScale(0, 0.55)
levelBarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
levelBarFrame.Parent = powerCenter
makeCorner(levelBarFrame, 4)
makeStroke(levelBarFrame, Color3.fromRGB(40, 40, 40), 2)

local levelBarFill = Instance.new("Frame")
levelBarFill.Size = UDim2.fromScale(0.1, 1)
levelBarFill.BackgroundColor3 = Color3.fromRGB(240, 80, 20)
levelBarFill.BorderSizePixel = 0
levelBarFill.Parent = levelBarFrame
makeCorner(levelBarFill, 4)

local levelBarText = Instance.new("TextLabel")
levelBarText.Size = UDim2.fromScale(1, 0.9)
levelBarText.BackgroundTransparency = 1
levelBarText.Text = "Level 1 / 10"
levelBarText.TextColor3 = Color3.new(1, 1, 1)
levelBarText.Font = Enum.Font.GothamBold
levelBarText.TextScaled = true
levelBarText.Parent = levelBarFrame

-- Tap to train zone
local tapZone = Instance.new("TextButton")
tapZone.Size = UDim2.fromScale(1, 0.2)
tapZone.Position = UDim2.fromScale(0, 0.8)
tapZone.BackgroundColor3 = Color3.fromRGB(150, 40, 200)
tapZone.Text = "TAP TO TRAIN INFAMY"
tapZone.TextColor3 = Color3.new(1, 1, 1)
tapZone.Font = Enum.Font.GothamBold
tapZone.TextScaled = true
tapZone.Parent = powerCenter
makeCorner(tapZone, 6)

tapZone.MouseButton1Click:Connect(function()
	trainEv:FireServer({ count = 1 })
end)

-- ========================================================
-- 5. REBIRTH MODAL (Screenshot 2: Rebirth resets power/level)
-- ========================================================
local rebirthModal = Instance.new("Frame")
rebirthModal.Name = "RebirthModal"
rebirthModal.Size = UDim2.fromScale(0.42, 0.52)
rebirthModal.Position = UDim2.fromScale(0.29, 0.22)
rebirthModal.BackgroundColor3 = Color3.fromRGB(180, 225, 255)
rebirthModal.Visible = false
rebirthModal.Parent = mainGui
makeCorner(rebirthModal, 8)
makeStroke(rebirthModal, Color3.fromRGB(30, 30, 30), 4)

-- Title
local rHeader = Instance.new("Frame")
rHeader.Size = UDim2.fromScale(1, 0.16)
rHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rHeader.Parent = rebirthModal
makeCorner(rHeader, 8)

local rTitle = Instance.new("TextLabel")
rTitle.Size = UDim2.fromScale(0.8, 0.8)
rTitle.Position = UDim2.fromScale(0.1, 0.1)
rTitle.BackgroundTransparency = 1
rTitle.Text = "🔄 Rebirth"
rTitle.TextColor3 = Color3.fromRGB(30, 30, 30)
rTitle.Font = Enum.Font.GothamBold
rTitle.TextScaled = true
rTitle.Parent = rHeader

local rClose = Instance.new("TextButton")
rClose.Size = UDim2.fromScale(0.08, 0.7)
rClose.Position = UDim2.fromScale(0.9, 0.15)
rClose.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
rClose.Text = "X"
rClose.TextColor3 = Color3.new(1, 1, 1)
rClose.Font = Enum.Font.GothamBold
rClose.TextScaled = true
rClose.Parent = rHeader
makeCorner(rClose, 4)
rClose.MouseButton1Click:Connect(function() rebirthModal.Visible = false end)

-- Comparison cards: Current Rebirth -> Next Rebirth
local cardCur = Instance.new("Frame")
cardCur.Size = UDim2.fromScale(0.42, 0.25)
cardCur.Position = UDim2.fromScale(0.05, 0.22)
cardCur.BackgroundColor3 = Color3.fromRGB(70, 200, 240)
cardCur.Parent = rebirthModal
makeCorner(cardCur, 6)
makeStroke(cardCur, Color3.fromRGB(30, 30, 30), 2)

local curRebirthLabel = Instance.new("TextLabel")
curRebirthLabel.Size = UDim2.fromScale(1, 0.4)
curRebirthLabel.BackgroundTransparency = 1
curRebirthLabel.Text = "Rebirth 0"
curRebirthLabel.TextColor3 = Color3.new(0, 0, 0)
curRebirthLabel.Font = Enum.Font.GothamBold
curRebirthLabel.TextScaled = true
curRebirthLabel.Parent = cardCur

local curMultLabel = Instance.new("TextLabel")
curMultLabel.Size = UDim2.fromScale(1, 0.5)
curMultLabel.Position = UDim2.fromScale(0, 0.45)
curMultLabel.BackgroundTransparency = 1
curMultLabel.Text = "💪 1x"
curMultLabel.TextColor3 = Color3.new(0, 0, 0)
curMultLabel.Font = Enum.Font.GothamBold
curMultLabel.TextScaled = true
curMultLabel.Parent = cardCur

local cardNext = Instance.new("Frame")
cardNext.Size = UDim2.fromScale(0.42, 0.25)
cardNext.Position = UDim2.fromScale(0.53, 0.22)
cardNext.BackgroundColor3 = Color3.fromRGB(70, 200, 240)
cardNext.Parent = rebirthModal
makeCorner(cardNext, 6)
makeStroke(cardNext, Color3.fromRGB(30, 30, 30), 2)

local nextRebirthLabel = Instance.new("TextLabel")
nextRebirthLabel.Size = UDim2.fromScale(1, 0.4)
nextRebirthLabel.BackgroundTransparency = 1
nextRebirthLabel.Text = "Rebirth 1"
nextRebirthLabel.TextColor3 = Color3.new(0, 0, 0)
nextRebirthLabel.Font = Enum.Font.GothamBold
nextRebirthLabel.TextScaled = true
nextRebirthLabel.Parent = cardNext

local nextMultLabel = Instance.new("TextLabel")
nextMultLabel.Size = UDim2.fromScale(1, 0.5)
nextMultLabel.Position = UDim2.fromScale(0, 0.45)
nextMultLabel.BackgroundTransparency = 1
nextMultLabel.Text = "💪 3x"
nextMultLabel.TextColor3 = Color3.new(0, 0, 0)
nextMultLabel.Font = Enum.Font.GothamBold
nextMultLabel.TextScaled = true
nextMultLabel.Parent = cardNext

-- Red Warning Text
local warnLabel = Instance.new("TextLabel")
warnLabel.Size = UDim2.fromScale(0.9, 0.08)
warnLabel.Position = UDim2.fromScale(0.05, 0.5)
warnLabel.BackgroundTransparency = 1
warnLabel.Text = "Rebirth resets your power and level"
warnLabel.TextColor3 = Color3.fromRGB(240, 20, 20)
warnLabel.Font = Enum.Font.GothamBold
warnLabel.TextScaled = true
warnLabel.Parent = rebirthModal

-- XP Progress Bar inside Rebirth
local rBarFrame = Instance.new("Frame")
rBarFrame.Size = UDim2.fromScale(0.9, 0.14)
rBarFrame.Position = UDim2.fromScale(0.05, 0.6)
rBarFrame.BackgroundColor3 = Color3.fromRGB(50, 180, 200)
rBarFrame.Parent = rebirthModal
makeCorner(rBarFrame, 4)
makeStroke(rBarFrame, Color3.fromRGB(30, 30, 30), 2)

local rBarFill = Instance.new("Frame")
rBarFill.Name = "Fill"
rBarFill.Size = UDim2.fromScale(0.1, 1)
rBarFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
rBarFill.BorderSizePixel = 0
rBarFill.Parent = rBarFrame
makeCorner(rBarFill, 4)

local rBarText = Instance.new("TextLabel")
rBarText.Size = UDim2.fromScale(1, 0.9)
rBarText.BackgroundTransparency = 1
rBarText.Text = "Level 1 / 10"
rBarText.TextColor3 = Color3.new(0, 0, 0)
rBarText.Font = Enum.Font.GothamBold
rBarText.TextScaled = true
rBarText.ZIndex = 2
rBarText.Parent = rBarFrame

-- Buttons: Free Rebirth & Skip Rebirth
local doRebirthBtn = Instance.new("TextButton")
doRebirthBtn.Size = UDim2.fromScale(0.42, 0.16)
doRebirthBtn.Position = UDim2.fromScale(0.05, 0.78)
doRebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
doRebirthBtn.Text = "🔄 Rebirth"
doRebirthBtn.TextColor3 = Color3.new(0, 0, 0)
doRebirthBtn.Font = Enum.Font.GothamBold
doRebirthBtn.TextScaled = true
doRebirthBtn.Parent = rebirthModal
makeCorner(doRebirthBtn, 6)
makeStroke(doRebirthBtn, Color3.fromRGB(30, 30, 30), 2)

local skipRebirthBtn = Instance.new("TextButton")
skipRebirthBtn.Size = UDim2.fromScale(0.42, 0.16)
skipRebirthBtn.Position = UDim2.fromScale(0.53, 0.78)
skipRebirthBtn.BackgroundColor3 = Color3.fromRGB(120, 220, 240)
skipRebirthBtn.Text = "Skip Rebirth (19 R$)"
skipRebirthBtn.TextColor3 = Color3.new(0, 0, 0)
skipRebirthBtn.Font = Enum.Font.GothamBold
skipRebirthBtn.TextScaled = true
skipRebirthBtn.Parent = rebirthModal
makeCorner(skipRebirthBtn, 6)
makeStroke(skipRebirthBtn, Color3.fromRGB(30, 30, 30), 2)

doRebirthBtn.MouseButton1Click:Connect(function()
	local ok, res = pcall(function()
		return requestRebirthFn:InvokeServer()
	end)
	if ok and res and res.success then
		rebirthModal.Visible = false
	end
end)

toggleRebirthModal = function()
	rebirthModal.Visible = not rebirthModal.Visible
end

-- ========================================================
-- 6. TABBED BACKPACK MODAL (Screenshots 3, 4, 5: Heros, Pets, Items)
-- ========================================================
local backpackModal = Instance.new("Frame")
backpackModal.Name = "BackpackModal"
backpackModal.Size = UDim2.fromScale(0.58, 0.62)
backpackModal.Position = UDim2.fromScale(0.24, 0.18)
backpackModal.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
backpackModal.Visible = false
backpackModal.Parent = mainGui
makeCorner(backpackModal, 8)
makeStroke(backpackModal, Color3.fromRGB(20, 20, 25), 4)

-- Left Tab Rail inside Backpack
local tabRail = Instance.new("Frame")
tabRail.Name = "TabRail"
tabRail.Size = UDim2.fromScale(0.18, 1)
tabRail.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
tabRail.Parent = backpackModal
makeCorner(tabRail, 8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Vertical
tabLayout.Padding = UDim.new(0, 6)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Parent = tabRail

local tabTitle = Instance.new("TextLabel")
tabTitle.Size = UDim2.fromScale(0.7, 0.1)
tabTitle.Position = UDim2.fromScale(0.22, 0.02)
tabTitle.BackgroundTransparency = 1
tabTitle.Text = "Heros"
tabTitle.TextColor3 = Color3.new(1, 1, 1)
tabTitle.Font = Enum.Font.GothamBold
tabTitle.TextScaled = true
tabTitle.TextXAlignment = Enum.TextXAlignment.Left
tabTitle.Parent = backpackModal

local closeBackpack = Instance.new("TextButton")
closeBackpack.Size = UDim2.fromScale(0.06, 0.08)
closeBackpack.Position = UDim2.fromScale(0.92, 0.02)
closeBackpack.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBackpack.Text = "X"
closeBackpack.TextColor3 = Color3.new(1, 1, 1)
closeBackpack.Font = Enum.Font.GothamBold
closeBackpack.TextScaled = true
closeBackpack.Parent = backpackModal
makeCorner(closeBackpack, 4)
closeBackpack.MouseButton1Click:Connect(function() backpackModal.Visible = false end)

-- Content Scroll Area
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.fromScale(0.78, 0.84)
contentScroll.Position = UDim2.fromScale(0.20, 0.12)
contentScroll.BackgroundTransparency = 1
contentScroll.ScrollBarThickness = 6
contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.Parent = backpackModal

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 85, 0, 110)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.Parent = contentScroll

local currentTab = "Heros"

local function renderTabContent(tab: string)
	currentTab = tab
	tabTitle.Text = tab

	for _, child in contentScroll:GetChildren() do
		if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") and not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	local p = localPlayerData

	if tab == "Heros" then
		for _, v in Config.Villains do
			if v.district == 1 then
				local card = Instance.new("Frame")
				card.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
				card.Parent = contentScroll
				makeCorner(card, 6)

				local name = Instance.new("TextLabel")
				name.Size = UDim2.fromScale(1, 0.3)
				name.BackgroundTransparency = 1
				name.Text = v.name
				name.TextColor3 = Color3.new(1, 1, 1)
				name.Font = Enum.Font.GothamBold
				name.TextScaled = true
				name.Parent = card

				local power = Instance.new("TextLabel")
				power.Size = UDim2.fromScale(1, 0.3)
				power.Position = UDim2.fromScale(0, 0.32)
				power.BackgroundTransparency = 1
				power.Text = Format.abbreviate(v.infamyPerClick)
				power.TextColor3 = Color3.fromRGB(255, 215, 0)
				power.Font = Enum.Font.GothamBold
				power.TextScaled = true
				power.Parent = card

				local isEquipped = p and (p.EquippedVillain == v.id)
				local isOwned = p and p.OwnedVillains and (p.OwnedVillains[v.id] == true or v.cost == 0)

				if isEquipped then
					local chk = Instance.new("TextLabel")
					chk.Size = UDim2.fromScale(0.35, 0.35)
					chk.Position = UDim2.fromScale(0.325, 0.62)
					chk.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
					chk.Text = "✔"
					chk.TextColor3 = Color3.new(1, 1, 1)
					chk.Font = Enum.Font.GothamBold
					chk.TextScaled = true
					chk.Parent = card
					makeCorner(chk, 100)
				else
					local btn = Instance.new("TextButton")
					btn.Size = UDim2.fromScale(0.85, 0.28)
					btn.Position = UDim2.fromScale(0.075, 0.65)
					btn.BackgroundColor3 = isOwned and Color3.fromRGB(40, 140, 220) or Color3.fromRGB(240, 160, 20)
					btn.Text = isOwned and "Equip" or (v.cost == 0 and "Free" or (Format.abbreviate(v.cost) .. " Loot"))
					btn.TextColor3 = Color3.new(1, 1, 1)
					btn.Font = Enum.Font.GothamBold
					btn.TextScaled = true
					btn.Parent = card
					makeCorner(btn, 4)

					local targetId = v.id
					btn.MouseButton1Click:Connect(function()
						if isOwned then
							equipVillainEv:FireServer(targetId)
						else
							buyVillainFn:InvokeServer(targetId)
						end
						task.wait(0.2)
						renderTabContent("Heros")
					end)
				end
			end
		end
	elseif tab == "Pets" then
		for _, h in Config.Henchmen do
			local card = Instance.new("Frame")
			card.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
			card.Parent = contentScroll
			makeCorner(card, 6)

			local name = Instance.new("TextLabel")
			name.Size = UDim2.fromScale(1, 0.35)
			name.BackgroundTransparency = 1
			name.Text = h.name
			name.TextColor3 = Color3.new(1, 1, 1)
			name.Font = Enum.Font.GothamBold
			name.TextScaled = true
			name.Parent = card

			local mult = Instance.new("TextLabel")
			mult.Size = UDim2.fromScale(1, 0.35)
			mult.Position = UDim2.fromScale(0, 0.4)
			mult.BackgroundTransparency = 1
			mult.Text = "+" .. tostring(math.floor(h.multipliers.infamy * 100)) .. "% Power"
			mult.TextColor3 = Color3.fromRGB(80, 240, 120)
			mult.Font = Enum.Font.GothamBold
			mult.TextScaled = true
			mult.Parent = card
		end
	elseif tab == "Items" then
		for _, itm in Config.Items do
			local card = Instance.new("Frame")
			card.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
			card.Parent = contentScroll
			makeCorner(card, 6)

			local name = Instance.new("TextLabel")
			name.Size = UDim2.fromScale(1, 0.4)
			name.BackgroundTransparency = 1
			name.Text = itm.name
			name.TextColor3 = Color3.new(1, 1, 1)
			name.Font = Enum.Font.GothamBold
			name.TextScaled = true
			name.Parent = card

			local pwr = Instance.new("TextLabel")
			pwr.Size = UDim2.fromScale(1, 0.4)
			pwr.Position = UDim2.fromScale(0, 0.45)
			pwr.BackgroundTransparency = 1
			pwr.Text = "+" .. Format.abbreviate(itm.power) .. " Power"
			pwr.TextColor3 = Color3.fromRGB(255, 200, 40)
			pwr.Font = Enum.Font.GothamBold
			pwr.TextScaled = true
			pwr.Parent = card
		end
	elseif tab == "Eggs" then
		local titleSub = Instance.new("TextLabel")
		titleSub.Size = UDim2.fromScale(1, 0.15)
		titleSub.BackgroundTransparency = 1
		titleSub.Text = "Exclusive Eggs"
		titleSub.TextColor3 = Color3.fromRGB(240, 240, 255)
		titleSub.Font = Enum.Font.GothamBold
		titleSub.TextScaled = true
		titleSub.Parent = contentScroll

		local eggSamples = {
			{ name = "Burger Egg", count = "x1", color = Color3.fromRGB(230, 200, 60), mult = "+250% Power" },
			{ name = "Gentleman Egg", count = "x1", color = Color3.fromRGB(240, 240, 245), mult = "+500% Power" },
			{ name = "Cactus Spiky Egg", count = "x2", color = Color3.fromRGB(80, 220, 90), mult = "+1,000% Power" },
		}

		for _, e in eggSamples do
			local card = Instance.new("Frame")
			card.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
			card.Parent = contentScroll
			makeCorner(card, 6)

			local cLabel = Instance.new("TextLabel")
			cLabel.Size = UDim2.fromScale(0.4, 0.3)
			cLabel.Position = UDim2.fromScale(0.6, 0.05)
			cLabel.BackgroundTransparency = 1
			cLabel.Text = e.count
			cLabel.TextColor3 = Color3.new(1, 1, 1)
			cLabel.Font = Enum.Font.GothamBold
			cLabel.TextScaled = true
			cLabel.Parent = card

			local eIcon = Instance.new("Frame")
			eIcon.Size = UDim2.fromScale(0.45, 0.45)
			eIcon.Position = UDim2.fromScale(0.275, 0.15)
			eIcon.BackgroundColor3 = e.color
			eIcon.Parent = card
			makeCorner(eIcon, 100)

			local nLabel = Instance.new("TextLabel")
			nLabel.Size = UDim2.fromScale(1, 0.25)
			nLabel.Position = UDim2.fromScale(0, 0.62)
			nLabel.BackgroundTransparency = 1
			nLabel.Text = e.name
			nLabel.TextColor3 = Color3.new(1, 1, 1)
			nLabel.Font = Enum.Font.GothamBold
			nLabel.TextScaled = true
			nLabel.Parent = card

			local mLabel = Instance.new("TextLabel")
			mLabel.Size = UDim2.fromScale(1, 0.2)
			mLabel.Position = UDim2.fromScale(0, 0.82)
			mLabel.BackgroundTransparency = 1
			mLabel.Text = e.mult
			mLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
			mLabel.Font = Enum.Font.GothamBold
			mLabel.TextScaled = true
			mLabel.Parent = card
		end
	elseif tab == "Boosts" then
		local titleSub = Instance.new("TextLabel")
		titleSub.Size = UDim2.fromScale(1, 0.15)
		titleSub.BackgroundTransparency = 1
		titleSub.Text = "Consumable Boosts"
		titleSub.TextColor3 = Color3.fromRGB(240, 240, 255)
		titleSub.Font = Enum.Font.GothamBold
		titleSub.TextScaled = true
		titleSub.Parent = contentScroll

		local boostSamples = {
			{ name = "Heat Potion", count = "x2", color = Color3.fromRGB(255, 80, 140) },
			{ name = "Luck Potion", count = "x1", color = Color3.fromRGB(80, 240, 120) },
			{ name = "Infamy Potion", count = "x1", color = Color3.fromRGB(255, 220, 60) },
			{ name = "Raid Medals", count = "x3", color = Color3.fromRGB(220, 40, 50) },
		}

		for _, b in boostSamples do
			local card = Instance.new("Frame")
			card.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
			card.Parent = contentScroll
			makeCorner(card, 6)

			local cLabel = Instance.new("TextLabel")
			cLabel.Size = UDim2.fromScale(0.4, 0.3)
			cLabel.Position = UDim2.fromScale(0.6, 0.05)
			cLabel.BackgroundTransparency = 1
			cLabel.Text = b.count
			cLabel.TextColor3 = Color3.new(1, 1, 1)
			cLabel.Font = Enum.Font.GothamBold
			cLabel.TextScaled = true
			cLabel.Parent = card

			local bIcon = Instance.new("Frame")
			bIcon.Size = UDim2.fromScale(0.45, 0.45)
			bIcon.Position = UDim2.fromScale(0.275, 0.15)
			bIcon.BackgroundColor3 = b.color
			bIcon.Parent = card
			makeCorner(bIcon, 8)

			local nLabel = Instance.new("TextLabel")
			nLabel.Size = UDim2.fromScale(1, 0.3)
			nLabel.Position = UDim2.fromScale(0, 0.65)
			nLabel.BackgroundTransparency = 1
			nLabel.Text = b.name
			nLabel.TextColor3 = Color3.new(1, 1, 1)
			nLabel.Font = Enum.Font.GothamBold
			nLabel.TextScaled = true
			nLabel.Parent = card
		end

		-- Secret Codes Input
		local codeInput = Instance.new("TextBox")
		codeInput.Size = UDim2.fromScale(0.65, 0.22)
		codeInput.Position = UDim2.fromScale(0.05, 0.72)
		codeInput.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
		codeInput.PlaceholderText = "Enter Secret Code..."
		codeInput.Text = ""
		codeInput.TextColor3 = Color3.new(1, 1, 1)
		codeInput.Font = Enum.Font.GothamBold
		codeInput.TextScaled = true
		codeInput.Parent = contentScroll
		makeCorner(codeInput, 6)

		local redeemBtn = Instance.new("TextButton")
		redeemBtn.Size = UDim2.fromScale(0.25, 0.22)
		redeemBtn.Position = UDim2.fromScale(0.72, 0.72)
		redeemBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
		redeemBtn.Text = "REDEEM"
		redeemBtn.TextColor3 = Color3.new(1, 1, 1)
		redeemBtn.Font = Enum.Font.GothamBold
		redeemBtn.TextScaled = true
		redeemBtn.Parent = contentScroll
		makeCorner(redeemBtn, 6)

		redeemBtn.MouseButton1Click:Connect(function()
			if codeInput.Text ~= "" then
				local res = redeemCodeFn:InvokeServer(codeInput.Text)
				if res and res.message then
					codeInput.Text = ""
					codeInput.PlaceholderText = res.message
				end
			end
		end)
	end
end

local function makeTabBtn(tabName: string, iconStr: string)
	local b = Instance.new("TextButton")
	b.Name = "Tab_" .. tabName
	b.Size = UDim2.fromScale(0.9, 0.15)
	b.BackgroundColor3 = Color3.fromRGB(40, 48, 60)
	b.Text = iconStr .. "\n" .. tabName
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Parent = tabRail
	makeCorner(b, 6)
	b.MouseButton1Click:Connect(function()
		renderTabContent(tabName)
	end)
end

makeTabBtn("Heros", "🎭")
makeTabBtn("Pets", "🐾")
makeTabBtn("Items", "🎒")
makeTabBtn("Eggs", "🥚")
makeTabBtn("Boosts", "🧪")

toggleBackpack = function(tab: string)
	if backpackModal.Visible and currentTab == tab then
		backpackModal.Visible = false
	else
		backpackModal.Visible = true
		renderTabContent(tab)
	end
end

-- ========================================================
-- 7. EVENT LISTENERS
-- ========================================================
dataEv.OnClientEvent:Connect(function(d: any)
	if not d then return end
	localPlayerData = d

	infamyBigLabel.Text = "💪 " .. Format.abbreviate(d.Infamy)
	multLabel.Text = "Multiplier: " .. tostring(d.RebirthMult or 1) .. "x"
	lootValLabel.Text = Format.abbreviate(d.Loot)
	heatValLabel.Text = Format.abbreviate(d.Heat)
	rebirthValLabel.Text = tostring(d.Rebirths)

	if backpackModal.Visible and currentTab == "Heros" then
		renderTabContent("Heros")
	end

	-- Level Bar: Fills smoothly with XP points towards each level!
	local xpRatio = math.clamp((d.LevelXp or 0) / math.max(1, d.NextLevelXp or 1), 0, 1)
	local rebirthRatio = math.clamp(d.Level / math.max(1, d.ReqLevel), 0, 1)

	if d.IsMaxLevel then
		levelBarFill.Size = UDim2.fromScale(1, 1)
		levelBarText.Text = string.format("Level %d [MAX LEVEL]", d.Level)
		levelBarFill.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
		doRebirthBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
		doRebirthBtn.Text = "🔄 Rebirth [READY]"
		local badge = rebirthRailBtn:FindFirstChild("Badge") :: TextLabel?
		if badge then badge.Text = "100%" end
	else
		levelBarFill.Size = UDim2.fromScale(xpRatio, 1)
		levelBarText.Text = string.format("Level %d / %d", d.Level, d.ReqLevel)
		levelBarFill.BackgroundColor3 = Color3.fromRGB(70, 200, 80)
		doRebirthBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
		doRebirthBtn.Text = "🔄 Rebirth"
		local badge = rebirthRailBtn:FindFirstChild("Badge") :: TextLabel?
		if badge then
			badge.Text = string.format("%d%%", math.floor(rebirthRatio * 100))
		end
	end

	-- Rebirth Modal updates
	curRebirthLabel.Text = "Rebirth " .. tostring(d.Rebirths)
	curMultLabel.Text = "💪 " .. tostring(d.RebirthMult) .. "x"
	nextRebirthLabel.Text = "Rebirth " .. tostring(d.Rebirths + 1)
	nextMultLabel.Text = "💪 " .. tostring(d.NextRebirthMult) .. "x"
	rBarText.Text = string.format("Level %d / %d", d.Level, d.ReqLevel)
	rBarFill.Size = UDim2.fromScale(rebirthRatio, 1)
end)

timerEv.OnClientEvent:Connect(function(t: any)
	if not t then return end
	if t.heroRaidActive then
		heroTimerLabel.Text = "HERO RAID: ACTIVE IN PLAZA!"
		heroTimerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	else
		heroTimerLabel.Text = "Next HERO RAID in: " .. Format.timer(t.heroRaidSeconds)
		heroTimerLabel.TextColor3 = Color3.new(1, 1, 1)
	end
	raidTimerLabel.Text = "Next RAID in: " .. Format.timer(t.bigScoreSeconds)
end)

print("✓ Villains Evolved Authentic Screenshot-Grounded UI initialized.")
