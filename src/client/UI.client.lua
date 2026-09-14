--!strict
-- Minimal UI: Infamy/Heists/Tokens, villain list, henchmen, rebirth, dungeon buttons
-- ponytail: one ScreenGui, code-built, no extra assets

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local trainEv = remotes:WaitForChild("Train") :: RemoteEvent
local rebirthEv = remotes:WaitForChild("Rebirth") :: RemoteEvent
local enterEv = remotes:WaitForChild("EnterDungeon") :: RemoteEvent
local cashOutEv = remotes:WaitForChild("CashOut") :: RemoteEvent
local equipEv = remotes:WaitForChild("EquipVillain") :: RemoteEvent
local buyVillainFn = remotes:WaitForChild("BuyVillain") :: RemoteFunction
local buyHenchFn = remotes:WaitForChild("BuyHenchman") :: RemoteFunction
local dataEv = remotes:WaitForChild("DataUpdate") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "VillainsEvolvedUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeFrame(name: string, size: UDim2, pos: UDim2, parent: Instance): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	f.BackgroundTransparency = 0.2
	f.BorderSizePixel = 0
	f.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = f
	return f
end

local top = makeFrame("TopBar", UDim2.fromScale(1, 0.08), UDim2.fromScale(0, 0), gui)
top.BackgroundTransparency = 0.1
local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.Padding = UDim.new(0, 8)
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Parent = top

local function makeStatLabel(name: string, parent: Instance): TextLabel
	local tl = Instance.new("TextLabel")
	tl.Name = name
	tl.Size = UDim2.fromScale(0.22, 0.8)
	tl.BackgroundTransparency = 1
	tl.TextScaled = true
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.Font = Enum.Font.GothamBold
	tl.Text = name .. ": 0"
	tl.Parent = parent
	return tl
end

local infamyLabel = makeStatLabel("Infamy", top)
local heistsLabel = makeStatLabel("Heists", top)
local tokensLabel = makeStatLabel("Tokens", top)
local rebirthLabel = makeStatLabel("Rebirths", top)

-- Buttons row
local mid = makeFrame("MidBar", UDim2.fromScale(1, 0.07), UDim2.fromScale(0, 0.09), gui)
local midLayout = Instance.new("UIListLayout")
midLayout.FillDirection = Enum.FillDirection.Horizontal
midLayout.Padding = UDim.new(0, 6)
midLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
midLayout.VerticalAlignment = Enum.VerticalAlignment.Center
midLayout.Parent = mid

local function makeBtn(name: string, text: string, color: Color3, cb: () -> ()): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.fromScale(0.18, 0.8)
	b.Text = text
	b.TextScaled = true
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.BackgroundColor3 = color
	b.Parent = mid
	local c = Instance.new("UICorner")
	c.Parent = b
	b.MouseButton1Click:Connect(cb)
	return b
end

makeBtn("TrainBtn", "CLICK (+Infamy)", Color3.fromRGB(200, 40, 40), function()
	trainEv:FireServer()
end)
makeBtn("DungeonBtn", "Enter Heist", Color3.fromRGB(40, 120, 200), function()
	enterEv:FireServer()
end)
makeBtn("CashBtn", "Escape Van (Cash Out)", Color3.fromRGB(255, 220, 0), function()
	cashOutEv:FireServer()
end)
makeBtn(
	"RebirthBtn",
	"Rebirth (" .. tostring(Config.Rebirth.HeistsRequired) .. " Heists)",
	Color3.fromRGB(120, 40, 180),
	function()
		rebirthEv:FireServer()
	end
)

-- Villain shop scroll
local shop = makeFrame("Shop", UDim2.fromScale(0.48, 0.78), UDim2.fromScale(0.01, 0.17), gui)
shop.BackgroundTransparency = 0.3
local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.fromScale(1, 0.06)
shopTitle.BackgroundTransparency = 1
shopTitle.Text = "Villains — buy with Heists (adjacent parody names)"
shopTitle.TextScaled = true
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.Font = Enum.Font.GothamBold
shopTitle.Parent = shop
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.fromScale(1, 0.94)
scroll.Position = UDim2.fromScale(0, 0.06)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.fromScale(0, 0)
scroll.ScrollBarThickness = 6
scroll.Parent = shop
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local henchShop = makeFrame("HenchShop", UDim2.fromScale(0.48, 0.78), UDim2.fromScale(0.51, 0.17), gui)
henchShop.BackgroundTransparency = 0.3
local henchTitle = Instance.new("TextLabel")
henchTitle.Size = UDim2.fromScale(1, 0.06)
henchTitle.BackgroundTransparency = 1
henchTitle.Text = "Henchmen Capsules — hatch for multiplier"
henchTitle.TextScaled = true
henchTitle.TextColor3 = Color3.new(1, 1, 1)
henchTitle.Font = Enum.Font.GothamBold
henchTitle.Parent = henchShop
local henchScroll = Instance.new("ScrollingFrame")
henchScroll.Size = UDim2.fromScale(1, 0.94)
henchScroll.Position = UDim2.fromScale(0, 0.06)
henchScroll.BackgroundTransparency = 1
henchScroll.CanvasSize = UDim2.fromScale(0, 0)
henchScroll.ScrollBarThickness = 6
henchScroll.Parent = henchShop
local henchList = Instance.new("UIListLayout")
henchList.Padding = UDim.new(0, 4)
henchList.Parent = henchScroll

local ownedVillains: { string } = {}
local ownedHenchmen: { string } = {}

local function refreshShop(heists: number)
	scroll:ClearAllChildren()
	list.Parent = scroll
	-- re-add layout after clear
	list.Parent = scroll
	for idx, v in Config.Villains do
		local row = Instance.new("Frame")
		row.Size = UDim2.fromScale(1, 0.08)
		row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		row.LayoutOrder = idx
		row.Parent = scroll
		local rc = Instance.new("UICorner")
		rc.Parent = row
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(0.55, 1)
		tl.Position = UDim2.fromScale(0.02, 0)
		tl.BackgroundTransparency = 1
		tl.TextXAlignment = Enum.TextXAlignment.Left
		tl.TextScaled = true
		tl.TextColor3 = Color3.new(1, 1, 1)
		tl.Font = Enum.Font.Gotham
		local costStr = v.CostHeists and tostring(v.CostHeists) .. " Heists"
			or (v.Robux and tostring(v.Robux) .. " Robux" or "—")
		local pStr = v.PowerPerClick and tostring(v.PowerPerClick) .. "/click"
			or (v.IsBestMultiplier and "+100% best" or "?")
		tl.Text = string.format("%s [W%d] %s — %s", v.Name, v.World, pStr, costStr)
		tl.Parent = row
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(0.2, 0.8)
		btn.Position = UDim2.fromScale(0.78, 0.1)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Parent = row
		local bc = Instance.new("UICorner")
		bc.Parent = btn
		local isOwned = false
		for _, n in ownedVillains do
			if n == v.Name then
				isOwned = true
				break
			end
		end
		if isOwned then
			btn.Text = "Equip"
			btn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
			btn.MouseButton1Click:Connect(function()
				equipEv:FireServer(v.Name)
			end)
		elseif v.Robux then
			btn.Text = "Buy R$"
			btn.BackgroundColor3 = Color3.fromRGB(160, 140, 40)
			btn.MouseButton1Click:Connect(function()
				buyVillainFn:InvokeServer(v.Name)
			end)
		else
			local canAfford = heists >= (v.CostHeists or math.huge)
			btn.Text = canAfford and "Buy" or "Need Heists"
			btn.BackgroundColor3 = canAfford and Color3.fromRGB(40, 120, 200) or Color3.fromRGB(90, 90, 90)
			btn.MouseButton1Click:Connect(function()
				local ok, msg = buyVillainFn:InvokeServer(v.Name)
				if not ok then
					warn(msg)
				end
			end)
		end
	end
	task.wait()
	scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end

local function refreshHenchShop()
	henchScroll:ClearAllChildren()
	henchList.Parent = henchScroll
	for idx, egg in Config.HenchmenEggs do
		local row = Instance.new("Frame")
		row.Size = UDim2.fromScale(1, 0.09)
		row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		row.LayoutOrder = idx
		row.Parent = henchScroll
		local rc = Instance.new("UICorner")
		rc.Parent = row
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(0.65, 1)
		tl.Position = UDim2.fromScale(0.02, 0)
		tl.BackgroundTransparency = 1
		tl.TextXAlignment = Enum.TextXAlignment.Left
		tl.TextScaled = true
		tl.TextColor3 = Color3.new(1, 1, 1)
		tl.Font = Enum.Font.Gotham
		local costStr = egg.CostHeists and tostring(egg.CostHeists) .. " Heists"
			or egg.CostTokens and tostring(egg.CostTokens) .. " Tokens"
			or (egg.Robux and tostring(egg.Robux) .. " Robux" or "?")
		tl.Text = string.format("%s [W%d] — %s", egg.Name, egg.World, costStr)
		tl.Parent = row
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(0.2, 0.8)
		btn.Position = UDim2.fromScale(0.78, 0.1)
		btn.Text = "Hatch"
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.BackgroundColor3 = Color3.fromRGB(200, 120, 40)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Parent = row
		local bc = Instance.new("UICorner")
		bc.Parent = btn
		btn.MouseButton1Click:Connect(function()
			local ok, res = buyHenchFn:InvokeServer(egg.Name)
			if ok then
				print("Hatched " .. tostring(res))
			else
				warn(res)
			end
		end)
	end
	task.wait()
	henchScroll.CanvasSize = UDim2.new(0, 0, 0, henchList.AbsoluteContentSize.Y + 10)
end

local function onDataUpdate(data: any)
	infamyLabel.Text = "Infamy: " .. tostring(math.floor(data.Infamy))
	heistsLabel.Text = "Heists: " .. tostring(math.floor(data.Heists))
	tokensLabel.Text = "Tokens: " .. tostring(math.floor(data.Tokens))
	rebirthLabel.Text = "Rebirths: " .. tostring(data.Rebirths)
	ownedVillains = data.OwnedVillains or {}
	ownedHenchmen = data.OwnedHenchmen or {}
	refreshShop(math.floor(data.Heists))
	refreshHenchShop()
end

dataEv.OnClientEvent:Connect(onDataUpdate)

-- also poll attributes for top bar
task.spawn(function()
	while true do
		task.wait(0.5)
		infamyLabel.Text = "Infamy: " .. tostring(math.floor(player:GetAttribute("Infamy") or 0))
		heistsLabel.Text = "Heists: " .. tostring(math.floor(player:GetAttribute("Heists") or 0))
		tokensLabel.Text = "Tokens: " .. tostring(math.floor(player:GetAttribute("Tokens") or 0))
		rebirthLabel.Text = "Rebirths: " .. tostring(player:GetAttribute("Rebirths") or 0)
	end
end)

-- initial
refreshShop(0)
refreshHenchShop()
