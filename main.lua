-- [[ STAPE HUB - UNIVERSAL V2.5 (FLUENT EDITION) ]]
-- Credits: Created by SINEY

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CHARGEMENT DE FLUENT ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ VARIABLES GLOBALES ]]
_G.Aimbot = false
_G.TeamCheck = false
_G.VisibleCheck = true
_G.Prediction = 0.165
_G.FOV_Visible = true
_G.FOV_Radius = 150
_G.Aimbot_Smoothing = 0.4
_G.AimbotKey = Enum.KeyCode.E

_G.ESP_Enabled = false
_G.ESP_Skeleton = false
_G.ESP_Box = false
_G.Trackers_Enabled = false

_G.FlyEnabled = false
_G.NoClip = false
_G.FreeCam = false
_G.GodMode = false
_G.WalkSpeed = 16
_G.RunSpeed = 35
_G.NeoStrafe = false

_G.InfAmmo = false
_G.RapidFire = false
_G.AutoReload = false

_G.Colors = {
    FOV = Color3.fromRGB(150, 0, 255),
    Box = Color3.fromRGB(255, 255, 255),
    Skeleton = Color3.fromRGB(255, 255, 255),
    Tracker = Color3.fromRGB(0, 255, 0)
}

local cameraRotation = Vector2.new(0, 0)

-- [[ AURA RARE ]]
local function ApplyRareAura(char)
    if not char then return end
    local part = char:WaitForChild("HumanoidRootPart", 5)
    if not part or part:FindFirstChild("StapeRareAura") then return end
    
    local aura = Instance.new("ParticleEmitter")
    aura.Name = "StapeRareAura"
    aura.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(50, 0, 100))
    aura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)})
    aura.Texture = "rbxassetid://6073700091" 
    aura.Lifetime = NumberRange.new(0.8, 1.5)
    aura.Rate = 45
    aura.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    aura.Parent = part
end

LocalPlayer.CharacterAdded:Connect(ApplyRareAura)
if LocalPlayer.Character then ApplyRareAura(LocalPlayer.Character) end

-- [[ FONCTIONS LOGIQUES ]]
local function IsVisible(part)
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, part.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function ApplyGunMods()
    if not (_G.InfAmmo or _G.RapidFire or _G.AutoReload) then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        if _G.InfAmmo then 
            for _, v in pairs(tool:GetDescendants()) do 
                if v:IsA("IntValue") or v:IsA("NumberValue") then 
                    if v.Name:find("Ammo") or v.Name:find("Clip") or v.Name:find("Mag") then v.Value = 999 end 
                end 
            end 
        end
        if _G.RapidFire then 
            if tool:FindFirstChild("Delay") then tool.Delay.Value = 0 end 
            if tool:FindFirstChild("Cooldown") then tool.Cooldown.Value = 0 end 
            if tool:FindFirstChild("FireRate") then tool.FireRate.Value = 0 end 
        end
        if _G.AutoReload and tool:FindFirstChild("Reloading") then tool.Reloading.Value = false end
    end
end

-- [[ INTERFACE FLUENT ]]
local Window = Fluent:CreateWindow({
    Title = "STAPE HUB",
    SubTitle = "by SINEY",
    TabWidth = 160,
    Size =UDim2.fromOffset(580, 460),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert -- Define ici la touche pour ouvrir/fermer
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    GunMods = Window:AddTab({ Title = "Gun Mods", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Macros = Window:AddTab({ Title = "Macros", Icon = "activity" }),
    Colors = Window:AddTab({ Title = "Colors", Icon = "palette" })
}

-- COMBAT
Tabs.Combat:AddToggle("AimbotToggle", { Title = "Aimbot Active", Default = _G.Aimbot, Callback = function(v) _G.Aimbot = v end })
Tabs.Combat:AddToggle("TeamCheckToggle", { Title = "Team Check", Default = _G.TeamCheck, Callback = function(v) _G.TeamCheck = v end })
Tabs.Combat:AddToggle("VisCheckToggle", { Title = "Visibility Check", Default = _G.VisibleCheck, Callback = function(v) _G.VisibleCheck = v end })

Tabs.Combat:AddSlider("SmoothSlider", { Title = "Smoothing", Default = _G.Aimbot_Smoothing, Min = 0.1, Max = 1, Rounding = 2, Callback = function(v) _G.Aimbot_Smoothing = v end })
Tabs.Combat:AddSlider("PredSlider", { Title = "Prediction", Default = _G.Prediction, Min = 0.01, Max = 0.5, Rounding = 3, Callback = function(v) _G.Prediction = v end })
Tabs.Combat:AddSlider("FOVSlider", { Title = "FOV Radius", Default = _G.FOV_Radius, Min = 10, Max = 800, Rounding = 0, Callback = function(v) _G.FOV_Radius = v end })

-- GUN MODS
Tabs.GunMods:AddToggle("InfAmmoToggle", { Title = "Infinite Ammo", Default = _G.InfAmmo, Callback = function(v) _G.InfAmmo = v end })
Tabs.GunMods:AddToggle("RapidToggle", { Title = "Rapid Fire", Default = _G.RapidFire, Callback = function(v) _G.RapidFire = v end })
Tabs.GunMods:AddToggle("ReloadToggle", { Title = "Auto Reload", Default = _G.AutoReload, Callback = function(v) _G.AutoReload = v end })

-- VISUALS
Tabs.Visuals:AddToggle("MasterESPToggle", { Title = "Master ESP", Default = _G.ESP_Enabled, Callback = function(v) _G.ESP_Enabled = v end })
Tabs.Visuals:AddToggle("BoxESPToggle", { Title = "Box ESP", Default = _G.ESP_Box, Callback = function(v) _G.ESP_Box = v end })
Tabs.Visuals:AddToggle("SkelESPToggle", { Title = "Skeleton ESP", Default = _G.ESP_Skeleton, Callback = function(v) _G.ESP_Skeleton = v end })
Tabs.Visuals:AddToggle("TracersToggle", { Title = "Trackers", Default = _G.Trackers_Enabled, Callback = function(v) _G.Trackers_Enabled = v end })
Tabs.Visuals:AddToggle("FOVVisToggle", { Title = "Show FOV Circle", Default = _G.FOV_Visible, Callback = function(v) _G.FOV_Visible = v end })

-- PLAYER
Tabs.Player:AddSlider("WalkSlider", { Title = "WalkSpeed", Default = _G.WalkSpeed, Min = 16, Max = 250, Rounding = 0, Callback = function(v) _G.WalkSpeed = v end })
Tabs.Player:AddSlider("RunSlider", { Title = "RunSpeed", Default = _G.RunSpeed, Min = 16, Max = 400, Rounding = 0, Callback = function(v) _G.RunSpeed = v end })
Tabs.Player:AddToggle("FlyToggle", { Title = "Fly Mode", Default = _G.FlyEnabled, Callback = function(v) _G.FlyEnabled = v end })
Tabs.Player:AddToggle("NoclipToggle", { Title = "No Clip", Default = _G.NoClip, Callback = function(v) _G.NoClip = v end })
Tabs.Player:AddToggle("FreecamToggle", { Title = "Free Cam", Default = _G.FreeCam, Callback = function(v) _G.FreeCam = v end })
Tabs.Player:AddToggle("GodToggle", { Title = "God Mode", Default = _G.GodMode, Callback = function(v) _G.GodMode = v end })

-- MACROS
Tabs.Macros:AddToggle("StrafeToggle", { Title = "Neo Strafe", Default = _G.NeoStrafe, Callback = function(v) _G.NeoStrafe = v end })

-- COLORS
Tabs.Colors:AddColorpicker("FOVColor", { Title = "FOV Circle", Default = _G.Colors.FOV, Callback = function(v) _G.Colors.FOV = v end })
Tabs.Colors:AddColorpicker("BoxColor", { Title = "Box ESP", Default = _G.Colors.Box, Callback = function(v) _G.Colors.Box = v end })
Tabs.Colors:AddColorpicker("SkelColor", { Title = "Skeleton ESP", Default = _G.Colors.Skeleton, Callback = function(v) _G.Colors.Skeleton = v end })
Tabs.Colors:AddColorpicker("TracerColor", { Title = "Trackers", Default = _G.Colors.Tracker, Callback = function(v) _G.Colors.Tracker = v end })

-- [[ RENDU ESP ]]
local function CreateESP(target)
    if target == LocalPlayer then return end
    local Drawings = { 
        Box = Drawing.new("Square"), 
        Tracer = Drawing.new("Line"), 
        Skeleton = {
            HtoT = Drawing.new("Line"), 
            TtoLA = Drawing.new("Line"), 
            TtoRA = Drawing.new("Line"), 
            TtoLL = Drawing.new("Line"), 
            TtoRL = Drawing.new("Line")
        } 
    }
    local function Clean() 
        Drawings.Box.Visible = false 
        Drawings.Tracer.Visible = false 
        for _, l in pairs(Drawings.Skeleton) do l.Visible = false end 
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        local char = target.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not char or not hum or not hrp or hum.Health <= 0 then 
            Clean()
            if not target.Parent then 
                for _, d in pairs(Drawings) do 
                    if type(d) == "table" then 
                        for _, v in pairs(d) do v:Remove() end 
                    else 
                        d:Remove() 
                    end 
                end 
                Connection:Disconnect() 
            end 
            return 
        end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if _G.ESP_Enabled and onScreen then
            if _G.ESP_Box then 
                Drawings.Box.Visible = true 
                Drawings.Box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z) 
                Drawings.Box.Position = Vector2.new(pos.X - Drawings.Box.Size.X/2, pos.Y - Drawings.Box.Size.Y/2) 
                Drawings.Box.Color = _G.Colors.Box 
            else 
                Drawings.Box.Visible = false 
            end

            if _G.ESP_Skeleton then
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if head and torso then
                    local hP = Camera:WorldToViewportPoint(head.Position)
                    local tP = Camera:WorldToViewportPoint(torso.Position)
                    Drawings.Skeleton.HtoT.Visible = true 
                    Drawings.Skeleton.HtoT.From = Vector2.new(hP.X, hP.Y) 
                    Drawings.Skeleton.HtoT.To = Vector2.new(tP.X, tP.Y) 
                    Drawings.Skeleton.HtoT.Color = _G.Colors.Skeleton

                    local limbs = {["LA"] = "Left Arm", ["RA"] = "Right Arm", ["LL"] = "Left Leg", ["RL"] = "Right Leg"}
                    for k, v in pairs(limbs) do 
                        local part = char:FindFirstChild(v) or char:FindFirstChild(v:gsub(" ", "Upper"))
                        if part then 
                            local partPos = Camera:WorldToViewportPoint(part.Position)
                            Drawings.Skeleton["Tto"..k].Visible = true 
                            Drawings.Skeleton["Tto"..k].From = Vector2.new(tP.X, tP.Y) 
                            Drawings.Skeleton["Tto"..k].To = Vector2.new(partPos.X, partPos.Y) 
                            Drawings.Skeleton["Tto"..k].Color = _G.Colors.Skeleton 
                        end 
                    end
                end
            else 
                for _, l in pairs(Drawings.Skeleton) do l.Visible = false end 
            end

            if _G.Trackers_Enabled then 
                Drawings.Tracer.Visible = true 
                Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) 
                Drawings.Tracer.To = Vector2.new(pos.X, pos.Y) 
                Drawings.Tracer.Color = _G.Colors.Tracker 
            else 
                Drawings.Tracer.Visible = false 
            end
        else 
            Clean() 
        end
    end)
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60

UserInputService.InputChanged:Connect(function(input) 
    if _G.FreeCam and input.UserInputType == Enum.UserInputType.MouseMovement then 
        local delta = input.Delta 
        cameraRotation = cameraRotation - Vector2.new(delta.X * 0.4, delta.Y * 0.4) 
    end 
end)

-- [[ BOUCLE PRINCIPALE ]]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.FOV_Visible 
    FOVCircle.Radius = _G.FOV_Radius 
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) 
    FOVCircle.Color = _G.Colors.FOV

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if _G.FreeCam then
            Camera.CameraType = Enum.CameraType.Scriptable 
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            local rotX = CFrame.Angles(0, math.rad(cameraRotation.X), 0) 
            local rotY = CFrame.Angles(math.rad(cameraRotation.Y), 0, 0)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * rotX * rotY

            local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4 or 1 
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.Z) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Vector3.new(0,1,0) end
            Camera.CFrame = Camera.CFrame + (move * speed)
        else 
            if Camera.CameraType ~= Enum.CameraType.Custom then 
                Camera.CameraType = Enum.CameraType.Custom 
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default 
            end 
        end

        if not _G.FreeCam and hrp then
            hum.WalkSpeed = hum.MoveDirection.Magnitude > 0 and _G.RunSpeed or _G.WalkSpeed
            if _G.FlyEnabled then 
                hrp.Velocity = Vector3.zero 
                local m = Vector3.zero 
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end 
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end 
                hrp.CFrame += m * 2 
            end
        end

        ApplyGunMods()
        if _G.GodMode then hum.Health = hum.MaxHealth end
        if _G.NeoStrafe and hum.FloorMaterial == Enum.Material.Air and hrp then 
            hrp.Velocity = Vector3.new(hum.MoveDirection.X * 80, hrp.Velocity.Y, hum.MoveDirection.Z * 80) 
        end
    end

    if _G.Aimbot and UserInputService:IsKeyDown(_G.AimbotKey) then
        local target = nil 
        local dist = _G.FOV_Radius
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not _G.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local h = p.Character.Head 
                    if not _G.VisibleCheck or IsVisible(h) then
                        local pos, onScreen = Camera:WorldToViewportPoint(h.Position)
                        if onScreen then 
                            local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude 
                            if mag < dist then target = p.Character; dist = mag end 
                        end
                    end
                end
            end
        end
        if target and target:FindFirstChild("HumanoidRootPart") then 
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Head.Position + (target.HumanoidRootPart.Velocity * _G.Prediction)) 
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1.1 - _G.Aimbot_Smoothing) 
        end
    end
end)

RunService.Stepped:Connect(function() 
    if _G.NoClip and LocalPlayer.Character then 
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid") 
        if hum then hum:ChangeState(11) end 
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do 
            if part:IsA("BasePart") then part.CanCollide = false end 
        end 
    end 
end)

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

Window:SelectTab(1)

Fluent:Notify({
    Title = "STAPE HUB V2.5",
    Content = "Script optimisé et chargé avec succès !",
    Duration = 5
})
