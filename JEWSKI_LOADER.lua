--// JEWSKI LOADER — max speed + premium top UI
if _G.JewskiLoaderRunning then return end
_G.JewskiLoaderRunning = true

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local SoundService     = game:GetService("SoundService")
local StarterGui       = game:GetService("StarterGui")

pcall(function() game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen() end)
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)

local T0 = os.clock()
local function log(msg)
	if _G.JewskiLoaderQuiet then return end
	pcall(print, ("[JEWSKI] %.2fs | %s"):format(os.clock() - T0, msg))
end

local PLAY_FPS = tonumber(_G.JewskiPlayFps) or 9999
pcall(function() if setfpscap then setfpscap(PLAY_FPS) end end)
pcall(function() if setfps then setfps(PLAY_FPS) end end)

if type(setfflag) == "function" then
	local flags = {
		["DebugForceAllTextures1x1"] = "True",
		["RomRenderTextureScale"] = "32",
		["DFIntTextureQualityOverride"] = "0",
		["DFIntTexturePoolSizeMB"] = "1",
		["DFIntTextureCompositorActiveJobs"] = "0",
		["FIntRenderTextureScale"] = "1",
		["FFlagTextureQualityOverrideEnabled"] = "True",
		["DFIntTextureStreamingPoolSizeMB"] = "1",
		["FIntTextureCompositorLowResFactor"] = "4",
		["FIntRenderShadowIntensity"] = "0",
		["FIntRenderLocalLightUpdatesMax"] = "0",
		["FIntRenderLocalLightUpdatesMin"] = "0",
		["FIntRenderLocalLightFadeInMs"] = "0",
		["FFlagDebugLightingRender"] = "False",
		["FFlagNewLightAttenuation"] = "False",
		["DFIntMaxShadowmapSize"] = "0",
		["DFIntCSGLevelOfDetailSwitchingDistance"] = "0",
		["DFIntCSGLevelOfDetailSwitchingDistanceL12"] = "0",
		["DFIntCSGLevelOfDetailSwitchingDistanceL23"] = "0",
		["DFIntCSGLevelOfDetailSwitchingDistanceL34"] = "0",
		["FFlagDebugSkipMeshVoxelizer"] = "True",
		["DFFlagDebugPauseVoxelizer"] = "True",
		["FFlagDebugDisableMeshOcclusion"] = "True",
		["FIntTerrainArraySliceSize"] = "0",
		["DFIntMaxFrameBufferSize"] = "1",
		["FIntRenderGrassDensity"] = "0",
		["FIntRenderGrassHeightScaler"] = "0",
		["FIntTerrainDecorationDrawDistance"] = "0",
		["FIntSimWidgetKeyboardMoveTime"] = "0",
		["DFIntS2PhysicsSenderRate"] = "15",
		["DFIntTaskSchedulerTargetFps"] = "9999",
		["FFlagTaskSchedulerLimitTargetFpsTo2402"] = "False",
		["DFIntHttpCurlConnectionCacheSize"] = "0",
		["FFlagDebugDisableTimeoutDisconnect"] = "True",
		["DFIntTimestepArbiterThresholdInMs"] = "0",
		["DFIntDebugFRMQualityLevelOverride"] = "1",
		["FIntFRMMinGrassDistance"] = "0",
		["FIntFRMMaxGrassDistance"] = "0",
		["FIntRenderMeshAOQuality"] = "0",
		["FIntRenderBloomQuality"] = "0",
		["DFIntMaxInterpolationFrames"] = "1",
		["DFIntMaxProcessPacketsStepsPerCycle"] = "8",
		["DFIntRenderClampMaxTextureSize"] = "64",
		["FFlagEnableCameraCulling"] = "False",
		["FIntCameraFarZPlane"] = "500",
	}
	for k, v in pairs(flags) do pcall(setfflag, k, v) end
	log("fflags applied")
end

local LP = Players.LocalPlayer
while not LP do task.wait(); LP = Players.LocalPlayer end

local MAX_LOAD = tonumber(_G.JewskiMaxLoad) or 6
local restore, restored = {}, false
local function keep(fn) restore[#restore + 1] = fn end
if _G.JewskiKeepLowGraphics == nil then _G.JewskiKeepLowGraphics = true end
local function keepGfx(fn)
	if _G.JewskiKeepLowGraphics ~= false then return end
	restore[#restore + 1] = fn
end

local function playDoneSound()
	pcall(function()
		local s = Instance.new("Sound")
		s.Name = "JewskiDone"
		s.SoundId = "rbxassetid://828172750"
		s.Volume = tonumber(_G.JewskiDoneVolume) or 1
		s.Parent = SoundService
		s:Play()
		s.Ended:Connect(function() pcall(function() s:Destroy() end) end)
		task.delay(8, function() if s and s.Parent then pcall(function() s:Destroy() end) end end)
	end)
end

local function restoreAll(reason)
	if restored then return end
	restored = true
	for i = #restore, 1, -1 do pcall(restore[i]) end
	table.clear(restore)
	pcall(function() if setfpscap then setfpscap(PLAY_FPS) end end)
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
	log("restored (" .. tostring(reason) .. ")")
end

task.delay(MAX_LOAD, function() restoreAll("timeout") end)
if LP.OnTeleport then
	pcall(function() LP.OnTeleport:Connect(function() restoreAll("teleport") end) end)
end

----------------------------------------------------------------
-- PREMIUM TOP UI
----------------------------------------------------------------
local C = {
	bg      = Color3.fromRGB(12, 12, 16),
	panel   = Color3.fromRGB(18, 18, 24),
	line    = Color3.fromRGB(48, 48, 58),
	accent  = Color3.fromRGB(168, 85, 247), -- soft violet
	accent2 = Color3.fromRGB(236, 72, 153), -- pink tip
	text    = Color3.fromRGB(250, 250, 252),
	muted   = Color3.fromRGB(140, 140, 155),
	ok      = Color3.fromRGB(52, 211, 153),
}

local function mk(class, parent, props)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function pickHost()
	local hosts = {}
	pcall(function() if gethui then hosts[#hosts + 1] = gethui() end end)
	pcall(function() hosts[#hosts + 1] = game:GetService("CoreGui") end)
	hosts[#hosts + 1] = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 4)
	for _, h in ipairs(hosts) do
		if h then
			local ok = pcall(function()
				local probe = Instance.new("Folder"); probe.Parent = h; probe:Destroy()
			end)
			if ok then return h end
		end
	end
	return nil
end

local gui, card, barFill, pctLbl, subLbl, statusDot
local CARD_W, CARD_H = 360, 78

local uiOk = pcall(function()
	local host = pickHost()
	if not host then error("no host") end
	local old = host:FindFirstChild("JewskiBootUI")
	if old then old:Destroy() end

	gui = mk("ScreenGui", host, {
		Name = "JewskiBootUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 10000,
	})

	-- soft outer glow
	local glow = mk("Frame", gui, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -CARD_H - 20),
		Size = UDim2.fromOffset(CARD_W + 18, CARD_H + 18),
		BackgroundColor3 = C.accent,
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
	})
	mk("UICorner", glow, { CornerRadius = UDim.new(0, 22) })

	card = mk("Frame", gui, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -CARD_H - 16),
		Size = UDim2.fromOffset(CARD_W, CARD_H),
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
	})
	mk("UICorner", card, { CornerRadius = UDim.new(0, 16) })
	mk("UIStroke", card, {
		Color = C.line, Thickness = 1, Transparency = 0.25,
	})
	-- subtle top sheen
	mk("UIGradient", card, {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 36)),
			ColorSequenceKeypoint.new(0.45, C.panel),
			ColorSequenceKeypoint.new(1, C.bg),
		}),
	})

	-- brand mark (circle)
	local mark = mk("Frame", card, {
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
	})
	mk("UICorner", mark, { CornerRadius = UDim.new(1, 0) })
	mk("UIGradient", mark, {
		Rotation = 135,
		Color = ColorSequence.new(C.accent, C.accent2),
	})
	mk("TextLabel", mark, {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBlack,
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "J",
	})

	mk("TextLabel", card, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 12),
		Size = UDim2.new(1, -120, 0, 20),
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "JEWSKI LOADER",
	})

	subLbl = mk("TextLabel", card, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 32),
		Size = UDim2.new(1, -120, 0, 14),
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = C.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Initializing…",
	})

	-- status chip top-right
	local chip = mk("Frame", card, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 14),
		Size = UDim2.fromOffset(72, 22),
		BackgroundColor3 = Color3.fromRGB(28, 28, 36),
		BorderSizePixel = 0,
	})
	mk("UICorner", chip, { CornerRadius = UDim.new(1, 0) })
	statusDot = mk("Frame", chip, {
		Position = UDim2.fromOffset(8, 7),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
	})
	mk("UICorner", statusDot, { CornerRadius = UDim.new(1, 0) })
	pctLbl = mk("TextLabel", chip, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "0%",
	})

	-- progress track
	local track = mk("Frame", card, {
		Position = UDim2.fromOffset(16, CARD_H - 18),
		Size = UDim2.new(1, -32, 0, 5),
		BackgroundColor3 = Color3.fromRGB(32, 32, 40),
		BorderSizePixel = 0,
	})
	mk("UICorner", track, { CornerRadius = UDim.new(1, 0) })

	barFill = mk("Frame", track, {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
	})
	mk("UICorner", barFill, { CornerRadius = UDim.new(1, 0) })
	mk("UIGradient", barFill, {
		Color = ColorSequence.new(C.accent, C.accent2),
	})

	-- slide in from top
	local slide = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TweenService:Create(card, slide, { Position = UDim2.new(0.5, 0, 0, 22) }):Play()
	TweenService:Create(glow, slide, { Position = UDim2.new(0.5, 0, 0, 13) }):Play()

	-- pulse status dot
	task.spawn(function()
		while statusDot and statusDot.Parent do
			TweenService:Create(statusDot, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0.55,
			}):Play()
			task.wait(0.7)
			if not statusDot or not statusDot.Parent then break end
			TweenService:Create(statusDot, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0,
			}):Play()
			task.wait(0.7)
		end
	end)
end)

if not uiOk then log("ui skipped") end
_G.JewskiLoaderUIShown = uiOk == true

local function setProgress(p, label)
	p = math.clamp(p, 0, 1)
	if barFill and barFill.Parent then
		TweenService:Create(barFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Size = UDim2.fromScale(p, 1),
		}):Play()
	end
	if pctLbl then pctLbl.Text = ("%d%%"):format(math.floor(p * 100)) end
	if subLbl and label then subLbl.Text = label end
	if p >= 1 and statusDot then
		statusDot.BackgroundColor3 = C.ok
	end
end

----------------------------------------------------------------
-- Graphics / world
----------------------------------------------------------------
pcall(function()
	local ok, s = pcall(settings)
	if ok and s and s.Rendering then
		local r = s.Rendering
		local prev = r.QualityLevel
		r.QualityLevel = Enum.QualityLevel.Level01
		pcall(function() r.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
		keepGfx(function() r.QualityLevel = prev end)
	end
end)

pcall(function()
	for _, o in ipairs(Lighting:GetDescendants()) do
		if o:IsA("PostEffect") or o:IsA("Atmosphere") or o:IsA("Sky")
			or o:IsA("BloomEffect") or o:IsA("BlurEffect") or o:IsA("ColorCorrectionEffect")
			or o:IsA("SunRaysEffect") or o:IsA("DepthOfFieldEffect") then
			pcall(function() o.Enabled = false end)
		end
	end
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Brightness = 1
	Lighting.FogStart = 0
	Lighting.FogEnd = tonumber(_G.JewskiLoadFog) or 120
	Lighting.ClockTime = 12
	pcall(function() Lighting.Technology = Enum.Technology.Legacy end)
end)

pcall(function()
	local ter = Workspace:FindFirstChildOfClass("Terrain")
	if ter then
		ter.Decoration = false
		ter.WaterWaveSize = 0
		ter.WaterWaveSpeed = 0
		ter.WaterReflectance = 0
		ter.WaterTransparency = 1
	end
end)

local SMOOTH = Enum.Material.SmoothPlastic
local FX = {
	ParticleEmitter = true, Trail = true, Beam = true,
	Smoke = true, Fire = true, Sparkles = true,
	PointLight = true, SpotLight = true, SurfaceLight = true,
}

local function stripPart(o)
	local c = o.ClassName
	if c == "MeshPart" then
		pcall(function() o.TextureID = "" end)
		pcall(function() o.Material = SMOOTH; o.CastShadow = false end)
	elseif c == "SpecialMesh" then
		pcall(function() o.TextureId = "" end)
	elseif c == "Decal" or c == "Texture" then
		pcall(function() o.Texture = "" end)
	elseif FX[c] then
		pcall(function()
			if o:IsA("Light") then o.Enabled = false
			elseif o.Enabled ~= nil then o.Enabled = false end
		end)
	elseif o:IsA("BasePart") then
		pcall(function() o.Material = SMOOTH; o.CastShadow = false; o.Reflectance = 0 end)
	end
end

task.spawn(function()
	local list = Workspace:GetDescendants()
	local i, n = 1, #list
	local budget = tonumber(_G.JewskiSweepMs) or 16
	while i <= n do
		local t = os.clock()
		while i <= n and (os.clock() - t) * 1000 < budget do
			pcall(stripPart, list[i]); i += 1
		end
		RunService.Heartbeat:Wait()
	end
	log("world stripped: " .. tostring(n))
	Workspace.DescendantAdded:Connect(function(o) pcall(stripPart, o) end)
end)

if _G.JewskiFryUI ~= false then
	task.spawn(function()
		local pg = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 3)
		if not pg then return end
		for _, o in ipairs(pg:GetDescendants()) do
			if o:IsA("ImageLabel") or o:IsA("ImageButton") then
				pcall(function() o.ResampleMode = Enum.ResamplerMode.Pixelated end)
			end
		end
	end)
end

----------------------------------------------------------------
-- Ready
----------------------------------------------------------------
local MARK = { game = false, char = false }

task.spawn(function()
	if not game:IsLoaded() then game.Loaded:Wait() end
	MARK.game = true
	setProgress(0.45, "Game online")
end)

task.spawn(function()
	local ch = LP.Character or LP.CharacterAdded:Wait()
	ch:WaitForChild("HumanoidRootPart", 10)
	MARK.char = true
	setProgress(0.85, "Character ready")
end)

task.spawn(function()
	pcall(function() Workspace:WaitForChild("Plots", 4) end)
	setProgress(0.95, "Map warm")
end)

for _, d in ipairs({ 0.1, 0.4 }) do
	task.delay(d, function()
		pcall(function()
			local cam = Workspace.CurrentCamera
			if cam then
				cam.CameraType = Enum.CameraType.Custom
				local ch = LP.Character
				if ch then cam.CameraSubject = ch:FindFirstChildOfClass("Humanoid") end
			end
		end)
	end)
end

task.spawn(function()
	while not (MARK.game and MARK.char) and (os.clock() - T0) < MAX_LOAD do
		RunService.Heartbeat:Wait()
	end
	local took = os.clock() - T0
	log(("ready in %.2fs"):format(took))
	setProgress(1, ("Ready · %.2fs"):format(took))
	playDoneSound()
	restoreAll("ready")
	_G.JewskiLoaderReady = true
	_G.JewskiLoaderReadyAt = took
	_G.EladLoaderReady = true -- compat
end)

if uiOk then
	task.spawn(function()
		local minShow = tonumber(_G.JewskiCardHold) or 0.55
		local tShow = os.clock()
		while not _G.JewskiLoaderReady and (os.clock() - T0) < MAX_LOAD do
			task.wait(0.04)
		end
		local left = minShow - (os.clock() - tShow)
		if left > 0 then task.wait(left) end
		if card and card.Parent then
			local t = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			for _, o in ipairs(gui:GetChildren()) do
				if o:IsA("Frame") then
					TweenService:Create(o, t, {
						Position = UDim2.new(0.5, 0, 0, -CARD_H - 30),
						BackgroundTransparency = 1,
					}):Play()
				end
			end
			task.wait(0.38)
		end
		pcall(function() if gui then gui:Destroy() end end)
		_G.JewskiLoaderRunning = nil
	end)
else
	task.delay(MAX_LOAD + 1, function() _G.JewskiLoaderRunning = nil end)
end

log("boot started")
