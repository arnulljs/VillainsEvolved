--!strict
-- Shop, Pedestal Purchases, Crate Hatching, Rebirth Requests, and Codes Funnel
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Morphs = require(ReplicatedStorage.Shared.Morphs)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyVillainFn = remotes:WaitForChild("BuyVillain") :: RemoteFunction
local buyCrateFn = remotes:WaitForChild("BuyCrate") :: RemoteFunction
local redeemCodeFn = remotes:WaitForChild("RedeemCode") :: RemoteFunction
local requestRebirthFn = remotes:WaitForChild("RequestRebirth") :: RemoteFunction
local equipVillainEv = remotes:WaitForChild("EquipVillain") :: RemoteEvent
local noticeEv = remotes:WaitForChild("FloatingNotice") :: RemoteEvent

local function getDataManager()
	return (_G :: any).VillainsData or (shared :: any).VillainsData
end

local ShopManager = {}

-- Buy Villain from Pedestal or UI
function ShopManager.BuyVillain(player: Player, villainId: string): { success: boolean, message: string }
	if typeof(villainId) ~= "string" then
		return { success = false, message = "Invalid argument" }
	end

	local v = Config.GetVillain(villainId)
	if not v then
		return { success = false, message = "Villain not found" }
	end

	local data = getDataManager()
	if not data then
		return { success = false, message = "Data service unavailable" }
	end

	if data.OwnsVillain(player, villainId) then
		data.EquipVillain(player, villainId)
		return { success = true, message = "Equipped " .. v.name .. "!" }
	end

	local p = data.Get(player)

	if v.costType == "Robux" then
		noticeEv:FireClient(player, {
			text = "Exclusive Robux Villain!",
			color = Color3.fromRGB(240, 140, 40),
		})
		return { success = false, message = "Robux item — purchase via store" }
	end

	if p.Loot < v.cost then
		noticeEv:FireClient(player, {
			text = string.format("Requires %s Loot! (Have: %s)", Format.abbreviate(v.cost), Format.abbreviate(p.Loot)),
			color = Color3.fromRGB(255, 80, 80),
		})
		return { success = false, message = "Not enough Loot" }
	end

	-- Deduct Loot and grant Villain
	p.Loot -= v.cost
	p.OwnedVillains[villainId] = true
	p.EquippedVillain = villainId
	data.Set(player, p)

	-- Apply Character Morph immediately
	Morphs.ApplyMorph(player, villainId)

	noticeEv:FireClient(player, {
		text = string.format("UNLOCKED %s! (+%s/Click)", v.name, Format.abbreviate(v.infamyPerClick)),
		color = Color3.fromRGB(80, 255, 120),
	})

	return { success = true, message = "Unlocked " .. v.name .. "!" }
end

buyVillainFn.OnServerInvoke = function(player: Player, villainId: string)
	return ShopManager.BuyVillain(player, villainId)
end

equipVillainEv.OnServerEvent:Connect(function(player: Player, villainId: any)
	if typeof(villainId) ~= "string" then return end
	local data = getDataManager()
	if data then
		data.EquipVillain(player, villainId)
	end
end)

;(_G :: any).VillainsShop = ShopManager
;(shared :: any).VillainsShop = ShopManager

-- Buy Recruitment Crate (Server-Side Roll)
buyCrateFn.OnServerInvoke = function(player: Player, crateId: string)
	local crate: Config.Crate? = nil
	for _, c in Config.Crates do
		if c.id == crateId then
			crate = c
			break
		end
	end

	if not crate then
		return { success = false, message = "Crate not found" }
	end

	local data = getDataManager()
	if not data then
		return { success = false, message = "Data unavailable" }
	end

	local p = data.Get(player)
	if p.Loot < crate.cost then
		return { success = false, message = "Not enough Loot" }
	end

	p.Loot -= crate.cost

	-- Server-Side Weighted RNG
	local roll = math.random() * 100
	local cumulative = 0
	local chosenHenchmanId = "alley_cat"

	for hId, weight in crate.weights do
		cumulative += weight
		if roll <= cumulative then
			chosenHenchmanId = hId
			break
		end
	end

	table.insert(p.Henchmen, chosenHenchmanId)

	-- Auto-equip up to slot limit
	local maxSlots = player:GetAttribute("Pass_+3 Henchmen") == true and 6 or 3
	if #p.EquippedHenchmen < maxSlots then
		table.insert(p.EquippedHenchmen, chosenHenchmanId)
	end

	data.Set(player, p)

	local henchObj = nil
	for _, h in Config.Henchmen do
		if h.id == chosenHenchmanId then
			henchObj = h
			break
		end
	end

	return { success = true, henchman = henchObj }
end

-- Redeem Code (Spec Revision 2 Section C.4)
redeemCodeFn.OnServerInvoke = function(player: Player, codeStr: string)
	if typeof(codeStr) ~= "string" then
		return { success = false, message = "Invalid code format" }
	end

	local cleanCode = string.upper(string.gsub(codeStr, "%s+", ""))
	local codeReward = Config.Codes[cleanCode]

	if not codeReward then
		return { success = false, message = "Code does not exist!" }
	end

	local data = getDataManager()
	if not data then
		return { success = false, message = "Data unavailable" }
	end

	local p = data.Get(player)
	if p.RedeemedCodes[cleanCode] then
		return { success = false, message = "Code already redeemed!" }
	end

	p.RedeemedCodes[cleanCode] = true
	p.Loot += codeReward.loot
	p.Heat += codeReward.heat
	data.Set(player, p)

	return { success = true, message = "Claimed: " .. codeReward.label }
end

-- Rebirth Request
requestRebirthFn.OnServerInvoke = function(player: Player)
	local data = getDataManager()
	if not data then
		return { success = false, message = "Data unavailable" }
	end

	local success, msg = data.Rebirth(player)
	local p = data.Get(player)

	local noticeEv = remotes:FindFirstChild("FloatingNotice") :: RemoteEvent?
	if noticeEv then
		if success then
			noticeEv:FireClient(player, {
				text = string.format("REBIRTH %d UNLOCKED! (+2x Multiplier)", p.Rebirths),
				color = Color3.fromRGB(80, 255, 120),
			})
		else
			noticeEv:FireClient(player, {
				text = msg or "Cannot rebirth yet!",
				color = Color3.fromRGB(255, 80, 80),
			})
		end
	end

	return {
		success = success,
		message = msg,
		rapSheet = p.Rebirths,
		multiplier = Config.Rebirth.multiplier(p.Rebirths),
	}
end

print("✓ Villains Evolved Shop & Codes initialized.")
