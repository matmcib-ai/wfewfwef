-- Ultra FPS Boost Optimizer (extracted from Elite3_FIXED.lua, verbatim engine)
-- Run once to enable. Run again to disable/restore. _G.setFPSBoostUltra(bool) also works.
local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting  = game:GetService("Lighting")
local Config = _G.UltraFPSConfig or { FPSBoostUltra = false }
_G.UltraFPSConfig = Config
local function saveConfig() end
local function setToggle() end
local OriginalTransparency = setmetatable({}, {__mode = "k"})
local _ultraDescendantConn = nil
local _ultraLightingConn = nil
local _ultraMaterialConn = nil
local _ultraThreads = {}
local _ultraConnections = {}
local function AddUltraThread(f)
	table.insert(_ultraThreads, task.spawn(f))
end
local function AddUltraConnection(c)
	table.insert(_ultraConnections, c)
end
local function SafeDestroyUltra(obj)
	if obj.Name == "Overhead" then return end
	pcall(function() obj:Destroy() end)
end
local ClothingClasses = {
	"Shirt","Pants","ShirtGraphic",
	"Accessory","Hat","HairAccessory",
	"FaceAccessory","NeckAccessory","ShoulderAccessory",
	"FrontAccessory","BackAccessory","WaistAccessory",
}
local function IsClothing(obj)
	for _, c in ipairs(ClothingClasses) do
		if obj:IsA(c) then return true end
	end
end
local function IsCharacterPart(obj)
	local parent = obj.Parent
	while parent and parent ~= Workspace do
		if parent:IsA("Model") and Players:GetPlayerFromCharacter(parent) then
			return true
		end
		parent = parent.Parent
	end
	return false
end
local function IsOutOfRange(obj)
	return false
end
local BASE_NAMES = {
	["baseplate"] = true, ["spawnlocation"] = true, ["spawn location"] = true, ["spawn"] = true,
}
local function IsBase(obj)
	if not obj:IsA("BasePart") then return false end
	local nameLower = obj.Name:lower()
	if BASE_NAMES[nameLower] then return true end
	for n in pairs(BASE_NAMES) do
		if nameLower:find(n, 1, true) then return true end
	end
	return false
end
local function IsInBase(obj)
	local p = obj.Parent
	while p and p ~= workspace do
		if IsBase(p) then return true end
		p = p.Parent
	end
	return false
end
local function MakeTransparentUltra(obj)
	pcall(function()
		if IsBase(obj) and not IsCharacterPart(obj) then
			if OriginalTransparency[obj] == nil then
				OriginalTransparency[obj] = {trans = obj.Transparency, shadow = obj.CastShadow}
			end
			obj.Transparency = 1
			obj.CastShadow   = false
		end
	end)
end
local function StripObjectUltra(obj)
	pcall(function()
		if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
			or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
			pcall(function() obj.Enabled = false end)
			SafeDestroyUltra(obj)
		elseif obj:IsA("SurfaceAppearance") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("BasePart") then
			obj.CastShadow      = false
			obj.Material        = Enum.Material.Plastic
			obj.MaterialVariant = ""
			obj.Reflectance     = 0
		end
	end)
end
local function CleanObjectUltra(obj)
	pcall(function()
		if obj:IsA("SurfaceAppearance") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
				SafeDestroyUltra(obj)
			end
		elseif obj:IsA("SpecialMesh") then
			obj.TextureId = ""
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
			SafeDestroyUltra(obj)
		elseif obj:IsA("BasePart") then
			obj.CastShadow      = false
			obj.Material        = Enum.Material.Plastic
			obj.MaterialVariant = ""
			obj.Reflectance     = 0
		end
	end)
end
local function StopAnimationsUltra(animator)
	pcall(function()
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			local isChar = false
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character and animator:IsDescendantOf(plr.Character) then
					isChar = true
					break
				end
			end
			if not isChar then
				track:Stop()
			end
		end
	end)
end
local function OptimizeCharacterUltra(char)
	if not char then return end
	task.spawn(function()
		task.wait(0.3)
		for _, obj in ipairs(char:GetDescendants()) do
			if IsClothing(obj) then
				SafeDestroyUltra(obj)
			else
				CleanObjectUltra(obj)
			end
		end
	end)
end
local function ApplyGreySkyUltra()
	pcall(function()
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA("Sky") then
				obj:Destroy()
			end
		end
		local sky        = Instance.new("Sky")
		sky.SkyboxBk     = ""
		sky.SkyboxDn     = ""
		sky.SkyboxFt     = ""
		sky.SkyboxLf     = ""
		sky.SkyboxRt     = ""
		sky.SkyboxUp     = ""
		sky.CelestialBodiesShown = false
		sky.Parent       = Lighting
	end)
end
local function OptimizeLightingUltra()
	Lighting.GlobalShadows            = false
	Lighting.FogEnd                   = 9e9
	Lighting.FogStart                 = 9e9
	Lighting.EnvironmentDiffuseScale  = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Brightness               = 1.5
	Lighting.Ambient                  = Color3.fromRGB(60, 60, 60)
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") then
			pcall(function() v.Enabled = false end)
		elseif v:IsA("Atmosphere") or v:IsA("Clouds") then
			v:Destroy()
		end
	end
	ApplyGreySkyUltra()
end
local function ApplyTerrainUltra()
	pcall(function()
		local T = Workspace.Terrain
		T.Decoration        = false
		T.WaterWaveSize     = 0
		T.WaterWaveSpeed    = 0
		T.WaterReflectance  = 0
		T.WaterTransparency = 1
	end)
end
local function setFPSBoostUltra(enabled)
    Config.FPSBoostUltra = enabled
    saveConfig()
    setToggle("FPS Boost Ultra", enabled)
    if enabled then
        pcall(function()
            settings().Rendering.QualityLevel        = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Physics.AllowSleep = true
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.PhysicsEnvironmentalThrottle or Enum.EnviromentalPhysicsThrottle.Skip
        end)
        pcall(setfpscap, 999)
        OptimizeLightingUltra()
        ApplyTerrainUltra()
        local allDesc = Workspace:GetDescendants()
        local BATCH_SIZE = 200
        for i = 1, #allDesc, BATCH_SIZE do
            local batchEnd = math.min(i + BATCH_SIZE - 1, #allDesc)
            for j = i, batchEnd do
                local obj = allDesc[j]
                if obj and obj.Parent then
                    if IsBase(obj) then
                        MakeTransparentUltra(obj)
                    elseif IsClothing(obj) then
                        SafeDestroyUltra(obj)
                    elseif IsInBase(obj) then
                    elseif IsCharacterPart(obj) then
                    elseif IsOutOfRange(obj) then
                        SafeDestroyUltra(obj)
                    else
                        CleanObjectUltra(obj)
                        StripObjectUltra(obj)
                        if obj:IsA("Animator") then
                            StopAnimationsUltra(obj)
                        end
                    end
                end
            end
            if i + BATCH_SIZE <= #allDesc then task.wait() end
        end
        AddUltraConnection(Workspace.DescendantAdded:Connect(function(obj)
            task.defer(function()
                if not Config.FPSBoostUltra then return end
                if IsBase(obj) then
                    MakeTransparentUltra(obj)
                    return
                end
                if IsClothing(obj) then
                    SafeDestroyUltra(obj)
                elseif IsInBase(obj) then
                elseif IsCharacterPart(obj) then
                elseif IsOutOfRange(obj) then
                    SafeDestroyUltra(obj)
                else
                    CleanObjectUltra(obj)
                    StripObjectUltra(obj)
                    if obj:IsA("Animator") then
                        StopAnimationsUltra(obj)
                    end
                end
            end)
        end))
        AddUltraConnection(Lighting.DescendantAdded:Connect(function(obj)
            if obj:IsA("PostEffect") then
                pcall(function() obj.Enabled = false end)
            elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                SafeDestroyUltra(obj)
            end
        end))
        local MaterialService = game:GetService("MaterialService")
        AddUltraConnection(MaterialService.DescendantAdded:Connect(function(obj)
            SafeDestroyUltra(obj)
        end))
        for _, plr in ipairs(Players:GetPlayers()) do
            OptimizeCharacterUltra(plr.Character)
            AddUltraConnection(plr.CharacterAdded:Connect(OptimizeCharacterUltra))
        end
        AddUltraConnection(Players.PlayerAdded:Connect(function(plr)
            AddUltraConnection(plr.CharacterAdded:Connect(OptimizeCharacterUltra))
        end))
    else
        for _, conn in ipairs(_ultraConnections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _ultraConnections = {}
        for _, thr in ipairs(_ultraThreads) do
            pcall(function() task.cancel(thr) end)
        end
        _ultraThreads = {}
        pcall(function()
            for part, data in pairs(OriginalTransparency) do
                if part and part.Parent then
                    part.Transparency = data.trans
                    part.CastShadow = data.shadow
                end
            end
        end)
        OriginalTransparency = {}
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Automatic
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Workspace.Terrain.WaterWaveSize = 0.15
            Workspace.Terrain.WaterWaveSpeed = 1
            Workspace.Terrain.WaterReflectance = 0.5
            Workspace.Terrain.WaterTransparency = 0.3
            Workspace.Terrain.Decoration = true
        end)
    end
end
_G.setFPSBoostUltra = setFPSBoostUltra
setFPSBoostUltra(not Config.FPSBoostUltra)
