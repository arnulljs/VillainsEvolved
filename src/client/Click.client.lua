--!strict
-- Click Client: 0.1s Batching, Instant Predicted Feedback, Sound, Punch Effect, and Mobile Support
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local trainEv = remotes:WaitForChild("Train") :: RemoteEvent
local noticeEv = remotes:WaitForChild("FloatingNotice") :: RemoteEvent

local clicksInBatch = 0
local lastFlush = os.clock()

-- Floating Notice / Predicted visual feedback
local playerGui = player:WaitForChild("PlayerGui")
local feedbackGui = playerGui:FindFirstChild("FeedbackGui") :: ScreenGui?
if not feedbackGui then
	feedbackGui = Instance.new("ScreenGui")
	feedbackGui.Name = "FeedbackGui"
	feedbackGui.ResetOnSpawn = false
	feedbackGui.Parent = playerGui
end

local function spawnFloatingText(text: string, color: Color3, startPos: UDim2?)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.2, 0.05)
	label.Position = startPos or UDim2.fromScale(0.4 + math.random(-5, 5) / 100, 0.45 + math.random(-5, 5) / 100)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = feedbackGui

	local targetPos = label.Position - UDim2.fromScale(0, 0.08)
	local tween = TweenService:Create(label, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = targetPos,
		TextTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		label:Destroy()
	end)
end

-- Server feedback receiver
noticeEv.OnClientEvent:Connect(function(data: { text: string, color: Color3 })
	if data and data.text then
		spawnFloatingText(data.text, data.color or Color3.new(1, 1, 1))
	end
end)

local isPunching = false
local defaultShoulderC0: CFrame? = nil

local function playPunchAnimation()
	local char = player.Character
	if not char then return end

	local rightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	local shoulder: Motor6D? = nil

	if rightUpperArm then
		shoulder = (rightUpperArm:FindFirstChild("RightShoulder") or rightUpperArm:FindFirstChild("Right Shoulder")) :: Motor6D?
	end
	if not shoulder and torso then
		shoulder = (torso:FindFirstChild("RightShoulder") or torso:FindFirstChild("Right Shoulder")) :: Motor6D?
	end

	if shoulder then
		if not defaultShoulderC0 then
			defaultShoulderC0 = shoulder.C0
		end

		if not isPunching then
			isPunching = true
			local origC0 = defaultShoulderC0 :: CFrame
			local punchC0 = origC0 * CFrame.Angles(math.rad(75), math.rad(-15), math.rad(20)) * CFrame.new(0, 0, -0.4)

			shoulder.C0 = punchC0

			-- Fist impact shockwave effect
			local fistPart = (char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")) :: BasePart?
			if fistPart then
				local punchFx = Instance.new("Part")
				punchFx.Size = Vector3.new(0.6, 0.6, 0.6)
				punchFx.Shape = Enum.PartType.Ball
				punchFx.Color = Color3.fromRGB(255, 215, 60)
				punchFx.Material = Enum.Material.Neon
				punchFx.CanCollide = false
				punchFx.Anchored = true
				punchFx.CFrame = fistPart.CFrame * CFrame.new(0, -0.6, 0)
				punchFx.Parent = Workspace

				local fxTween = TweenService:Create(punchFx, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(1.8, 1.8, 1.8),
					Transparency = 1,
				})
				fxTween:Play()
				fxTween.Completed:Connect(function()
					punchFx:Destroy()
				end)
			end

			task.delay(0.09, function()
				if shoulder and shoulder.Parent then
					local returnTween = TweenService:Create(shoulder, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						C0 = origC0,
					})
					returnTween:Play()
					returnTween.Completed:Connect(function()
						isPunching = false
					end)
				else
					isPunching = false
				end
			end)
		end
	end
end

player.CharacterAdded:Connect(function()
	defaultShoulderC0 = nil
	isPunching = false
end)

-- Click action
local function registerClick()
	clicksInBatch += 1

	-- Instant Punch Animation & Camera Bump
	playPunchAnimation()

	local cam = Workspace.CurrentCamera
	if cam then
		cam.FieldOfView -= 0.8
		task.delay(0.05, function()
			cam.FieldOfView += 0.8
		end)
	end
end

-- 0.1-second batch flusher
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	if now - lastFlush >= 0.1 then
		if clicksInBatch > 0 then
			trainEv:FireServer({ count = clicksInBatch })
			clicksInBatch = 0
		end
		lastFlush = now
	end
end)

-- Input handlers
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		registerClick()
	elseif input.KeyCode == Enum.KeyCode.E then
		registerClick()
	end
end)

UserInputService.TouchTapInWorld:Connect(function(_, gp)
	if not gp then
		registerClick()
	end
end)

print("✓ Villains Evolved Click Client (0.1s Batching) initialized.")
