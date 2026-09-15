--!strict
-- Remotes initialization for Villains Evolved
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote<T>(name: string, className: string): T
	local r = remotesFolder:FindFirstChild(name)
	if not r then
		r = Instance.new(className)
		r.Name = name
		r.Parent = remotesFolder
	end
	return (r :: any) :: T
end

-- Events
ensureRemote("Train", "RemoteEvent")
ensureRemote("EnterJob", "RemoteEvent")
ensureRemote("CashOut", "RemoteEvent")
ensureRemote("EquipVillain", "RemoteEvent")
ensureRemote("EquipBestHenchmen", "RemoteEvent")
ensureRemote("EnterRaid", "RemoteEvent")
ensureRemote("DataUpdate", "RemoteEvent")
ensureRemote("TimerUpdate", "RemoteEvent")
ensureRemote("JobUpdate", "RemoteEvent")
ensureRemote("FloatingNotice", "RemoteEvent")

-- Functions
ensureRemote("BuyVillain", "RemoteFunction")
ensureRemote("BuyCrate", "RemoteFunction")
ensureRemote("RequestRebirth", "RemoteFunction")
ensureRemote("RedeemCode", "RemoteFunction")

print("✓ Villains Evolved Remotes initialized successfully.")
