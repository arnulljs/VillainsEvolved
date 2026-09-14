--!strict
-- Client morph listener: re-apply when EquippedVillain attribute changes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Morphs = require(ReplicatedStorage.Shared.Morphs)

local player = Players.LocalPlayer

local function apply()
	local char = player.Character
	if not char then return end
	local villainName = player:GetAttribute("EquippedVillain") :: string?
	if typeof(villainName) ~= "string" then villainName = "Goon" end
	local v = Config.GetVillainByName(villainName)
	local pal = v and v.Palette or "Gray"
	Morphs.ApplyToCharacter(char, villainName, pal)
end

player:GetAttributeChangedSignal("EquippedVillain"):Connect(apply)
player.CharacterAdded:Connect(function()
	task.wait(1)
	apply()
end)
if player.Character then task.wait(1); apply() end
