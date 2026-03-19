-- [[ STAPE HUB - UNIVERSAL V2.5 ]]
-- Credits: Created by SINEY
-- UPDATED: NEW API SYSTEM (RAILWAY) + AUTO-WAKEUP + HWID LOCK + AUTO-FARM + AUTO-QUEST (STRICT)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIGURATION API ]]
local api_url = "https://stapebackend-production.up.railway.app/check" 
local FILE_NAME = "stape_config.json"

-- [[ RÉCUPÉRATION DU HWID ]]
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- [[ FONCTIONS DE SAUVEGARDE ]]
local function SaveKeyLocal(key)
    local data = {key = key}
    writefile(FILE_NAME, HttpService:JSONEncode(data))
end

local function GetSavedKey()
    if isfile(FILE_NAME) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
        if success then return data.key end
    end
    return nil
end

-- [[ UI DE CONNEXION ]]
if game:GetService("CoreGui"):FindFirstChild("StapeLogin") then game:GetService("CoreGui").StapeLogin:Destroy() end
local LoginGui = Instance.new("ScreenGui", game:GetService("CoreGui")); LoginGui.Name = "StapeLogin"

local LoginFrame = Instance.new("Frame", LoginGui)
LoginFrame.Size = UDim2.new(0, 300, 0, 180); LoginFrame.Position = UDim2.new(0.5, -150, 0.5, -90); LoginFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); LoginFrame.BorderSizePixel = 0; Instance.new("UICorner", LoginFrame)
local LoginStroke = Instance.new("UIStroke", LoginFrame); LoginStroke.Color = Color3.fromRGB(150, 0, 255); LoginStroke.Thickness = 2

local LoginTitle = Instance.new("TextLabel", LoginFrame)
LoginTitle.Size = UDim2.new(1, 0, 0, 40); LoginTitle.Text = "STAPE HUB - LOGIN"; LoginTitle.TextColor3 = Color3.new(1,1,1); LoginTitle.Font = "GothamBold"; LoginTitle.TextSize = 14; LoginTitle.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginFrame)
KeyInput.Size = UDim2.new(0, 240, 0, 35); KeyInput.Position = UDim2.new(0.5, -120, 0.4, 0); KeyInput.PlaceholderText = "Entrez votre clé..."; KeyInput.Text = ""; KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25); KeyInput.TextColor3 = Color3.new(1,1,1); KeyInput.Font = "Gotham"; KeyInput.TextSize = 12; Instance.new("UICorner", KeyInput)

local LoginBtn = Instance.new("TextButton", LoginFrame)
LoginBtn.Size = UDim2.new(0, 240, 0, 35); LoginBtn.Position = UDim2.new(0.5, -120, 0.7, 0); LoginBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 200); LoginBtn.Text = "VÉRIFIER"; LoginBtn.TextColor3 = Color3.new(1,1,1); LoginBtn.Font = "GothamBold"; Instance.new("UICorner", LoginBtn)

-- [[ LANCEMENT DU CHEAT ]]
local function StartCheat(expiration)
    if LoginGui then LoginGui:Destroy() end
    
    -- Variables Globales
    _G.Aimbot = false; _G.TeamCheck = false; _G.VisibleCheck = true; _G.Prediction = 0.165
    _G.FOV_Visible = true; _G.FOV_Radius = 150; _G.Aimbot_Smoothing = 0.4
    _G.ESP_Enabled = false; _G.ESP_Skeleton = false; _G.ESP_Box = false; _G.Trackers_Enabled = false
    _G.FlyEnabled = false; _G.NoClip = false; _G.FreeCam = false; _G.GodMode = false
    _G.WalkSpeed = 16; _G.RunSpeed = 16; _G.NeoStrafe = false; _G.InfAmmo = false
    _G.RapidFire = false; _G.AutoReload = false; _G.AimbotKey = Enum.KeyCode.E

    -- Variables Auto-Farm
    _G.AutoFarm = false; _G.FarmDistance = 15; _G.FarmSpeed = 100
    _G.AutoQuest = true 

    _G.Colors = {
        Main = Color3.fromRGB(150, 0, 255), BG = Color3.fromRGB(10, 10, 10),
        Section = Color3.fromRGB(18, 18, 18), FOV = Color3.fromRGB(150, 0, 255),
        Box = Color3.fromRGB(255, 255, 255), Skeleton = Color3.fromRGB(255, 255, 255), Tracker = Color3.fromRGB(0, 255, 0)
    }

    local cameraRotation = Vector2.new(0, 0)

    -- LOGIQUE AUTO-FARM
    local function EquipFirstItem()
        local bp = LocalPlayer.Backpack:GetChildren()
        local char = LocalPlayer.Character
        if #bp > 0 and not char:FindFirstChildOfClass("Tool") then
            bp[1].Parent = char
        end
    end

    local function AutoAttack()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:Button1Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.05)
        vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end

    local function GetClosestMob()
        local target = nil
        local dist = math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Health > 0 and v.Parent ~= LocalPlayer.Character then
                local root = v.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if d < dist and d < 1200 then
                        dist = d; target = v.Parent
                    end
                end
            end
        end
        return target
    end

    local function TryGetQuest()
        if not _G.AutoQuest then return end
        for _, v in pairs(workspace:GetDescendants()) do
            -- CHANGEMENT ICI : Uniquement "Quest", on vire "Giver"
            if v.Name:find("Quest") and v:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < 150 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    local vu = game:GetService("VirtualUser")
                    vu:SetKeyDown("e") task.wait(0.1) vu:SetKeyUp("e")
                    vu:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
                    return true
                end
            end
        end
    end

    -- UI HUB PRINCIPAL
    if game:GetService("CoreGui"):FindFirstChild("STAPE_V25") then game:GetService("CoreGui").STAPE_V25:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui")); ScreenGui.Name = "STAPE_V25"
    local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 650, 0, 500); Main.Position = UDim2.new(0.5, -325, 0.5, -250); Main.BackgroundColor3 = _G.Colors.BG; Main.BorderSizePixel = 0; Instance.new("UICorner", Main)
    local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = _G.Colors.Main; MainStroke.Thickness = 1.5

    local function MakeDraggable(frame, parent)
        local dragging, dragInput, dragStart, startPos
        frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = parent.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
        frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
        UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    end

    local DragPart = Instance.new("Frame", Main); DragPart.Size = UDim2.new(1, 0, 0, 40); DragPart.BackgroundTransparency = 1; MakeDraggable(DragPart, Main)
    local Header = Instance.new("TextLabel", Main); Header.Size = UDim2.new(1, -20, 0, 40); Header.Position = UDim2.new(0, 15, 0, 0); Header.BackgroundTransparency = 1; Header.Text = "STAPE HUB V2.5"; Header.TextColor3 = Color3.new(1,1,1); Header.Font = "GothamBold"; Header.TextSize = 14; Header.TextXAlignment = "Left"
    
    local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 150, 1, -40); Sidebar.Position = UDim2.new(0,0,0,40); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Sidebar.BorderSizePixel = 0
    local PageHolder = Instance.new("Frame", Main); PageHolder.Size = UDim2.new(1, -170, 1, -60); PageHolder.Position = UDim2.new(0, 160, 0, 50); PageHolder.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Pages = {}
    local function CreatePage(name)
        local p = Instance.new("ScrollingFrame", PageHolder); p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.ScrollBarThickness = 2; p.CanvasSize = UDim2.new(0,0,3.5,0)
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 10)
        local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(0, 140, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.Text = name:upper(); btn.TextColor3 = Color3.fromRGB(150, 150, 150); btn.Font = "GothamBold"; btn.TextSize = 10; Instance.new("UICorner", btn)
        local bS = Instance.new("UIStroke", btn); bS.Color = Color3.fromRGB(40,40,40)
        btn.MouseButton1Click:Connect(function()
            for _, pg in pairs(Pages) do pg.Visible = false end p.Visible = true
            for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150); b:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(40,40,40) end end
            btn.TextColor3 = _G.Colors.Main; bS.Color = _G.Colors.Main
        end)
        Pages[name] = p; return p
    end

    local function AddToggle(name, var, parent)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 35); f.BackgroundColor3 = _G.Colors.Section; Instance.new("UICorner", f)
        local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, -60, 1, 0); t.Position = UDim2.new(0, 10, 0, 0); t.Text = name:upper(); t.TextColor3 = Color3.fromRGB(200,200,200); t.Font = "GothamBold"; t.TextSize = 9; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
        local sw = Instance.new("Frame", f); sw.Size = UDim2.new(0, 34, 0, 18); sw.Position = UDim2.new(1, -44, 0.5, -9); sw.BackgroundColor3 = _G[var] and _G.Colors.Main or Color3.fromRGB(40,40,40); Instance.new("UICorner", sw).CornerRadius = UDim.new(0,10)
        local ball = Instance.new("Frame", sw); ball.Size = UDim2.new(0, 14, 0, 14); ball.Position = _G[var] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); ball.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", ball)
        local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Text = ""
        b.MouseButton1Click:Connect(function() _G[var] = not _G[var]; sw.BackgroundColor3 = _G[var] and _G.Colors.Main or Color3.fromRGB(40,40,40); ball:TweenPosition(_G[var] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.1) end)
    end

    local function AddSlider(name, var, min, max, parent, isFloat)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundColor3 = _G.Colors.Section; Instance.new("UICorner", f)
        local t = Instance.new("TextLabel", f); t.Text = name:upper(); t.Size = UDim2.new(1, -60, 0, 20); t.Position = UDim2.new(0, 10, 0, 5); t.TextColor3 = Color3.new(1,1,1); t.BackgroundTransparency = 1; t.Font = "GothamBold"; t.TextSize = 9; t.TextXAlignment = "Left"
        local vL = Instance.new("TextLabel", f); vL.Text = tostring(_G[var]); vL.Size = UDim2.new(0, 50, 0, 20); vL.Position = UDim2.new(1, -60, 0, 5); vL.TextColor3 = _G.Colors.Main; vL.BackgroundTransparency = 1; vL.Font = "GothamBold"; vL.TextSize = 9
        local bg = Instance.new("Frame", f); bg.Size = UDim2.new(1, -20, 0, 4); bg.Position = UDim2.new(0, 10, 0, 30); bg.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", bg)
        local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((_G[var]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = _G.Colors.Main; Instance.new("UICorner", fill)
        bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then local con; con = RunService.RenderStepped:Connect(function() local rel = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(rel, 0, 1, 0); local val = min + (rel * (max - min)); _G[var] = isFloat and (math.floor(val * 100) / 100) or math.floor(val); vL.Text = tostring(_G[var]) end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end end) end end)
    end

    -- PAGES
    local Combat = CreatePage("Combat"); AddToggle("Aimbot Active", "Aimbot", Combat); AddSlider("FOV Radius", "FOV_Radius", 10, 800, Combat, false)
    local Visuals = CreatePage("Visuals"); AddToggle("Master ESP", "ESP_Enabled", Visuals); AddToggle("Box ESP", "ESP_Box", Visuals)
    local PlayerP = CreatePage("Player"); AddSlider("WalkSpeed", "WalkSpeed", 16, 250, PlayerP, false); AddToggle("Fly Mode", "FlyEnabled", PlayerP)
    
    local AutoFarmPage = CreatePage("Auto Farm")
    AddToggle("Enable Auto Farm", "AutoFarm", AutoFarmPage)
    AddToggle("Strict Quest Mode", "AutoQuest", AutoFarmPage)
    AddSlider("Farm Height", "FarmDistance", 5, 40, AutoFarmPage, false)

    Pages["Combat"].Visible = true

    -- BOUCLE AUTO FARM + QUEST
    task.spawn(function()
        while true do
            task.wait()
            if _G.AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local mob = GetClosestMob()
                if mob then
                    EquipFirstItem()
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local targetPos = mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.FarmDistance, 0)
                    
                    hrp.CFrame = hrp.CFrame:Lerp(targetPos, 0.15)
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = CFrame.lookAt(hrp.Position, mob.HumanoidRootPart.Position)
                    
                    AutoAttack()
                else
                    TryGetQuest() 
                end
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end end)
end

-- [[ VÉRIFICATION RAILWAY ]]
local function CheckAccess(inputKey, isAuto)
    if not isAuto then LoginBtn.Text = "Vérification..." end
    local full_url = api_url .. "?key=" .. inputKey .. "&hwid=" .. HWID
    local success, response = pcall(function() return game:HttpGet(full_url) end)
    
    if success and response == "success" then
        if not isAuto then SaveKeyLocal(inputKey) end
        StartCheat(9999999999) 
    else
        if not isAuto then LoginBtn.Text = "ERREUR CLÉ/HWID" end
    end
end

local savedKey = GetSavedKey()
if savedKey then task.spawn(function() CheckAccess(savedKey, true) end) end

LoginBtn.MouseButton1Click:Connect(function()
    CheckAccess(KeyInput.Text:gsub("%s+", ""), false)
end)
