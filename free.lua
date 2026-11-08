--[[ Hook Fust Lite - Only Menu + ESP ]]
print("[HF] Lite START")

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
local LP = Players.LocalPlayer

-- ============ CONFIG ============
local Config = {
    ESPEnabled = true,
    ESPMaxDist = 1500,
    ESPColorHex = "#FF3232",
    ESPHealth = true,
    PanicKey = Enum.KeyCode.End,
}
local State = { Unloaded = false, MenuOpen = true }

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

-- ============ SCREEN GUI ============
local VisualGui = Instance.new("ScreenGui")
VisualGui.Name = "HookFustLite"
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

-- ============ ESP ============
local ESPElements = {}

local function CreateESP(p)
    if ESPElements[p] then return ESPElements[p] end
    local e = {}
    
    -- Бокс
    e.box = Instance.new("Frame")
    e.box.BackgroundTransparency = 1
    e.box.BorderSizePixel = 0
    e.box.Visible = false
    e.box.ZIndex = 1
    e.box.Parent = VisualGui
    
    e.stroke = Instance.new("UIStroke")
    e.stroke.Color = ESPColor
    e.stroke.Thickness = 1.5
    e.stroke.Parent = e.box
    
    -- Текст
    local function mkTxt(color, size)
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.TextSize = size
        t.TextColor3 = color
        t.TextStrokeTransparency = 0
        t.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        t.Size = UDim2.new(0, 200, 0, size)
        t.AnchorPoint = Vector2.new(0.5, 0)
        t.Visible = false
        t.ZIndex = 2
        t.Parent = VisualGui
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
    e.box.Visible = false
    e.name.Visible = false
    e.dist.Visible = false
    e.hp.Visible = false
end

-- ============ WINDOW ============
local Window
local okW, errW = pcall(function()
    Window = WindUI:CreateWindow({ Title = "Hook Fust Lite", Theme = "Dark", NewElements = true })
end)
if not okW or not Window then warn("[HF] Window fail:", errW); return end

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

-- ============ UI TAB ============
local VisTab = Window:Tab({ Title = "Visuals" })
local ESPSec = VisTab:Section({ Title = "Player ESP" })

ESPSec:Toggle({ Title = "Enable ESP", Value = Config.ESPEnabled, Callback = function(v)
    Config.ESPEnabled = v
    if not v then
        for _, e in pairs(ESPElements) do HideESP(e) end
    end
end })

ESPSec:Toggle({ Title = "Show Health", Value = Config.ESPHealth, Callback = function(v) 
    Config.ESPHealth = v 
end })

ESPSec:Slider({ Title = "Max Distance", Value = { Min = 100, Max = 3000, Default = Config.ESPMaxDist }, Callback = function(v) 
    Config.ESPMaxDist = v 
end })

ESPSec:Input({ Title = "ESP Color", Value = Config.ESPColorHex, Placeholder = "#FF3232", Callback = function(t)
    local c = Hex2Color(t)
    if c then
        ESPColor = c
        Config.ESPColorHex = t
        for _, e in pairs(ESPElements) do e.stroke.Color = c end
    end
end })

-- Кнопка выгрузки
VisTab:Button({ Title = "Unload Script", Callback = function()
    State.Unloaded = true
    pcall(function() VisualGui:Destroy() end)
    pcall(function() Window:Destroy() end)
end })

-- ============ ESP LOOP ============
local cam = workspace.CurrentCamera
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
            
            if h and h.Health > 0 and hrp and head then
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
                        
                        -- Обновляем бокс
                        e.box.Position = UDim2.new(0, x, 0, y)
                        e.box.Size = UDim2.new(0, wdt, 0, hgt)
                        e.box.Visible = true
                        e.stroke.Color = ESPColor
                        
                        -- Ник
                        e.name.Text = p.Name
                        e.name.Position = UDim2.new(0, sh.X, 0, y - 28)
                        e.name.Visible = true
                        
                        -- Дистанция
                        e.dist.Text = "[" .. math.floor(dist) .. "m]"
                        e.dist.Position = UDim2.new(0, sh.X, 0, y - 14)
                        e.dist.Visible = true
                        
                        -- Здоровье
                        if Config.ESPHealth then
                            e.hp.Text = "HP: " .. math.floor(h.Health)
                            e.hp.Position = UDim2.new(0, sh.X, 0, y + hgt + 5)
                            if h.Health > 50 then e.hp.TextColor3 = Color3.fromRGB(0,255,0)
                            elseif h.Health > 25 then e.hp.TextColor3 = Color3.fromRGB(255,200,0)
                            else e.hp.TextColor3 = Color3.fromRGB(255,50,50) end
                            e.hp.Visible = true
                        else
                            e.hp.Visible = false
                        end
                    else
                        HideESP(e)
                    end
                else
                    if ESPElements[p] then HideESP(ESPElements[p]) end
                end
            else
                if ESPElements[p] then HideESP(ESPElements[p]) end
            end
        end
    end
end)

-- ============ INPUT ============
UIS.InputBegan:Connect(function(input, gp)
    if State.Unloaded then return end
    
    -- Паника (выгрузка)
    if input.KeyCode == Config.PanicKey then
        State.Unloaded = true
        pcall(function() VisualGui:Destroy() end)
        pcall(function() Window:Destroy() end)
        return
    end
    
    -- Открытие/закрытие меню на RightShift
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu()
        return
    end
end)

print("[HF] ============ LITE READY ============")
pcall(function() WindUI:Notify({ Title = "Lite", Content = "RightShift = меню | End = выгрузить", Icon = "check", Duration = 5 }) end)
