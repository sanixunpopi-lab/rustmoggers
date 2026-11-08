--[[ Hook Fust V23 - RightShift + Fullbright(CC) ]]
print("[HF] V23 START")

local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not WindUI then pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end) end
if not WindUI then warn("[HF] WindUI fail"); return end
print("[HF] WindUI OK")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

-- ============ CONFIG ============
local Config = {
    AimbotEnabled = false, FOV = 200, Smoothness = 0.25,
    Prediction = true, TeamCheck = false, VisibleAim = false,
    AimbotMethod = "Camera",
    ESPEnabled = false, ESPMaxDist = 1500, ESPColorHex = "#FF3232",
    ESPWeapon = false, ESPHealth = true,
    ChamsEnabled = false, ChamsColorHex = "#FF00FF",
    CrossEnabled = false, CrossType = 1, CrossColorHex = "#00FFFF",
    Fullbright = false, FullbrightIntensity = 100,
    RemoveGrass = false, PotatoGraphics = false,
    PanicKey = Enum.KeyCode.End,
}
local Binds = { Aimbot = Enum.UserInputType.MouseButton2 }
local State = { HoldingKey = false, Unloaded = false, MenuOpen = true }
local Connections = {}

local function Hex2Color(h)
    if not h then return Color3.fromRGB(255,50,50) end
    h = tostring(h):gsub("#","")
    if #h == 6 then
        local r,g,b = h:match("(%x%x)(%x%x)(%x%x)")
        if r then return Color3.fromRGB(tonumber(r,16),tonumber(g,16),tonumber(b,16)) end
    end
    return Color3.fromRGB(255,50,50)
end
local ESPColor = Hex2Color(Config.ESPColorHex)
local CrossColor = Hex2Color(Config.CrossColorHex)
local ChamsColor = Hex2Color(Config.ChamsColorHex)

-- ============ SCREEN GUI ============
local VisualGui = Instance.new("ScreenGui")
VisualGui.Name = "HookFustVisuals"
VisualGui.ResetOnSpawn = false
VisualGui.DisplayOrder = 999999
VisualGui.IgnoreGuiInset = true
VisualGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if gethui then VisualGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(VisualGui); VisualGui.Parent = game:GetService("CoreGui")
    else VisualGui.Parent = game:GetService("CoreGui") end
end)
if not VisualGui.Parent then VisualGui.Parent = LP:WaitForChild("PlayerGui") end

-- ============ FOV CIRCLE ============
local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
FOVFrame.Position = UDim2.new(0.5, -Config.FOV, 0.5, -Config.FOV)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Visible = false
FOVFrame.ZIndex = 1
FOVFrame.Parent = VisualGui
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(80, 120, 255)
FOVStroke.Thickness = 2
FOVStroke.Parent = FOVFrame

-- ============ CROSSHAIR ============
local CrossFrames = {}
for i = 1, 8 do
    local f = Instance.new("Frame")
    f.BackgroundColor3 = CrossColor
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 3
    f.Parent = VisualGui
    CrossFrames[i] = f
end
local CrossDotFrame = Instance.new("Frame")
CrossDotFrame.Size = UDim2.new(0, 4, 0, 4)
CrossDotFrame.BackgroundColor3 = CrossColor
CrossDotFrame.BorderSizePixel = 0
CrossDotFrame.Visible = false
CrossDotFrame.ZIndex = 3
CrossDotFrame.Parent = VisualGui
Instance.new("UICorner", CrossDotFrame).CornerRadius = UDim.new(1, 0)
local CrossCircleFrame = Instance.new("Frame")
CrossCircleFrame.Size = UDim2.new(0, 20, 0, 20)
CrossCircleFrame.BackgroundTransparency = 1
CrossCircleFrame.BorderSizePixel = 0
CrossCircleFrame.Visible = false
CrossCircleFrame.ZIndex = 3
CrossCircleFrame.Parent = VisualGui
Instance.new("UICorner", CrossCircleFrame).CornerRadius = UDim.new(1, 0)
local CrossCircleStroke = Instance.new("UIStroke")
CrossCircleStroke.Color = CrossColor
CrossCircleStroke.Thickness = 1.5
CrossCircleStroke.Parent = CrossCircleFrame

local function UpdateCrosshair()
    if State.Unloaded then return end
    if not Config.CrossEnabled then
        for i = 1, 8 do CrossFrames[i].Visible = false end
        CrossDotFrame.Visible = false
        CrossCircleFrame.Visible = false
        return
    end
    for i = 1, 8 do CrossFrames[i].Visible = false end
    CrossDotFrame.Visible = false
    CrossCircleFrame.Visible = false
    if Config.CrossType == 1 then
        local gap, len, thick = 4, 7, 2
        CrossFrames[1].Size = UDim2.new(0, thick, 0, len); CrossFrames[1].Position = UDim2.new(0.5, -thick/2, 0.5, -gap-len); CrossFrames[1].Visible = true
        CrossFrames[2].Size = UDim2.new(0, thick, 0, len); CrossFrames[2].Position = UDim2.new(0.5, -thick/2, 0.5, gap); CrossFrames[2].Visible = true
        CrossFrames[3].Size = UDim2.new(0, len, 0, thick); CrossFrames[3].Position = UDim2.new(0.5, -gap-len, 0.5, -thick/2); CrossFrames[3].Visible = true
        CrossFrames[4].Size = UDim2.new(0, len, 0, thick); CrossFrames[4].Position = UDim2.new(0.5, gap, 0.5, -thick/2); CrossFrames[4].Visible = true
    elseif Config.CrossType == 2 then
        CrossDotFrame.Position = UDim2.new(0.5, -2, 0.5, -2); CrossDotFrame.Visible = true
    elseif Config.CrossType == 3 then
        CrossCircleFrame.Position = UDim2.new(0.5, -10, 0.5, -10); CrossCircleFrame.Visible = true
    elseif Config.CrossType == 4 then
        local L = 10
        for i = 1, 8 do
            local angle = (i - 1) * (math.pi * 2 / 8)
            local dx = math.cos(angle) * L
            local dy = math.sin(angle) * L
            local f = CrossFrames[i]
            f.Size = UDim2.new(0, math.abs(dx) + 2, 0, math.abs(dy) + 2)
            f.Position = UDim2.new(0.5, math.min(0, dx), 0.5, math.min(0, dy))
            f.Rotation = math.deg(angle)
            f.Visible = true
        end
    end
end

-- ============ ESP ELEMENTS ============
local ESPElements = {}
local function CreateESP(p)
    if ESPElements[p] then return ESPElements[p] end
    local e = {}
    e.box = Instance.new("Frame")
    e.box.BackgroundTransparency = 1; e.box.BorderSizePixel = 0
    e.box.Visible = false; e.box.ZIndex = 1; e.box.Parent = VisualGui
    e.stroke = Instance.new("UIStroke")
    e.stroke.Color = ESPColor; e.stroke.Thickness = 1.5; e.stroke.Parent = e.box
    local function mkTxt(color, size)
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold
        t.TextSize = size; t.TextColor3 = color
        t.TextStrokeTransparency = 0; t.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        t.Size = UDim2.new(0, 200, 0, size)
        t.AnchorPoint = Vector2.new(0.5, 0)
        t.Visible = false; t.ZIndex = 2; t.Parent = VisualGui
        return t
    end
    e.name = mkTxt(Color3.fromRGB(255,255,255), 14)
    e.dist = mkTxt(Color3.fromRGB(255,200,0), 12)
    e.hp = mkTxt(Color3.fromRGB(0,255,0), 12)
    ESPElements[p] = e
    return e
end
local function HideESP(e)
    if not e then return end
    e.box.Visible = false; e.name.Visible = false
    e.dist.Visible = false; e.hp.Visible = false
end

-- ============ CHAMS ============
local ChamsList = {}
local function UpdateChams()
    if State.Unloaded then return end
    if not Config.ChamsEnabled then
        for p, hl in pairs(ChamsList) do pcall(function() hl:Destroy() end); ChamsList[p] = nil end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local isEnemy = true
            if Config.TeamCheck and LP.Team and p.Team and LP.Team == p.Team then isEnemy = false end
            if hum and hum.Health > 0 and isEnemy then
                if not ChamsList[p] or not ChamsList[p].Parent then
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "HF_Chams"
                        hl.FillColor = ChamsColor; hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p.Character
                        ChamsList[p] = hl
                    end)
                else
                    ChamsList[p].FillColor = ChamsColor
                    ChamsList[p].Enabled = true
                end
            else
                if ChamsList[p] then pcall(function() ChamsList[p]:Destroy() end); ChamsList[p] = nil end
            end
        end
    end
    for p, hl in pairs(ChamsList) do
        if not p or not p.Parent or not p.Character then
            pcall(function() hl:Destroy() end); ChamsList[p] = nil
        end
    end
end

-- ============ FULLBRIGHT (только CC, без трогания Lighting) ============
-- Полностью НЕ трогаем Lighting.Brightness/Ambient/GlobalShadows — только
-- ColorCorrectionEffect. CC аддитивный, не конфликтует со скриптами игры
-- → мерцания не будет. Если яркости не хватает — поднимай слайдер.
local FCC = nil

local function ApplyFB()
    if not FCC then return end
    FCC.Brightness = Config.FullbrightIntensity / 100
end

local function EnableFullbright()
    if FCC then return end
    FCC = Instance.new("ColorCorrectionEffect")
    FCC.Name = "HF_FullbrightCC"
    FCC.Contrast = 0.05
    FCC.Saturation = 0
    FCC.TintColor = Color3.fromRGB(255, 255, 255)
    FCC.Parent = Lighting
    ApplyFB()
end

local function DisableFullbright()
    if FCC then pcall(function() FCC:Destroy() end); FCC = nil end
end

-- keep-alive: если игра удалит/отключит наш CC — вернём (без записи Lighting)
RunService.Heartbeat:Connect(function()
    if State.Unloaded or not Config.Fullbright then return end
    if not FCC or not FCC.Parent then
        EnableFullbright()
    elseif FCC.Enabled ~= true then
        pcall(function() FCC.Enabled = true end)
    end
end)

-- ============ POTATO GRAPHICS ============
local Potato = {
    Enabled = false, SavedLighting = nil,
    SavedEffects = setmetatable({}, {__mode = "k"}),
    SavedAtmos = setmetatable({}, {__mode = "k"}),
    SavedParticles = setmetatable({}, {__mode = "k"}),
    SavedLights = setmetatable({}, {__mode = "k"}),
    SavedClouds = setmetatable({}, {__mode = "k"}),
    SavedTerrain = nil, SavedQualityLevel = nil, DescConn = nil,
}
local function IsOurObject(obj) return obj.Name:sub(1,3) == "HF_" end
local function IsEffectObj(obj)
    return obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
end
local function DisableOneEffect(obj)
    if IsOurObject(obj) then return end
    if IsEffectObj(obj) then
        if Potato.SavedParticles[obj] == nil then Potato.SavedParticles[obj] = obj.Enabled end
        if obj.Enabled then pcall(function() obj.Enabled = false end) end
    elseif obj:IsA("Light") then
        if Potato.SavedLights[obj] == nil then Potato.SavedLights[obj] = obj.Enabled end
        if obj.Enabled then pcall(function() obj.Enabled = false end) end
    end
end

local function EnablePotato()
    if Potato.Enabled then return end
    Potato.Enabled = true
    Potato.SavedLighting = {
        GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, ClockTime = Lighting.ClockTime,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.FogEnd = 10000
        Lighting.FogStart = 10000
    end)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") and not IsOurObject(obj) then
            if Potato.SavedEffects[obj] == nil then Potato.SavedEffects[obj] = obj.Enabled end
            pcall(function() obj.Enabled = false end)
        elseif obj:IsA("Atmosphere") then
            if Potato.SavedAtmos[obj] == nil then
                Potato.SavedAtmos[obj] = {Density=obj.Density, Haze=obj.Haze, Glare=obj.Glare, Offset=obj.Offset}
            end
            pcall(function() obj.Density=0; obj.Haze=0; obj.Glare=0; obj.Offset=0 end)
        elseif obj:IsA("Clouds") then
            if Potato.SavedClouds[obj] == nil then Potato.SavedClouds[obj] = obj.Enabled end
            pcall(function() obj.Enabled = false end)
        end
    end
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then
        Potato.SavedTerrain = {Decoration=t.Decoration, WaterWaveSize=t.WaterWaveSize, WaterWaveSpeed=t.WaterWaveSpeed}
        pcall(function() t.Decoration=false; t.WaterWaveSize=0; t.WaterWaveSpeed=0 end)
    end
    pcall(function()
        local s = UserSettings():GetService("UserGameSettings")
        Potato.SavedQualityLevel = s.SavedQualityLevel
        s.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not IsOurObject(obj) then DisableOneEffect(obj) end
    end
    Potato.DescConn = workspace.DescendantAdded:Connect(function(obj)
        if Potato.Enabled and not State.Unloaded then DisableOneEffect(obj) end
    end)
end

local function DisablePotato()
    if not Potato.Enabled then return end
    Potato.Enabled = false
    if Potato.DescConn then pcall(function() Potato.DescConn:Disconnect() end); Potato.DescConn = nil end
    if Potato.SavedLighting then
        local s = Potato.SavedLighting
        pcall(function()
            Lighting.GlobalShadows=s.GlobalShadows; Lighting.Brightness=s.Brightness
            Lighting.Ambient=s.Ambient; Lighting.OutdoorAmbient=s.OutdoorAmbient
            Lighting.FogEnd=s.FogEnd; Lighting.FogStart=s.FogStart; Lighting.ClockTime=s.ClockTime
            Lighting.EnvironmentDiffuseScale=s.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale=s.EnvironmentSpecularScale
        end)
        Potato.SavedLighting = nil
    end
    for obj, was in pairs(Potato.SavedEffects) do if obj and obj.Parent then pcall(function() obj.Enabled=was end) end end
    Potato.SavedEffects = setmetatable({}, {__mode = "k"})
    for obj, d in pairs(Potato.SavedAtmos) do
        if obj and obj.Parent then pcall(function() obj.Density=d.Density; obj.Haze=d.Haze; obj.Glare=d.Glare; obj.Offset=d.Offset end) end
    end
    Potato.SavedAtmos = setmetatable({}, {__mode = "k"})
    for obj, was in pairs(Potato.SavedClouds) do if obj and obj.Parent then pcall(function() obj.Enabled=was end) end end
    Potato.SavedClouds = setmetatable({}, {__mode = "k"})
    for obj, was in pairs(Potato.SavedParticles) do if obj and obj.Parent and was then pcall(function() obj.Enabled=true end) end end
    Potato.SavedParticles = setmetatable({}, {__mode = "k"})
    for obj, was in pairs(Potato.SavedLights) do if obj and obj.Parent and was then pcall(function() obj.Enabled=true end) end end
    Potato.SavedLights = setmetatable({}, {__mode = "k"})
    if Potato.SavedTerrain then
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then pcall(function() t.Decoration=Potato.SavedTerrain.Decoration; t.WaterWaveSize=Potato.SavedTerrain.WaterWaveSize; t.WaterWaveSpeed=Potato.SavedTerrain.WaterWaveSpeed end) end
        Potato.SavedTerrain = nil
    end
    if Potato.SavedQualityLevel ~= nil then
        pcall(function()
            local s = UserSettings():GetService("UserGameSettings")
            s.SavedQualityLevel = Potato.SavedQualityLevel
        end)
        Potato.SavedQualityLevel = nil
    end
end

-- ============ WINDOW ============
local Window
local okW, errW = pcall(function()
    Window = WindUI:CreateWindow({ Title = "Hook Fust", Theme = "Dark", NewElements = true })
end)
if not okW or not Window then warn("[HF] Window fail:", errW); return end
print("[HF] Window OK")

local function ToggleMenu()
    State.MenuOpen = not State.MenuOpen
    pcall(function()
        if State.MenuOpen then
            if Window.Open then Window:Open() elseif Window.SetVisible then Window:SetVisible(true) end
        else
            if Window.Close then Window:Close() elseif Window.SetVisible then Window:SetVisible(false) end
        end
    end)
end

-- ============ AIMBOT TAB ============
local AimbotTab = Window:Tab({ Title = "Aimbot" })
local AimSec = AimbotTab:Section({ Title = "Aimbot" })
AimSec:Toggle({ Title = "Enable Aimbot", Value = Config.AimbotEnabled, Callback = function(v)
    Config.AimbotEnabled = v
    FOVFrame.Visible = v
end })
AimSec:Toggle({ Title = "Prediction", Value = Config.Prediction, Callback = function(v) Config.Prediction = v end })
AimSec:Toggle({ Title = "Team Check", Value = Config.TeamCheck, Callback = function(v) Config.TeamCheck = v end })
AimSec:Toggle({ Title = "Visible Check", Value = Config.VisibleAim, Callback = function(v) Config.VisibleAim = v end })
AimSec:Slider({ Title = "FOV", Value = { Min = 30, Max = 500, Default = Config.FOV }, Callback = function(v)
    Config.FOV = v
    FOVFrame.Size = UDim2.new(0, v*2, 0, v*2)
    FOVFrame.Position = UDim2.new(0.5, -v, 0.5, -v)
end })
AimSec:Slider({ Title = "Smoothness %", Value = { Min = 1, Max = 100, Default = 25 }, Callback = function(v) Config.Smoothness = v/100 end })
AimSec:Dropdown({ Title = "Method", Values = {"Camera","Mouse"}, Value = "Camera", Callback = function(v) Config.AimbotMethod = v end })

-- ============ VISUALS TAB ============
local VisTab = Window:Tab({ Title = "Visuals" })
local ESPSec = VisTab:Section({ Title = "Player ESP" })
ESPSec:Toggle({ Title = "ESP Boxes", Value = Config.ESPEnabled, Callback = function(v)
    Config.ESPEnabled = v
    if not v then for _, e in pairs(ESPElements) do HideESP(e) end end
end })
ESPSec:Toggle({ Title = "Health Text", Value = Config.ESPHealth, Callback = function(v) Config.ESPHealth = v end })
ESPSec:Input({ Title = "ESP Color", Value = Config.ESPColorHex, Placeholder = "#FF3232", Callback = function(t)
    local c = Hex2Color(t)
    if c then ESPColor = c; Config.ESPColorHex = t
        for _, e in pairs(ESPElements) do e.stroke.Color = c end
    end
end })
ESPSec:Slider({ Title = "Max Distance", Value = { Min = 100, Max = 3000, Default = Config.ESPMaxDist }, Callback = function(v) Config.ESPMaxDist = v end })

-- CHAMS (players)
local ChamsSec = VisTab:Section({ Title = "Chams (Players)" })
ChamsSec:Toggle({ Title = "Chams (сквозь стены)", Value = Config.ChamsEnabled, Callback = function(v)
    Config.ChamsEnabled = v
    if not v then for p, hl in pairs(ChamsList) do pcall(function() hl:Destroy() end); ChamsList[p] = nil end end
end })
ChamsSec:Input({ Title = "Chams Color", Value = Config.ChamsColorHex, Placeholder = "#FF00FF", Callback = function(t)
    local c = Hex2Color(t)
    if c then ChamsColor = c; Config.ChamsColorHex = t
        for _, hl in pairs(ChamsList) do hl.FillColor = c end
    end
end })

-- CROSSHAIR
local CrossSec = VisTab:Section({ Title = "Crosshair" })
CrossSec:Toggle({ Title = "Crosshair", Value = Config.CrossEnabled, Callback = function(v) Config.CrossEnabled = v end })
CrossSec:Dropdown({ Title = "Style", Values = {"Cross","Dot","Circle","Star"}, Value = "Cross", Callback = function(v)
    if v == "Cross" then Config.CrossType = 1
    elseif v == "Dot" then Config.CrossType = 2
    elseif v == "Circle" then Config.CrossType = 3
    elseif v == "Star" then Config.CrossType = 4 end
end })
CrossSec:Input({ Title = "Color", Value = Config.CrossColorHex, Placeholder = "#00FFFF", Callback = function(t)
    local c = Hex2Color(t)
    if c then CrossColor = c; Config.CrossColorHex = t
        for i = 1, 8 do CrossFrames[i].BackgroundColor3 = c end
        CrossDotFrame.BackgroundColor3 = c
        CrossCircleStroke.Color = c
    end
end })

-- ============ OPTIMIZER TAB ============
local OptTab = Window:Tab({ Title = "Optimizer" })
local OptSec = OptTab:Section({ Title = "Optimization" })
OptSec:Toggle({ Title = "Fullbright (CC only, no flicker)", Value = Config.Fullbright, Callback = function(v)
    Config.Fullbright = v
    if v then EnableFullbright() else DisableFullbright() end
end })
OptSec:Slider({ Title = "Fullbright % (20-300)", Value = { Min = 20, Max = 300, Default = 100 }, Callback = function(v)
    Config.FullbrightIntensity = v
    ApplyFB()
end })
OptSec:Toggle({ Title = "Remove Grass", Value = Config.RemoveGrass, Callback = function(v)
    Config.RemoveGrass = v
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then pcall(function() t.Decoration = not v end) end
end })
OptSec:Toggle({ Title = "Potato Graphics", Value = Config.PotatoGraphics, Callback = function(v)
    Config.PotatoGraphics = v
    if v then EnablePotato() else DisablePotato() end
end })

-- ============ MISC TAB ============
local MiscTab = Window:Tab({ Title = "Misc" })
local MiscSec = MiscTab:Section({ Title = "Misc" })
MiscSec:Keybind({ Title = "Panic Key", Value = "End", Callback = function(v)
    local ok, e = pcall(function() return Enum.KeyCode[tostring(v)] end)
    if ok and e then Config.PanicKey = e end
end })
MiscSec:Button({ Title = "UNLOAD (Panic)", Callback = function()
    State.Unloaded = true
    for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
    Config.Fullbright = false; DisableFullbright()
    Config.PotatoGraphics = false; DisablePotato()
    for p, hl in pairs(ChamsList) do pcall(function() hl:Destroy() end) end
    ChamsList = {}
    pcall(function() VisualGui:Destroy() end)
    pcall(function() Window:Destroy() end)
    print("[HF] Unloaded")
end })

-- ============ ESP HELPER ============
local function IsEnemy(p)
    if p == LP then return false end
    if not Config.TeamCheck then return true end
    if not LP.Team or not p.Team then return true end
    return LP.Team ~= p.Team
end

-- ============ AIMBOT LOOP ============
local cam = workspace.CurrentCamera
RunService.RenderStepped:Connect(function()
    if State.Unloaded then return end
    cam = workspace.CurrentCamera
    if not cam then return end
    if Config.AimbotEnabled then
        FOVFrame.Visible = true
        FOVFrame.Position = UDim2.new(0.5, -Config.FOV, 0.5, -Config.FOV)
        FOVFrame.Size = UDim2.new(0, Config.FOV*2, 0, Config.FOV*2)
    else
        FOVFrame.Visible = false
    end
    if not Config.AimbotEnabled or not State.HoldingKey then return end
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return end
    local bestT, bestD = nil, Config.FOV
    local sc = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and IsEnemy(p) and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            if h and h.Health > 0 and hrp and head then
                local tp = (head.Position + hrp.Position) / 2
                local skip = false
                if Config.VisibleAim then
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    rp.FilterDescendantsInstances = {myChar, p.Character}
                    if workspace:Raycast(cam.CFrame.Position, tp - cam.CFrame.Position, rp) then skip = true end
                end
                if not skip then
                    local sp, on = cam:WorldToViewportPoint(tp)
                    if on and sp.Z > 0 then
                        local d = (sc - Vector2.new(sp.X, sp.Y)).Magnitude
                        if d < bestD then
                            bestD = d
                            local fp = tp
                            if Config.Prediction then
                                local wd = (cam.CFrame.Position - tp).Magnitude
                                fp = fp + hrp.AssemblyLinearVelocity * (wd * 0.0006)
                            end
                            bestT = {pos = fp, screen = sp}
                        end
                    end
                end
            end
        end
    end
    if bestT then
        local tcf = CFrame.new(cam.CFrame.Position, bestT.pos)
        cam.CFrame = cam.CFrame:Lerp(tcf, Config.Smoothness)
    end
end)

-- ============ CROSSHAIR ============
RunService.RenderStepped:Connect(function() UpdateCrosshair() end)

-- ============ ESP UPDATE ============
RunService.RenderStepped:Connect(function()
    if State.Unloaded then return end
    cam = workspace.CurrentCamera
    if not cam then return end
    if not Config.ESPEnabled then
        for _, e in pairs(ESPElements) do HideESP(e) end
        return
    end
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then
        for _, e in pairs(ESPElements) do HideESP(e) end
        return
    end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            if h and h.Health > 0 and hrp and head and IsEnemy(p) then
                local dist = (myHrp.Position - hrp.Position).Magnitude
                if dist <= Config.ESPMaxDist then
                    local e = CreateESP(p)
                    local sh, onH = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                    local sf, onF = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.7, 0))
                    if onH and onF and sh.Z > 0 and sf.Z > 0 then
                        local hgt = math.max(math.abs(sh.Y - sf.Y), 20)
                        local wdt = hgt * 0.55
                        local x = sh.X - wdt/2
                        local y = sh.Y
                        e.box.Position = UDim2.new(0, x, 0, y)
                        e.box.Size = UDim2.new(0, wdt, 0, hgt)
                        e.box.Visible = true
                        e.stroke.Color = ESPColor
                        e.name.Text = p.Name
                        e.name.Position = UDim2.new(0, sh.X, 0, y - 28)
                        e.name.Visible = true
                        e.dist.Text = "[" .. math.floor(dist) .. "m]"
                        e.dist.Position = UDim2.new(0, sh.X, 0, y - 14)
                        e.dist.Visible = true
                        if Config.ESPHealth then
                            e.hp.Text = "HP: " .. math.floor(h.Health)
                            e.hp.Position = UDim2.new(0, sh.X, 0, y + hgt + 5)
                            if h.Health > 50 then e.hp.TextColor3 = Color3.fromRGB(0,255,0)
                            elseif h.Health > 25 then e.hp.TextColor3 = Color3.fromRGB(255,200,0)
                            else e.hp.TextColor3 = Color3.fromRGB(255,50,50) end
                            e.hp.Visible = true
                        else e.hp.Visible = false end
                    else HideESP(e) end
                else
                    if ESPElements[p] then HideESP(ESPElements[p]) end
                end
            else
                if ESPElements[p] then HideESP(ESPElements[p]) end
            end
        end
    end
end)

-- ============ CHAMS UPDATE ============
RunService.Heartbeat:Connect(function() UpdateChams() end)

-- ============ INPUT ============
UIS.InputBegan:Connect(function(input, gp)
    if State.Unloaded then return end
    if input.KeyCode == Config.PanicKey then
        State.Unloaded = true
        for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
        Config.Fullbright = false; DisableFullbright()
        Config.PotatoGraphics = false; DisablePotato()
        for p, hl in pairs(ChamsList) do pcall(function() hl:Destroy() end) end
        ChamsList = {}
        pcall(function() VisualGui:Destroy() end)
        pcall(function() Window:Destroy() end)
        return
    end
    if input.KeyCode == Enum.KeyCode.RightShift then ToggleMenu(); return end
    if gp then return end
    if input.UserInputType == Binds.Aimbot then State.HoldingKey = true end
end)
UIS.InputEnded:Connect(function(input)
    if State.Unloaded then return end
    if input.UserInputType == Binds.Aimbot then State.HoldingKey = false end
end)

print("[HF] ============ V23 READY ============")
pcall(function() WindUI:Notify({ Title = "V23", Content = "Fullbright → CC only (без мерцания) | Jump/WeaponChams удалены", Icon = "check", Duration = 5 }) end)
