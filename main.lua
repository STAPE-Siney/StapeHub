-- [[ STAPE HUB - UNIVERSAL V2.5 ]]
-- Credits: Created by SINEY
-- UPDATED: NEW API SYSTEM (RAILWAY) + AUTO-WAKEUP + HWID LOCK + AUTO-FARM (BLOX FRUITS / KING LEGACY / KAISEN)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService") -- Ajouté pour le Fly Farm
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIGURATION API ]]
local api_url = "https://stapebackend-production.up.railway.app/check" -- ⚠️ METS TON LIEN RAILWAY ICI
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

-- [[ FONCTION AURA RARE ]]
local function ApplyRareAura(char)
    local part = char:WaitForChild("HumanoidRootPart")
    local aura = Instance.new("ParticleEmitter")
    aura.Name = "StapeRareAura"
    aura.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(50, 0, 100))
    aura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)})
    aura.Texture = "rbxassetid://6073700091" 
    aura.Lifetime = NumberRange.new(0.8, 1.5); aura.Rate = 45
    aura.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    aura.Parent = part
    warn("✨ STAPE HUB : Aura Rare Activée !")
end

-- [[ LANCEMENT DU CHEAT ]]
local function StartCheat(expiration)
    if LoginGui then LoginGui:Destroy() end
    print("Access Granted! Welcome, " .. LocalPlayer.Name)

    if expiration == 9999999999 then
        LocalPlayer.CharacterAdded:Connect(ApplyRareAura)
        if LocalPlayer.Character then ApplyRareAura(LocalPlayer.Character) end
    end

    -- Variables Globales
    _G.Aimbot = false; _G.TeamCheck = false; _G.VisibleCheck = true; _G.Prediction = 0.165
    _G.FOV_Visible = true; _G.FOV_Radius = 150; _G.Aimbot_Smoothing = 0.4
    _G.ESP_Enabled = false; _G.ESP_Skeleton = false; _G.ESP_Box = false; _G.Trackers_Enabled = false
    _G.FlyEnabled = false; _G.NoClip = false; _G.FreeCam = false; _G.GodMode = false
    _G.WalkSpeed = 16; _G.RunSpeed = 16; _G.NeoStrafe = false; _G.InfAmmo = false
    _G.RapidFire = false; _G.AutoReload = false; _G.AimbotKey = Enum.KeyCode.E

    -- Variables Auto-Farm
    _G.AutoFarm = false; _G.FarmDistance = 12; _G.FarmSpeed = 100
    _G.TargetName = "" 

    _G.Colors = {
        Main = Color3.fromRGB(150, 0, 255), BG = Color3.fromRGB(10, 10, 10),
        Section = Color3.fromRGB(18, 18, 18), FOV = Color3.fromRGB(150, 0, 255),
        Box = Color3.fromRGB(255, 255, 255), Skeleton = Color3.fromRGB(255, 255, 255), Tracker = Color3.fromRGB(0, 255, 0)
    }

    local cameraRotation = Vector2.new(0, 0)

    -- LOGIQUE AUTO-FARM (ADAPTÉE BLOX/KING/KAISEN)
    local function EquipFirstItem()
        local bp = LocalPlayer.Backpack:GetChildren()
        local char = LocalPlayer.Character
        if #bp > 0 and not char:FindFirstChildOfClass("Tool") then
            bp[1].Parent = char
        end
    end

    local function AutoAttack()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end

    local function TryGetQuest()
        if not _G.AutoFarm then return end
        for _, v in pairs(workspace:GetDescendants()) do
            -- On check "Quest" ou "Giver" pour Blox Fruits / King Legacy
            if (v.Name:find("Quest") or v.Name:find("Giver")) and v:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < 100 then
                    -- Se TP au PNJ de quête
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    -- Simuler interaction
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:SetKeyDown("e")
                    task.wait(0.1)
                    VirtualUser:SetKeyUp("e")
                    return true
                end
            end
        end
    end

    local function GetClosestMob()
        local target = nil
        local dist = math.huge
        
        -- Dossiers spécifiques aux jeux (Blox Fruits = Enemies, King Legacy = Mobs, Kaisen = NPCs)
        local folders = {
            workspace:FindFirstChild("Enemies"), 
            workspace:FindFirstChild("NPCs"), 
            workspace:FindFirstChild("Mobs"),
            workspace
        }
        
        for _, folder in pairs(folders) do
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Parent ~= LocalPlayer.Character then
                        local root = v:FindFirstChild("HumanoidRootPart")
                        if root then
                            local d = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                            if d < dist then
                                dist = d
                                target = v
                            end
                        end
                    end
                end
            end
        end
        return target
    end

    local function IsVisible(part)
        local char = LocalPlayer.Character
        if not char then return false end
        local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {char, part.Parent}
        local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
        return result == nil
    end

    local function MakeDraggable(frame, parent)
        local dragging, dragInput, dragStart, startPos
        frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = parent.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
        frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
        UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    end

    local function ApplyGunMods()
        if not (_G.InfAmmo or _G.RapidFire or _G.AutoReload) then return end
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            if _G.InfAmmo then for _, v in pairs(tool:GetDescendants()) do if v:IsA("IntValue") or v:IsA("NumberValue") then if v.Name:find("Ammo") or v.Name:find("Clip") or v.Name:find("Mag") then v.Value = 999 end end end end
            if _G.RapidFire then if tool:FindFirstChild("Delay") then tool.Delay.Value = 0 end if tool:FindFirstChild("Cooldown") then tool.Cooldown.Value = 0 end if tool:FindFirstChild("FireRate") then tool.FireRate.Value = 0 end end
            if _G.AutoReload and tool:FindFirstChild("Reloading") then tool.Reloading.Value = false end
        end
    end

    if game:GetService("CoreGui"):FindFirstChild("STAPE_V25") then game:GetService("CoreGui").STAPE_V25:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui")); ScreenGui.Name = "STAPE_V25"
    local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 650, 0, 500); Main.Position = UDim2.new(0.5, -325, 0.5, -250); Main.BackgroundColor3 = _G.Colors.BG; Main.BorderSizePixel = 0; Instance.new("UICorner", Main)
    local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = _G.Colors.Main; MainStroke.Thickness = 1.5

    local DragPart = Instance.new("Frame", Main); DragPart.Size = UDim2.new(1, 0, 0, 40); DragPart.BackgroundTransparency = 1; MakeDraggable(DragPart, Main)
    local Header = Instance.new("TextLabel", Main); Header.Size = UDim2.new(1, -20, 0, 40); Header.Position = UDim2.new(0, 15, 0, 0); Header.BackgroundTransparency = 1; Header.Text = "STAPE HUB V2.5"; Header.TextColor3 = Color3.new(1,1,1); Header.Font = "GothamBold"; Header.TextSize = 14; Header.TextXAlignment = "Left"
    local Credits = Instance.new("TextLabel", Main); Credits.Size = UDim2.new(0, 200, 0, 40); Credits.Position = UDim2.new(1, -210, 0, 0); Credits.BackgroundTransparency = 1; Credits.Text = "CREATED BY SINEY"; Credits.TextColor3 = _G.Colors.Main; Credits.Font = "GothamBold"; Credits.TextSize = 10; Credits.TextXAlignment = "Right"

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

    local function AddColorPick(name, role, parent)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(1,-10,0,35); f.BackgroundColor3 = _G.Colors.Section; Instance.new("UICorner", f)
        local t = Instance.new("TextLabel", f); t.Text = "SET "..name:upper().." COLOR"; t.Size = UDim2.new(1,-10,1,0); t.Position = UDim2.new(0,10,0,0); t.TextColor3 = _G.Colors[role]; t.Font = "GothamBold"; t.TextSize = 9; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
        local b = Instance.new("TextButton", f); b.Size = UDim2.new(1,0,1,0); b.BackgroundTransparency = 1; b.Text = ""
        b.MouseButton1Click:Connect(function() _G.Colors[role] = Color3.fromHSV(math.random(), 0.7, 1); t.TextColor3 = _G.Colors[role]; if role == "Main" then MainStroke.Color = _G.Colors[role]; Credits.TextColor3 = _G.Colors[role] end end)
    end

    -- PAGES ET ONGLETS
    local Combat = CreatePage("Combat"); AddToggle("Aimbot Active", "Aimbot", Combat); AddToggle("Team Check", "TeamCheck", Combat); AddToggle("Vis Check", "VisibleCheck", Combat); AddSlider("Smoothing", "Aimbot_Smoothing", 0.1, 1, Combat, true); AddSlider("Prediction", "Prediction", 0.01, 0.5, Combat, true); AddSlider("FOV Radius", "FOV_Radius", 10, 800, Combat, false)
    local GunMods = CreatePage("Gun Mods"); AddToggle("Infinite Ammo", "InfAmmo", GunMods); AddToggle("Rapid Fire", "RapidFire", GunMods); AddToggle("Auto Reload", "AutoReload", GunMods)
    local Visuals = CreatePage("Visuals"); AddToggle("Master ESP", "ESP_Enabled", Visuals); AddToggle("Box ESP", "ESP_Box", Visuals); AddToggle("Skeleton ESP", "ESP_Skeleton", Visuals); AddToggle("Trackers", "Trackers_Enabled", Visuals); AddToggle("Show FOV", "FOV_Visible", Visuals)
    local PlayerP = CreatePage("Player"); AddSlider("WalkSpeed", "WalkSpeed", 16, 250, PlayerP, false); AddSlider("RunSpeed", "RunSpeed", 16, 400, PlayerP, false); AddToggle("Fly Mode", "FlyEnabled", PlayerP); AddToggle("No Clip", "NoClip", PlayerP); AddToggle("Free Cam", "FreeCam", PlayerP); AddToggle("God Mode", "GodMode", PlayerP)
    
    local AutoFarmPage = CreatePage("Auto Farm")
    AddToggle("Enable Auto Farm", "AutoFarm", AutoFarmPage)
    AddSlider("Farm Distance", "FarmDistance", 1, 30, AutoFarmPage, false)
    AddSlider("Fly Speed", "FarmSpeed", 10, 300, AutoFarmPage, false)

    local Macros = CreatePage("Macros"); AddToggle("Neo Strafe", "NeoStrafe", Macros)
    local ColorsP = CreatePage("Colors"); AddColorPick("Main Theme", "Main", ColorsP); AddColorPick("FOV Circle", "FOV", ColorsP); AddColorPick("Box ESP", "Box", ColorsP); AddColorPick("Skeleton", "Skeleton", ColorsP); AddColorPick("Trackers", "Tracker", ColorsP)

    Pages["Combat"].Visible = true

    -- LOGIQUE AUTO FARM (LANCEMENT)
    task.spawn(function()
        while true do
            task.wait()
            if _G.AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Noclip automatique
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local mob = GetClosestMob()
                if mob and mob:FindFirstChild("HumanoidRootPart") then
                    EquipFirstItem()
                    
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local targetHrp = mob.HumanoidRootPart
                    
                    local targetPos = targetHrp.CFrame * CFrame.new(0, _G.FarmDistance, 0)
                    
                    hrp.CFrame = hrp.CFrame:Lerp(targetPos, 0.15)
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = CFrame.lookAt(hrp.Position, targetHrp.Position)
                    
                    AutoAttack()
                else
                    -- Si aucun mob, on tente de check s'il y a une quête proche
                    TryGetQuest()
                end
            end
        end
    end)

    -- Le reste de tes fonctions ESP et Boucles existantes...
    local function CreateESP(target)
        if target == LocalPlayer then return end
        local Drawings = { Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), Skeleton = {HtoT = Drawing.new("Line"), TtoLA = Drawing.new("Line"), TtoRA = Drawing.new("Line"), TtoLL = Drawing.new("Line"), TtoRL = Drawing.new("Line")} }
        local function Clean() Drawings.Box.Visible = false; Drawings.Tracer.Visible = false; for _, l in pairs(Drawings.Skeleton) do l.Visible = false end end
        local Connection; Connection = RunService.RenderStepped:Connect(function()
            local char = target.Character; local hum = char and char:FindFirstChild("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hum or not hrp or hum.Health <= 0 then Clean(); if not target.Parent then for _, d in pairs(Drawings) do if type(d) == "table" then for _, v in pairs(d) do v:Remove() end else d:Remove() end end Connection:Disconnect() end return end
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if _G.ESP_Enabled and onScreen then
                if _G.ESP_Box then Drawings.Box.Visible = true; Drawings.Box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z); Drawings.Box.Position = Vector2.new(pos.X - Drawings.Box.Size.X/2, pos.Y - Drawings.Box.Size.Y/2); Drawings.Box.Color = _G.Colors.Box else Drawings.Box.Visible = false end
                if _G.ESP_Skeleton then
                    local head = char:FindFirstChild("Head"); local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    if head and torso then
                        local hP = Camera:WorldToViewportPoint(head.Position); local tP = Camera:WorldToViewportPoint(torso.Position)
                        Drawings.Skeleton.HtoT.Visible = true; Drawings.Skeleton.HtoT.From = Vector2.new(hP.X, hP.Y); Drawings.Skeleton.HtoT.To = Vector2.new(tP.X, tP.Y); Drawings.Skeleton.HtoT.Color = _G.Colors.Skeleton
                        local limbs = {["LA"] = "Left Arm", ["RA"] = "Right Arm", ["LL"] = "Left Leg", ["RL"] = "Right Leg"}
                        for k, v in pairs(limbs) do local part = char:FindFirstChild(v) or char:FindFirstChild(v:gsub(" ", "Upper")); if part then Drawings.Skeleton["Tto"..k].Visible = true; Drawings.Skeleton["Tto"..k].From = Vector2.new(tP.X, tP.Y); Drawings.Skeleton["Tto"..k].To = Vector2.new(Camera:WorldToViewportPoint(part.Position).X, Camera:WorldToViewportPoint(part.Position).Y); Drawings.Skeleton["Tto"..k].Color = _G.Colors.Skeleton end end
                    end
                else for _, l in pairs(Drawings.Skeleton) do l.Visible = false end end
                if _G.Trackers_Enabled then Drawings.Tracer.Visible = true; Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); Drawings.Tracer.To = Vector2.new(pos.X, pos.Y); Drawings.Tracer.Color = _G.Colors.Tracker else Drawings.Tracer.Visible = false end
            else Clean() end
        end)
    end

    local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1.5; FOVCircle.NumSides = 60
    UserInputService.InputChanged:Connect(function(input) if _G.FreeCam and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Delta; cameraRotation = cameraRotation - Vector2.new(delta.X * 0.4, delta.Y * 0.4) end end)

    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = _G.FOV_Visible; FOVCircle.Radius = _G.FOV_Radius; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = _G.Colors.FOV
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid; local hrp = char.HumanoidRootPart
            if _G.FreeCam then
                Camera.CameraType = Enum.CameraType.Scriptable; UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                local rotX = CFrame.Angles(0, math.rad(cameraRotation.X), 0); local rotY = CFrame.Angles(math.rad(cameraRotation.Y), 0, 0)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position) * rotX * rotY
                local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4 or 1; local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.Z) then move += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then move += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Vector3.new(0,1,0) end
                Camera.CFrame = Camera.CFrame + (move * speed)
            else if Camera.CameraType ~= Enum.CameraType.Custom then Camera.CameraType = Enum.CameraType.Custom; UserInputService.MouseBehavior = Enum.MouseBehavior.Default end end
            
            if not _G.FreeCam and not _G.AutoFarm then
                hum.WalkSpeed = hum.MoveDirection.Magnitude > 0 and _G.RunSpeed or _G.WalkSpeed
                if _G.FlyEnabled then hrp.Velocity = Vector3.zero; local m = Vector3.zero; if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end; hrp.CFrame += m * 2 end
            end
            ApplyGunMods()
            if _G.GodMode then hum.Health = hum.MaxHealth end
            if _G.NeoStrafe and hum.FloorMaterial == Enum.Material.Air then hrp.Velocity = Vector3.new(hum.MoveDirection.X * 80, hrp.Velocity.Y, hum.MoveDirection.X * 80) end
        end
        if _G.Aimbot and UserInputService:IsKeyDown(_G.AimbotKey) then
            local target = nil; local dist = _G.FOV_Radius
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                    local h = p.Character.Head; if not _G.VisibleCheck or IsVisible(h) then
                        local pos, onScreen = Camera:WorldToViewportPoint(h.Position)
                        if onScreen then local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude; if mag < dist then target = p.Character; dist = mag end end
                    end
                end
            end
            if target then local lookAt = CFrame.new(Camera.CFrame.Position, target.Head.Position + (target.HumanoidRootPart.Velocity * _G.Prediction)); Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1.1 - _G.Aimbot_Smoothing) end
        end
    end)

    RunService.Stepped:Connect(function() if _G.NoClip and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum then hum:ChangeState(11) end; for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
    Players.PlayerAdded:Connect(CreateESP)
    UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end end)
end

-- [[ LOGIQUE DE VÉRIFICATION UNIFIÉE (RAILWAY) ]]
local function CheckAccess(inputKey, isAuto)
    if not isAuto then LoginBtn.Text = "Vérification..." end
    local full_url = api_url .. "?key=" .. inputKey .. "&hwid=" .. HWID
    local attempts = 0
    local max_attempts = 2
    while attempts < max_attempts do
        local success, response = pcall(function() return game:HttpGet(full_url) end)
        if success then
            if response == "success" then
                if not isAuto then SaveKeyLocal(inputKey) end
                StartCheat(9999999999) 
                return
            elseif response == "mismatch" then
                if not isAuto then LoginBtn.Text = "PC NON AUTORISÉ !" end
                return
            elseif response == "invalid" then
                if not isAuto then LoginBtn.Text = "CLÉ INVALIDE !" end
                if isfile(FILE_NAME) then delfile(FILE_NAME) end
                return
            end
        end
        attempts = attempts + 1
        task.wait(2)
    end
    if not isAuto then LoginBtn.Text = "SERVEUR OFFLINE" end
end

-- [[ LANCEMENT ]]
local savedKey = GetSavedKey()
if savedKey then task.spawn(function() CheckAccess(savedKey, true) end) end

LoginBtn.MouseButton1Click:Connect(function()
    local inputKey = KeyInput.Text:gsub("%s+", "") 
    if inputKey == "" then
        LoginBtn.Text = "ENTREZ UNE CLÉ !"; wait(2); LoginBtn.Text = "VÉRIFIER"
        return
    end
    CheckAccess(inputKey, false)
end)
