--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(ReplicatedStorage.Shared.Config)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyVillainFn = remotes:WaitForChild("BuyVillain") :: RemoteFunction
local buyHenchFn = remotes:WaitForChild("BuyHenchman") :: RemoteFunction

local function owns(player: Player, villainName: string): boolean
	local data = (_G :: any).VillainsData
	return data and data.OwnsVillain(player, villainName) or false
end

buyVillainFn.OnServerInvoke = function(player: Player, villainName: string)
	if typeof(villainName) ~= "string" then return false, "bad arg" end
	local v = Config.GetVillainByName(villainName)
	if not v then return false, "not found" end
	if owns(player, villainName) then return false, "already owned" end

	local data = (_G :: any).VillainsData
	if not data then return false, "no data" end
	local d = data.Get(player)

	-- Robux villain
	if v.Robux and v.CostHeists == nil then
		-- prompt purchase; for now fail until product wired
		return false, "Robux only — prompt not wired (id " .. tostring(v.Robux) .. ")"
	end

	-- Heists cost
	local cost = v.CostHeists
	if cost == nil then return false, "no cost" end
	if d.Heists < cost then return false, "not enough Heists" end

	-- world gate
	local world = Config.GetWorld(v.World)
	if world and d.Heists < world.GateHeists then return false, "world locked" end

	d.Heists -= cost
	data.GiveVillain(player, villainName)
	-- auto-equip if better?
	if v.PowerPerClick and v.PowerPerClick > (Config.GetVillainByName(d.EquippedVillain) and Config.GetVillainByName(d.EquippedVillain).PowerPerClick or 1) then
		data.EquipVillain(player, villainName)
		-- morph applied in Data.EquipVillain
	end
	return true, "bought"
end

buyHenchFn.OnServerInvoke = function(player: Player, eggName: string)
	if typeof(eggName) ~= "string" then return false, "bad arg" end
	local egg = nil
	for _, e in Config.HenchmenEggs do if e.Name == eggName then egg = e; break end end
	if not egg then return false, "egg not found" end

	local data = (_G :: any).VillainsData
	if not data then return false, "no data" end
	local d = data.Get(player)

	-- Robux egg
	if egg.Robux then return false, "Robux egg " .. tostring(egg.Robux) end

	if egg.CostHeists then
		if d.Heists < egg.CostHeists then return false, "not enough Heists" end
		d.Heists -= egg.CostHeists
	elseif egg.CostTokens then
		if d.Tokens < egg.CostTokens then return false, "not enough Tokens" end
		d.Tokens -= egg.CostTokens
	end

	-- random hatch
	local pool = egg.Henchmen
	local pick = pool[math.random(1, #pool)]
	table.insert(d.OwnedHenchmen, pick.Name)
	-- auto-equip up to limit
	local limit = 3
	if player:GetAttribute("Pass_+3 Henchmen") == true then limit = 6 end
	if #d.EquippedHenchmen < limit then table.insert(d.EquippedHenchmen, pick.Name) end

	-- sync
	local Data = data
	Data.Set(player, d)
	return true, pick.Name
end

-- Marketplace pass handling (wire after publishing)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, id: number, purchased: boolean)
	if not purchased then return end
	for _, gp in Config.Gamepasses do
		if gp.Id == id then
			player:SetAttribute("Pass_" .. gp.Name, true)
		end
	end
	-- Robux villains: grant if id matches
	for _, v in Config.Villains do
		if v.Robux and v.Name then
			-- you need to create DeveloperProducts for each Robux villain and map here
		end
	end
end)
