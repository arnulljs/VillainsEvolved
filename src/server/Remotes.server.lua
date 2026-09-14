--!strict
-- Creates RemoteEvents/Functions under ReplicatedStorage.Remotes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name: string, className: string)
	local r = remotesFolder:FindFirstChild(name)
	if not r then
		r = Instance.new(className)
		r.Name = name
		r.Parent = remotesFolder
	end
	return r
end

ensureRemote("Train", "RemoteEvent")
ensureRemote("Rebirth", "RemoteEvent")
ensureRemote("BuyVillain", "RemoteFunction")
ensureRemote("BuyHenchman", "RemoteFunction")
ensureRemote("EnterDungeon", "RemoteEvent")
ensureRemote("CashOut", "RemoteEvent")
ensureRemote("EquipVillain", "RemoteEvent")
ensureRemote("DataUpdate", "RemoteEvent") -- server -> client
