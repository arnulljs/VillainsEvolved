--!strict
-- Client morph listener: applies equipped villain visuals and particle auras
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morphs = require(ReplicatedStorage.Shared.Morphs)

local player = Players.LocalPlayer

local function apply()
	local villainId = player:GetAttribute("EquippedVillain") :: string?
	if typeof(villainId) ~= "string" or villainId == "" then
		villainId = "nobody"
	end
	Morphs.ApplyMorph(player, villainId)
end

player:GetAttributeChangedSignal("EquippedVillain"):Connect(apply)

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	apply()
end)

if player.Character then
	task.wait(0.5)
	apply()
end

print("✓ Villains Evolved Client Morph listener ready.")
