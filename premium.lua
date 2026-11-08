--[[ Hook Fust V25 - Full Version (No Key System) ]]
print("[HF] V25 START")

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
    -- Aimbot
    AimbotEnabled = false, FOV = 200, Smoothness = 0.25,
    Prediction = true, TeamCheck = false, VisibleAim = false,
    -- ESP
    ESPEnabled = true, ESPMaxDist = 1500, ESPColorHex = "#FF3232", ESPHealth = true,
    -- Chams
    ChamsEnabled = false, ChamsColorHex = "#FF00FF",
    -- Fullbright
    Fullbright = false,
    -- Potato
    PotatoGraphics = false,
    -- Binds
    MenuKey = Enum.KeyCode.RightShift,
    ESPBindKey = Enum.KeyCode.None,
    PanicKey = Enum.KeyCode.End,
    -- Friends
    Friends = {},
}
local Binds = { Aimbot = Enum.UserInputType.MouseButton2 }
local State = { HoldingKey = false, Unloaded = false, MenuOpen = true }

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
local ChamsColor = Hex2Color(Config.ChamsColorHex)

-- ============ SCREEN GUI ============
local VisualGui = Instance.new("ScreenGui")
VisualGui.Name = "HookFustVisuals"
VisualGui.ResetOnSpawn = false
VisualGui.DisplayOrder = 999999
VisualGui.IgnoreGuiInset = true
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
FOVFrame.Parent = VisualGui
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(80, 120, 255)
FOVStroke.Thickness = 2
FOVStroke.Parent = FOVFrame

-- ============ ESP ELEMENTS ============
local ESPElements = {}
local function CreateESP(p)
    if ESPElements[p] then return ESPElements[p] end
    local e = {}
    e.box = Instance.new("Frame")
    e.box.BackgroundTransparency = 1; e.box.BorderSizePixel = 0
    e.box.Visible = false; e.box.Parent = VisualGui
    e.stroke = Instance.new("UIStroke")
    e.stroke.Color = ESPColor; e.stroke.Thickness = 1.5; e.stroke.Parent = e.box
    
    local function mkTxt(color, size)
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold
        t.TextSize = size; t.TextColor3 = color
        t.TextStrokeTransparency = 0; t.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        t.Size = UDim2.new(0, 200, 0, size); t.AnchorPoint = Vector2.new(0.5, 0)
        t.Visible = false; t.Parent = VisualGui
        return t
    end
    e.name = mkTxt(Color3.fromRGB(255,255,255), 14)
    e.dist = mkTxt(Color3.fromRGB(255,200,0), 12)
    e.hp = mkTxt(Color3.fromRGB(0,255,0), 12)
    ESPElements[p] = e
    return e
end
local function HideESP(e)
    if e then e.box.Visible = false; e.name.Visible = false; e.dist.Visible = false; e.hp.Visible = false end
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
        if p ~= LP and not Config.Friends[p.Name:lower()] and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not ChamsList[p] or not ChamsList[p].Parent then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = ChamsColor; hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.FillTransparency = 0.5; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = p.Character
                    ChamsList[p] = hl
                else
                    ChamsList[p].FillColor = ChamsColor
                end
            else
                if ChamsList[p] then pcall(function() ChamsList[p]:Destroy() end); ChamsList[p] = nil end
            end
        end
    end
end

-- ============ FULLBRIGHT ============
local OrigLighting = nil
local FCC = nil
local function EnableFullbright()
    if not OrigLighting then
        OrigLighting = { Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows }
    end
    pcall(function()
        Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180); Lighting.GlobalShadows = false
    end)
    if not FCC then
        FCC = Instance.new("ColorCorrectionEffect")
        FCC.Brightness = 0.15; FCC.Contrast = 0.05; FCC.Saturation = 0; FCC.Parent = Lighting
    end
end
local function DisableFullbright()
    if OrigLighting then
        pcall(function()
            Lighting.Brightness = OrigLighting.Brightness; Lighting.Ambient = OrigLighting.Ambient
            Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient; Lighting.GlobalShadows = OrigLighting.GlobalShadows
        end)
        OrigLighting = nil
    end
    if FCC then pcall(function() FCC:Destroy() end); FCC = nil end
end

-- ============ POTATO ============
local Potato = { Enabled = false, SavedLighting = nil, SavedEffects = setmetatable({}, {__mode = "k"}) }
local function EnablePotato()
    if Potato.Enabled then return end
    Potato.Enabled = true
    Potato.SavedLighting = { GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart }
    pcall(function() Lighting.GlobalShadows = false; Lighting.Brightness = 1; Lighting.FogEnd = 10000; Lighting.FogStart = 10000 end)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then Potato.SavedEffects[obj] = obj.Enabled; obj.Enabled = false end
    end
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then pcall(function() t.Decoration = false end) end
end
local function DisablePotato()
    if not Potato.Enabled then return end
    Potato.Enabled = false
    if Potato.SavedLighting then
        pcall(function()
            Lighting.GlobalShadows = Potato.SavedLighting.GlobalShadows
            Lighting.Brightness = Potato.SavedLighting.Brightness
            Lighting.Ambient = Potato.SavedLighting.Ambient
            Lighting.OutdoorAmbient = Potato.SavedLighting.OutdoorAmbient
            Lighting.FogEnd = Potato.SavedLighting.FogEnd
            Lighting.FogStart = Potato.SavedLighting.FogStart
        end)
        Potato.SavedLighting = nil
    end
    for obj, was in pairs(Potato.SavedEffects) do if obj and obj.Parent then obj.Enabled = was end end
    Potato.SavedEffects = setmetatable({}, {__mode = "k"})
end

-- ============ WINDOW ============
local Window
local okW, errW = pcall(function()
    Window = WindUI:CreateWindow({ Title = "Hook Fust V25", Theme = "Dark", NewElements = true })
end)
if not okW or not Window then warn("[HF] Window fail:", errW); return end

local function ToggleMenu()
    State.MenuOpen = not State.MenuOpen
    pcall(function()
        if State.MenuOpen then
            if Window.Open then Window:Open() else Window:SetVisible(true) end
        else
            if Window.Close then Window:Close() else Window:SetVisible(false) end
        end
    end)
end

-- ============ AIMBOT TAB ============
local AimbotTab = Window:Tab({ Title = "Aimbot" })
local AimSec = AimbotTab:Section({ Title = "Aimbot Settings" })
AimSec:Toggle({ Title = "Enable Aimbot", Value = Config.AimbotEnabled, Callback = function(v) Config.AimbotEnabled = v; FOVFrame.Visible = v end })
AimSec:Toggle({ Title = "Prediction", Value = Config.Prediction, Callback = function(v) Config.Prediction = v end })
AimSec:Toggle({ Title = "Team Check", Value = Config.TeamCheck, Callback = function(v) Config.TeamCheck = v end })
AimSec:Toggle({ Title = "Visible Check", Value = Config.VisibleAim, Callback = function(v) Config.VisibleAim = v end })
AimSec:Slider({ Title = "FOV", Value = { Min = 30, Max = 500, Default = Config.FOV }, Callback = function(v)
    Config.FOV = v; FOVFrame.Size = UDim2.new(0, v*2, 0, v*2); FOVFrame.Position = UDim2.new(0.5, -v, 0.5, -v)
end })
AimSec:Slider({ Title = "Smoothness %", Value = { Min = 1, Max = 100, Default = 25 }, Callback = function(v) Config.Smoothness = v/100 end })

-- ============ VISUALS TAB ============
local VisTab = Window:Tab({ Title = "Visuals" })
local ESPSec = VisTab:Section({ Title = "Player ESP" })
ESPSec:Toggle({ Title = "Enable ESP", Value = Config.ESPEnabled, Callback = function(v) Config.ESPEnabled = v end })
ESPSec:Toggle({ Title = "Show Health", Value = Config.ESPHealth, Callback = function(v) Config.ESPHealth = v end })
ESPSec:Slider({ Title = "Max Distance", Value = { Min = 100, Max = 3000, Default = Config.ESPMaxDist }, Callback = function(v) Config.ESPMaxDist = v end })
ESPSec:Input({ Title = "ESP Color", Value = Config.ESPColorHex, Placeholder = "#FF3232", Callback = function(t)
    local c = Hex2Color(t); if c then ESPColor = c; for _, e in pairs(ESPElements) do e.stroke.Color = c end end
end })

local ChamsSec = VisTab:Section({ Title = "Chams" })
ChamsSec:Toggle({ Title = "Enable Chams", Value = Config.ChamsEnabled, Callback = function(v) Config.ChamsEnabled = v end })
ChamsSec:Input({ Title = "Chams Color", Value = Config.ChamsColorHex, Placeholder = "#FF00FF", Callback = function(t)
    local c = Hex2Color(t); if c then ChamsColor = c end
end })

-- ============ FRIENDS TAB ============
local FriendTab = Window:Tab({ Title = "Friends" })
local FriendSec = FriendTab:Section({ Title = "Friendlist (Исключения из ESP/Aimbot)" })
FriendSec:Input({ Title = "Добавить друга", Value = "", Placeholder = "Введи ник и нажми Enter", Callback = function(t)
    if t and t ~= "" then
        Config.Friends[t:lower()] = true
        pcall(function() WindUI:Notify({ Title = "Friendlist", Content = "Добавлен: " .. t, Icon = "check", Duration = 2 }) end)
    end
end })
FriendSec:Button({ Title = "Добавить всех в сервере", Callback = function()
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then Config.Friends[p.Name:lower()] = true end end
    pcall(function() WindUI:Notify({ Title = "Friendlist", Content = "Все игроки добавлены", Icon = "check", Duration = 2 }) end)
end })
FriendSec:Button({ Title = "Очистить Friendlist", Callback = function()
    Config.Friends = {}
    pcall(function() WindUI:Notify({ Title = "Friendlist", Content = "Список очищен", Icon = "x", Duration = 2 }) end)
end })

-- ============ BINDS TAB ============
local BindTab = Window:Tab({ Title = "Binds" })
local BindSec = BindTab:Section({ Title = "Keybinds" })
BindSec:Keybind({ Title = "Меню (Open/Close)", Value = "RightShift", Callback = function(v)
    local ok, e = pcall(function() return Enum.KeyCode[tostring(v)] end); if ok and e then Config.MenuKey = e end
end })
BindSec:Keybind({ Title = "Toggle ESP", Value = "None", Callback = function(v)
    local ok, e = pcall(function() return Enum.KeyCode[tostring(v)] end); if ok and e then Config.ESPBindKey = e end
end })
BindSec:Keybind({ Title = "Panic Key (Выгрузка)", Value = "End", Callback = function(v)
    local ok, e = pcall(function() return Enum.KeyCode[tostring(v)] end); if ok and e then Config.PanicKey = e end
end })

-- ============ OPTIMIZER TAB ============
local OptTab = Window:Tab({ Title = "Optimizer" })
local OptSec = OptTab:Section({ Title = "Graphics" })
OptSec:Toggle({ Title = "Fullbright", Value = Config.Fullbright, Callback = function(v)
    Config.Fullbright = v; if v then EnableFullbright() else DisableFullbright() end
end })
OptSec:Toggle({ Title = "Potato Graphics", Value = Config.PotatoGraphics, Callback = function(v)
    Config.PotatoGraphics = v; if v then EnablePotato() else DisablePotato() end
end })

-- ============ MISC TAB ============
local MiscTab = Window:Tab({ Title = "Misc" })
local MiscSec = MiscTab:Section({ Title = "System" })
MiscSec:Button({ Title = "Unload Script", Callback = function()
    State.Unloaded = true
    pcall(function() VisualGui:Destroy() end)
    pcall(function() Window:Destroy() end)
end })

-- ============ ESP HELPER ============
local function IsEnemy(p)
    if p == LP then return false end
    if Config.Friends[p.Name:lower()] then return false end
    if Config.TeamCheck and LP.Team and p.Team and LP.Team == p.Team then return false end
    return true
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

    if Config.AimbotEnabled and State.HoldingKey then
        local myChar = LP.Character
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum.Health > 0 then
            local bestT, bestD = nil, Config.FOV
            local sc = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            for _, p in pairs(Players:GetPlayers()) do
                if IsEnemy(p) and p.Character then
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
                                    bestT = fp
                                end
                            end
                        end
                    end
                end
            end
            if bestT then
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, bestT), Config.Smoothness)
            end
        end
    end
end)

-- ============ ESP LOOP ============
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
        if IsEnemy(p) and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            if h and h.Health > 0 and hrp and head then
                local dist = (myHrp.Position - hrp.Position).Magnitude
                if dist <= Config.ESPMaxDist then
                    local e = CreateESP(p)
                    local sh, onH = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                    local sf, onF = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.7, 0))
                    if onH and onF and sh.Z > 0 and sf.Z > 0 then
                        local hgt = math.max(math.abs(sh.Y - sf.Y), 20)
                        local wdt = hgt * 0.55
                        e.box.Position = UDim2.new(0, sh.X - wdt/2, 0, sh.Y)
                        e.box.Size = UDim2.new(0, wdt, 0, hgt)
                        e.box.Visible = true
                        e.stroke.Color = ESPColor
                        e.name.Text = p.Name; e.name.Position = UDim2.new(0, sh.X, 0, sh.Y - 28); e.name.Visible = true
                        e.dist.Text = "[" .. math.floor(dist) .. "m]"; e.dist.Position = UDim2.new(0, sh.X, 0, sh.Y - 14); e.dist.Visible = true
                        if Config.ESPHealth then
                            e.hp.Text = "HP: " .. math.floor(h.Health); e.hp.Position = UDim2.new(0, sh.X, 0, sh.Y + hgt + 5); e.hp.Visible = true
                            if h.Health > 50 then e.hp.TextColor3 = Color3.fromRGB(0,255,0)
                            elseif h.Health > 25 then e.hp.TextColor3 = Color3.fromRGB(255,200,0)
                            else e.hp.TextColor3 = Color3.fromRGB(255,50,50) end
                        else e.hp.Visible = false end
                    else HideESP(e) end
                else
                    if ESPElements[p] then HideESP(ESPElements[p]) end
                end
            else
                if ESPElements[p] then HideESP(ESPElements[p]) end
            end
        else
            if ESPElements[p] then HideESP(ESPElements[p]) end
        end
    end
end)

RunService.Heartbeat:Connect(function() UpdateChams() end)

-- ============ INPUT ============
UIS.InputBegan:Connect(function(input, gp)
    if State.Unloaded then return end
    if input.KeyCode == Config.PanicKey then
        State.Unloaded = true
        pcall(function() VisualGui:Destroy() end)
        pcall(function() Window:Destroy() end)
        return
    end
    if input.KeyCode == Config.MenuKey then ToggleMenu(); return end
    if Config.ESPBindKey ~= Enum.KeyCode.None and input.KeyCode == Config.ESPBindKey then
        Config.ESPEnabled = not Config.ESPEnabled
        if not Config.ESPEnabled then
            for _, e in pairs(ESPElements) do HideESP(e) end
        end
        pcall(function() WindUI:Notify({ Title = "ESP", Content = Config.ESPEnabled and "Включен" or "Выключен", Icon = "check", Duration = 2 }) end)
        return
    end
    if gp then return end
    if input.UserInputType == Binds.Aimbot then State.HoldingKey = true end
end)

UIS.InputEnded:Connect(function(input)
    if State.Unloaded then return end
    if input.UserInputType == Binds.Aimbot then State.HoldingKey = false end
end)

print("[HF] ============ V25 READY ============")
pcall(function()
    WindUI:Notify({ Title = "V25", Content = "RightShift = меню | Все функции на месте", Icon = "check", Duration = 5 })
end)
