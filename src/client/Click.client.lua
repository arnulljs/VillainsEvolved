--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local trainEv = remotes:WaitForChild("Train") :: RemoteEvent

local function sendTrain()
	trainEv:FireServer()
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sendTrain()
	end
	if input.KeyCode == Enum.KeyCode.E then
		sendTrain()
	end
end)

-- touch for mobile
UserInputService.TouchTapInWorld:Connect(function()
	sendTrain()
end)
