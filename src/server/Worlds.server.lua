--!strict
-- District teleport pads & gates (Districts 1 through 5)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)

local function ensureDistrictPads()
	local folder = Workspace:FindFirstChild("DistrictPads")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "DistrictPads"
		folder.Parent = Workspace
	end

	for i, d in Config.Districts do
		local pad = folder:FindFirstChild(d.name)
		if not pad then
			pad = Instance.new("Part")
			pad.Name = d.name
			pad.Size = Vector3.new(12, 1, 12)
			pad.Position = Vector3.new(-60 + (i * 20), 1, 60)
			pad.Anchored = true
			pad.Color = d.themeColor
			pad.Material = Enum.Material.Neon
			pad.Parent = folder

			local sg = Instance.new("SurfaceGui")
			sg.Face = Enum.NormalId.Top
			sg.Parent = pad

			local tl = Instance.new("TextLabel")
			tl.Size = UDim2.fromScale(1, 1)
			tl.BackgroundTransparency = 1
			tl.Text = string.format("DISTRICT %d\n%s\nReq: %s Loot", d.id, d.name:upper(), Format.abbreviate(d.unlockRequirement))
			tl.TextScaled = true
			tl.TextColor3 = Color3.fromRGB(255, 255, 255)
			tl.Font = Enum.Font.GothamBold
			tl.Parent = sg

			local prox = Instance.new("ProximityPrompt")
			prox.ObjectText = d.name
			prox.ActionText = "Travel"
			prox.HoldDuration = 0
			prox.MaxActivationDistance = 10
			prox.Parent = pad

			prox.Triggered:Connect(function(plr: Player)
				local data = (_G :: any).VillainsData
				if not data then return end
				local p = data.Get(plr)
				if p.Loot < d.unlockRequirement then return end

				p.District = d.id
				data.Set(plr, p)

				local char = plr.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hrp then
					hrp.CFrame = CFrame.new(0, 5, 0)
				end
			end)
		end
	end
end

ensureDistrictPads()