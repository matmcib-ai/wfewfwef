-- [[ ULTIMATE HYBRID LOADER - KASHI STYLE WIDGET ]]
-- Place in ReplicatedFirst > LocalScript or execute via your executor.

local CONFIG = {
    REVEAL_ON = "playable",      -- "render", "playable", "loaded"
    MAX_WAIT = 8,                -- Hard cap in seconds
    VISUAL_CLEANUP = true,       -- Disable heavy visual effects for higher FPS
    USE_DESTROY = false,         -- false = disable in place (anti-cheat safe), true = delete instances
    NUKE_3D_TEXTURES = true,     -- Convert 3D models to low-spec SmoothPlastic with no textures
    PRELOAD_ASSETS = true,       -- Asynchronously preloads workspace & plot assets
    APPLY_FFLAGS = true,         -- Inject performance FFlags
    BLACK_OVERLAY = true,        -- Display black screen overlay during load
    DISPLAY_TIME = 6             -- How many seconds the top card stays before fading out
}

-- ============================================
-- 1. INITIAL SETUP & ENVIRONMENT MOUNTING
-- ============================================
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

pcall(function() ReplicatedFirst:RemoveDefaultLoadingScreen() end)

local startTime = os.clock()
local texturesRemoved = 0
local effectsDisabled = 0
local assetsPreloaded = 0

local localPlayer = Players.LocalPlayer
while not localPlayer do
    task.wait()
    localPlayer = Players.LocalPlayer
end

local function mountGui(gui)
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
    local mounted = false
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then
        gui.Parent = hui
        mounted = true
    end
    if not mounted then
        mounted = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    end
    if not mounted then
        gui.Parent = localPlayer:WaitForChild("PlayerGui", 5)
    end
end

-- ============================================
-- 2. BLACK LOADING OVERLAY
-- ============================================
local blackScreenGui, blackFrame
if CONFIG.BLACK_OVERLAY then
    blackScreenGui = Instance.new("ScreenGui")
    blackScreenGui.Name = "UltimateLoaderOverlay"
    blackScreenGui.ResetOnSpawn = false
    blackScreenGui.IgnoreGuiInset = true
    blackScreenGui.DisplayOrder = 999998

    blackFrame = Instance.new("Frame")
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackFrame.BorderSizePixel = 0
    blackFrame.Parent = blackScreenGui

    local loadLbl = Instance.new("TextLabel")
    loadLbl.Size = UDim2.new(1, 0, 0, 40)
    loadLbl.Position = UDim2.new(0, 0, 1, -80)
    loadLbl.BackgroundTransparency = 1
    loadLbl.Text = "LOADING..."
    loadLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    loadLbl.Font = Enum.Font.GothamBold
    loadLbl.TextSize = 13
    loadLbl.Parent = blackFrame

    mountGui(blackScreenGui)
end

-- ============================================
-- 3. FFLAG INJECTION
-- ============================================
if CONFIG.APPLY_FFLAGS then
    task.spawn(function()
        local candidates = {"setfflag", "setfastflag", "set_fflag", "setFFlag", "fflag", "mfflags"}
        local setter = nil
        for _, name in ipairs(candidates) do
            local fn = rawget(getfenv(), name) or (getgenv and getgenv()[name])
            if type(fn) == "function" then setter = fn; break end
        end

        if setter then
            local fflags = {
                ["DFIntTaskSchedulerTargetFps"] = "9999",
                ["FFlagTaskSchedulerLimitTargetFpsToDevice"] = "False",
                ["FIntTaskSchedulerAutoThreadLimit"] = "8",
                ["FFlagEnableTextureStreaming"] = "True",
                ["DFIntMaxConcurrentDownloads"] = "64",
                ["FIntContentProviderConcurrentDownloadCount"] = "64",
                ["FFlagLuauCodegen"] = "True",
                ["FFlagLuauCodegenFull"] = "True",
                ["FFlagDisablePostProcess"] = "True",
                ["FFlagDisablePostFx"] = "True",
                ["FFlagDisableTelemetryOnJoin"] = "True"
            }
            for flag, val in pairs(fflags) do
                pcall(function() setter(flag, val) end)
            end
        end
    end)
end

-- ============================================
-- 4. PASSIVE GRAPHICS & WORLD CLEANUP
-- ============================================
pcall(function()
    local r = settings().Rendering
    r.QualityLevel = Enum.QualityLevel.Level01
    r.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
end)

local function processObject(obj)
    local class = obj.ClassName

    if CONFIG.NUKE_3D_TEXTURES then
        pcall(function()
            if obj:IsA("MeshPart") then
                obj.TextureID = ""
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            end
        end)
    end

    if CONFIG.VISUAL_CLEANUP then
        if class == "ParticleEmitter" or class == "Fire" or class == "Smoke" or class == "Sparkles" or class == "Trail" or class == "Beam" or class == "Highlight" then
            if CONFIG.USE_DESTROY then obj:Destroy() else pcall(function() obj.Enabled = false end) end
            effectsDisabled += 1
        elseif class == "PointLight" or class == "SpotLight" or class == "SurfaceLight" then
            if CONFIG.USE_DESTROY then obj:Destroy() else pcall(function() obj.Enabled = false end) end
            effectsDisabled += 1
        elseif class == "BloomEffect" or class == "BlurEffect" or class == "DepthOfFieldEffect" or class == "SunRaysEffect" or class == "ColorCorrectionEffect" then
            if CONFIG.USE_DESTROY then obj:Destroy() else pcall(function() obj.Enabled = false end) end
            effectsDisabled += 1
        elseif class == "Atmosphere" then
            if CONFIG.USE_DESTROY then obj:Destroy() else pcall(function() obj.Density = 0 end) end
            effectsDisabled += 1
        elseif class == "Clouds" then
            if CONFIG.USE_DESTROY then obj:Destroy() else pcall(function() obj.Cover = 0; obj.Density = 0 end) end
            effectsDisabled += 1
        elseif class == "Decal" or class == "Texture" then
            if CONFIG.USE_DESTROY then obj:Destroy() else pcall(function() obj.Transparency = 1 end) end
            texturesRemoved += 1
        end
    end
end

local function scanWorld()
    for _, obj in ipairs(Workspace:GetDescendants()) do processObject(obj) end
    for _, obj in ipairs(Lighting:GetDescendants()) do processObject(obj) end
end

Workspace.DescendantAdded:Connect(processObject)
Lighting.DescendantAdded:Connect(processObject)

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 99999
end)

scanWorld()

-- ============================================
-- 5. ASSET PRELOADING
-- ============================================
if CONFIG.PRELOAD_ASSETS then
    task.spawn(function()
        local ids, seen = {}, {}
        local propMap = {
            MeshPart = {"MeshId", "TextureID"},
            SpecialMesh = {"MeshId", "TextureId"},
            Decal = {"Texture"}, Texture = {"Texture"}
        }
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if #ids >= 250 then break end
            local props = propMap[obj.ClassName]
            if props then
                for _, prop in ipairs(props) do
                    pcall(function()
                        local id = obj[prop]
                        if id and id ~= "" and not seen[id] then
                            seen[id] = true
                            table.insert(ids, id)
                        end
                    end)
                end
            end
        end
        if #ids > 0 then
            pcall(ContentProvider.PreloadAsync, ContentProvider, ids)
            assetsPreloaded = #ids
        end
    end)
end

-- ============================================
-- 6. MILESTONE REVEAL
-- ============================================
local mile = {}
local function mark(name) if not mile[name] then mile[name] = os.clock() - startTime end end

task.spawn(function() RunService.RenderStepped:Wait(); mark("render") end)
task.spawn(function() while not Workspace.CurrentCamera do task.wait() end; mark("camera") end)
task.spawn(function()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    mark("character")
end)
task.spawn(function() if not game:IsLoaded() then game.Loaded:Wait() end; mark("loaded") end)

local function isReady()
    if CONFIG.REVEAL_ON == "render" then return mile.render ~= nil end
    if CONFIG.REVEAL_ON == "loaded" then return mile.loaded ~= nil end
    return mile.loaded ~= nil or (mile.camera ~= nil and mile.character ~= nil)
end

while not isReady() do
    if os.clock() - startTime > CONFIG.MAX_WAIT then break end
    task.wait()
end

local finalLoadTime = os.clock() - startTime

if blackFrame then
    TweenService:Create(blackFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    task.delay(0.4, function() blackScreenGui:Destroy() end)
end

-- ============================================
-- 7. KASHI-STYLE TOP WIDGET CARD
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "KashiStyleLoader"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

-- Outer Shadow (Matches Kashi size/position offset)
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, 304, 0, 100)
shadow.Position = UDim2.new(0.5, -154, 0, 20)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.6
shadow.BorderSizePixel = 0
shadow.ZIndex = 1
shadow.Parent = gui
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

-- Main Top Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 96)
frame.Position = UDim2.new(0.5, -150, 0, 18)
frame.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
frame.BorderSizePixel = 0
frame.ZIndex = 2
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Top Gradient Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 3)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = frame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 100, 255)),
})
topGrad.Parent = topBar

-- Close Button[cite: 2]
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 4
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Title[cite: 2]
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 22)
title.Position = UDim2.new(0, 16, 0, 10)
title.BackgroundTransparency = 1
title.Text = "ultimate loader"
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = frame

-- Divider Line[cite: 2]
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -32, 0, 1)
divider.Position = UDim2.new(0, 16, 0, 36)
divider.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
divider.BorderSizePixel = 0
divider.ZIndex = 3
divider.Parent = frame

-- Stat Row Labels
local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0.5, 0, 0, 18)
timeLabel.Position = UDim2.new(0, 16, 0, 44)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = string.format("⏱  %.2fs", finalLoadTime)
timeLabel.TextColor3 = Color3.fromRGB(100, 200, 130)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 12
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.ZIndex = 4
timeLabel.Parent = frame

local texLabel = Instance.new("TextLabel")
texLabel.Size = UDim2.new(0.5, -16, 0, 18)
texLabel.Position = UDim2.new(0.5, 0, 0, 44)
texLabel.BackgroundTransparency = 1
texLabel.Text = "🖼  " .. texturesRemoved .. " textures"
texLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
texLabel.Font = Enum.Font.Gotham
texLabel.TextSize = 11
texLabel.TextXAlignment = Enum.TextXAlignment.Right
texLabel.ZIndex = 4
texLabel.Parent = frame

local fxLabel = Instance.new("TextLabel")
fxLabel.Size = UDim2.new(1, -32, 0, 16)
fxLabel.Position = UDim2.new(0, 16, 0, 68)
fxLabel.BackgroundTransparency = 1
fxLabel.Text = "✦  " .. effectsDisabled .. " fx | ⚡ " .. assetsPreloaded .. " preloaded"
fxLabel.TextColor3 = Color3.fromRGB(110, 110, 130)
fxLabel.Font = Enum.Font.Gotham
fxLabel.TextSize = 11
fxLabel.TextXAlignment = Enum.TextXAlignment.Left
fxLabel.ZIndex = 4
fxLabel.Parent = frame

-- Dismiss & Fade Function
local function dismissWidget()
    if not gui or not gui.Parent then return end
    local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("Frame") then
            TweenService:Create(child, fadeInfo, {BackgroundTransparency = 1}):Play()
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(child, fadeInfo, {TextTransparency = 1}):Play()
        end
    end
    task.delay(0.55, function()
        if gui then gui:Destroy() end
    end)
end

closeBtn.MouseButton1Click:Connect(dismissWidget)
mountGui(gui)

-- Automatically fade out and destroy after configured display time[cite: 2]
task.delay(CONFIG.DISPLAY_TIME, dismissWidget)