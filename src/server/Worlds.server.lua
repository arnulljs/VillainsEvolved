--!strict
-- World teleport pads + gate checks

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local WORLD_POSITIONS: { [number]: Vector3 } = {
	[1] = Vector3.new(0, 5, 0),
	[2] = Vector3.new(200, 5, 0),
	[3] = Vector3.new(400, 5, 0),
	[4] = Vector3.new(600, 5, 0),
	[5] = Vector3.new(800, 5, 0),
}

local function ensureWorldPads()
	local folder = Workspace:FindFirstChild("WorldPads")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "WorldPads"
		folder.Parent = Workspace
	end
	for _, w in Config.Worlds do
		local pad = folder:FindFirstChild(w.Name)
		if not pad then
			pad = Instance.new("Part")
			pad.Name = w.Name
			pad.Size = Vector3.new(14, 1, 14)
			pad.Position = (WORLD_POSITIONS[w.Id] or Vector3.new(w.Id * 200, 5, 0)) + Vector3.new(0, -4, 20)
			pad.Anchored = true
			pad.Color = w.Color
			pad.Material = Enum.Material.Neon
			pad.Parent = folder
			local sg = Instance.new("SurfaceGui")
			sg.Face = Enum.NormalId.Top
			sg.Parent = pad
			local tl = Instance.new("TextLabel")
			tl.Size = UDim2.fromScale(1, 1)
			tl.BackgroundTransparency = 1
			tl.Text = w.Name .. "\n" .. tostring(w.GateHeists) .. " Heists"
			tl.TextScaled = true
			tl.TextColor3 = Color3.fromRGB(255, 255, 255)
			tl.Font = Enum.Font.GothamBold
			tl.Parent = sg
			local prox = Instance.new("ProximityPrompt")
			prox.ObjectText = w.Name
			prox.ActionText = "Teleport"
			prox.HoldDuration = 0
			prox.MaxActivationDistance = 12
			prox.Parent = pad
			prox.Triggered:Connect(function(plr: Player)
				local data = (_G :: any).VillainsData
				if not data then
					return
				end
				local d = data.Get(plr)
				if d.Heists < w.GateHeists or d.Infamy < w.GateInfamy then
					return
				end
				d.CurrentWorld = w.Id
				data.Set(plr, d)
				local char = plr.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hrp then
					hrp.CFrame = CFrame.new(WORLD_POSITIONS[w.Id])
				end
			end)
		end
	end
end

ensureWorldPads()
