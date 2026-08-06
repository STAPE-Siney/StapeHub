-- ============================================================
-- STAPE HUB V3.0 — BUILT ON V2.5 BASE
-- Credits: Original by SINEY | Expanded V3
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

-- [[ FLUENT — same loader as V2.5, untouched ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ============================================================
-- GLOBALS — backward compatible + new
-- ============================================================
_G.Aimbot           = false
_G.TeamCheck        = false
_G.VisibleCheck     = true
_G.Prediction       = 0.165
_G.FOV_Visible      = true
_G.FOV_Radius       = 150
_G.Aimbot_Smoothing = 0.4
_G.AimbotKey        = Enum.KeyCode.E
_G.AimPart          = "Head"
_G.SilentAim        = false

_G.ESP_Enabled      = false
_G.ESP_Skeleton     = false
_G.ESP_Box          = false
_G.Trackers_Enabled = false
_G.ESP_Names        = false
_G.ESP_Distance     = false
_G.ESP_Health       = false
_G.ESP_MaxDist      = 1000
_G.ESP_TeamCheck    = false
_G.ESP_TeamColor    = false

_G.FlyEnabled       = false
_G.FlySpeed         = 40
_G.NoClip           = false
_G.FreeCam          = false
_G.GodMode          = false
_G.WalkSpeed        = 16
_G.RunSpeed         = 35
_G.JumpPower        = 50
_G.InfJump          = false
_G.NeoStrafe        = false
_G.BunnyHop         = false
_G.SpeedBoost       = false
_G.SpeedValue       = 60
_G.AntiAFK          = false
_G.AutoRespawn      = false
_G.Invisible        = false

_G.InfAmmo          = false
_G.RapidFire        = false
_G.AutoReload       = false
_G.NoRecoil         = false
_G.NoSpread         = false
_G.AutoShoot        = false

_G.TriggerBot       = false
_G.TriggerDelay     = 0.05

_G.Crosshair        = false
_G.CrosshairStyle   = "Cross"
_G.HitmarkerEnabled = false
_G.HitmarkerDuration = 0.2
_G.ChamsEnabled     = false
_G.ChamsWallCheck   = false
_G.FOV_Filled       = false
_G.FPS_Counter      = false

_G.Colors = {
    FOV       = Color3.fromRGB(150, 0, 255),
    Box       = Color3.fromRGB(255, 255, 255),
    Skeleton  = Color3.fromRGB(255, 255, 255),
    Tracker   = Color3.fromRGB(0, 255, 0),
    Name      = Color3.fromRGB(255, 255, 255),
    Distance  = Color3.fromRGB(200, 200, 200),
    Health    = Color3.fromRGB(0, 255, 0),
    HealthLow = Color3.fromRGB(255, 0, 0),
    Crosshair = Color3.fromRGB(255, 255, 255),
    Hitmarker = Color3.fromRGB(255, 100, 0),
    Chams     = Color3.fromRGB(255, 0, 255),
}

local cameraRotation  = Vector2.new(0, 0)
local hitmarkerTime   = 0
local hitmarkerOn     = false
local fpsFrames       = 0
local fpsTimer        = 0
local fpsValue        = 0
local afkThread       = nil
local autoRespawnConn = nil

-- ============================================================
-- AURA RARE — dual-layer
-- ============================================================
local function ApplyRareAura(char)
    if not char then return end
    local part = char:WaitForChild("HumanoidRootPart", 5)
    if not part then return end
    if part:FindFirstChild("StapeAura1") then return end
    local configs = {
        { name="StapeAura1", col1=Color3.fromRGB(150,0,255),   col2=Color3.fromRGB(50,0,100),   rate=45, lt=NumberRange.new(0.8,1.5), sz=2.5 },
        { name="StapeAura2", col1=Color3.fromRGB(255,255,255), col2=Color3.fromRGB(150,0,255),  rate=20, lt=NumberRange.new(0.4,0.9), sz=1.2 },
    }
    for _, c in ipairs(configs) do
        local e = Instance.new("ParticleEmitter")
        e.Name         = c.name
        e.Color        = ColorSequence.new(c.col1, c.col2)
        e.Size         = NumberSequence.new({NumberSequenceKeypoint.new(0,c.sz), NumberSequenceKeypoint.new(1,0)})
        e.Texture      = "rbxassetid://6073700091"
        e.Lifetime     = c.lt
        e.Rate         = c.rate
        e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.2), NumberSequenceKeypoint.new(1,1)})
        e.Parent       = part
    end
end

LocalPlayer.CharacterAdded:Connect(ApplyRareAura)
if LocalPlayer.Character then ApplyRareAura(LocalPlayer.Character) end

-- ============================================================
-- UTILITIES
-- ============================================================
local function Notify(title, body, dur)
    Fluent:Notify({ Title = title, Content = body, Duration = dur or 3 })
end

local function IsVisible(part)
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, part.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function WorldToScreen(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis, sp.Z
end

local function ScreenCenter()
    return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

local function GetBone(char, bone)
    local map = {
        Head             = {"Head"},
        HumanoidRootPart = {"HumanoidRootPart"},
        UpperTorso       = {"UpperTorso", "Torso"},
        Neck             = {"Head", "UpperTorso", "Torso"},
    }
    for _, n in ipairs(map[bone] or {bone}) do
        local p = char:FindFirstChild(n)
        if p then return p end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHealthColor(pct)
    if pct > 0.6 then return _G.Colors.Health
    elseif pct > 0.3 then return Color3.fromRGB(255,200,0)
    else return _G.Colors.HealthLow end
end

local function TeamMatch(p)
    return _G.TeamCheck and p.Team == LocalPlayer.Team
end

-- ============================================================
-- GUN MODS
-- ============================================================
local function ApplyGunMods()
    if not (_G.InfAmmo or _G.RapidFire or _G.AutoReload or _G.NoRecoil or _G.NoSpread) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    if _G.InfAmmo then
        for _, v in pairs(tool:GetDescendants()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) then
                local n = v.Name:lower()
                if n:find("ammo") or n:find("clip") or n:find("mag") or n:find("bullet") then v.Value = 9999 end
            end
        end
    end
    if _G.RapidFire then
        for _, name in ipairs({"Delay","Cooldown","FireRate","FireDelay","ShootDelay"}) do
            local v = tool:FindFirstChild(name, true)
            if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then v.Value = 0 end
        end
    end
    if _G.AutoReload then
        local r = tool:FindFirstChild("Reloading", true)
        if r then r.Value = false end
    end
    if _G.NoRecoil then
        local r = tool:FindFirstChild("Recoil", true) or tool:FindFirstChild("RecoilAmount", true)
        if r then r.Value = 0 end
    end
    if _G.NoSpread then
        local s = tool:FindFirstChild("Spread", true) or tool:FindFirstChild("Accuracy", true)
        if s then s.Value = 0 end
    end
end

-- ============================================================
-- TRIGGERBOT
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not _G.TriggerBot then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.T) then return end
    local unitRay = Camera:ScreenPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local params  = RaycastParams.new()
    local myChar  = LocalPlayer.Character
    if myChar then params.FilterDescendantsInstances = {myChar}; params.FilterType = Enum.RaycastFilterType.Exclude end
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, params)
    if result then
        local hit = result.Instance
        if hit and hit.Parent then
            local p = Players:GetPlayerFromCharacter(hit.Parent)
            if p and p ~= LocalPlayer and not TeamMatch(p) then
                task.delay(_G.TriggerDelay, function()
                    local tool = myChar and myChar:FindFirstChildOfClass("Tool")
                    if tool then
                        local fire = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
                        if fire and fire:IsA("RemoteEvent") then fire:FireServer() end
                    end
                end)
            end
        end
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local ESPObjects = {}

local BONES_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
}
local BONES_R6 = {
    {"Head","Torso"},{"Torso","Right Arm"},{"Torso","Left Arm"},{"Torso","Right Leg"},{"Torso","Left Leg"},
}

local function NewDraw(class, props)
    local d = Drawing.new(class)
    for k,v in pairs(props) do d[k] = v end
    return d
end

local function CreateESP(target)
    if target == LocalPlayer then return end
    if ESPObjects[target] then return end
    local obj = {
        Box      = NewDraw("Square", {Thickness=1.5, Filled=false, Visible=false}),
        Tracer   = NewDraw("Line",   {Thickness=1.5, Visible=false}),
        NameText = NewDraw("Text",   {Size=14, Center=true, Outline=true, Visible=false}),
        DistText = NewDraw("Text",   {Size=12, Center=true, Outline=true, Visible=false}),
        HpBG     = NewDraw("Square", {Thickness=1, Filled=true, Color=Color3.fromRGB(0,0,0), Visible=false}),
        HpBar    = NewDraw("Square", {Thickness=1, Filled=true, Visible=false}),
        Skel     = {},
    }
    for i = 1, 14 do obj.Skel[i] = NewDraw("Line", {Thickness=1, Visible=false}) end
    ESPObjects[target] = obj

    local conn
    conn = RunService.RenderStepped:Connect(function()
        local char = target.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")

        local function Hide()
            obj.Box.Visible=false; obj.Tracer.Visible=false
            obj.NameText.Visible=false; obj.DistText.Visible=false
            obj.HpBG.Visible=false; obj.HpBar.Visible=false
            for _,l in ipairs(obj.Skel) do l.Visible=false end
        end

        if not char or not hum or not hrp or hum.Health <= 0 then
            Hide()
            if not target.Parent then
                for k,d in pairs(obj) do
                    if type(d)=="table" then for _,v in ipairs(d) do if v.Remove then v:Remove() end end
                    elseif d.Remove then d:Remove() end
                end
                ESPObjects[target] = nil
                conn:Disconnect()
            end
            return
        end

        if not _G.ESP_Enabled then Hide(); return end
        if _G.ESP_TeamCheck and target.Team == LocalPlayer.Team then Hide(); return end

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist3D = myHRP and (myHRP.Position - hrp.Position).Magnitude or 0
        if dist3D > _G.ESP_MaxDist then Hide(); return end

        local sp, onScreen, depth = WorldToScreen(hrp.Position)
        if not onScreen then Hide(); return end

        local scale = 1 / depth
        local bH    = math.clamp(3000 * scale, 10, 1000)
        local bW    = bH * 0.6

        -- BOX
        if _G.ESP_Box then
            local boxColor = _G.Colors.Box
            if _G.ESP_TeamColor and target.Team then
                local tc = target.TeamColor
                boxColor = Color3.fromRGB(tc.r*255, tc.g*255, tc.b*255)
            end
            obj.Box.Visible  = true
            obj.Box.Size     = Vector2.new(bW, bH)
            obj.Box.Position = Vector2.new(sp.X - bW/2, sp.Y - bH/2)
            obj.Box.Color    = boxColor
        else obj.Box.Visible = false end

        -- HEALTH BAR
        local hpPct = hum.Health / hum.MaxHealth
        if _G.ESP_Health then
            local bx = sp.X - bW/2 - 6
            local by = sp.Y - bH/2
            obj.HpBG.Visible   = true
            obj.HpBG.Size      = Vector2.new(4, bH)
            obj.HpBG.Position  = Vector2.new(bx, by)
            obj.HpBar.Visible  = true
            obj.HpBar.Size     = Vector2.new(4, bH * hpPct)
            obj.HpBar.Position = Vector2.new(bx, by + bH*(1-hpPct))
            obj.HpBar.Color    = GetHealthColor(hpPct)
        else obj.HpBG.Visible=false; obj.HpBar.Visible=false end

        -- NAME
        if _G.ESP_Names then
            obj.NameText.Visible  = true
            obj.NameText.Text     = target.DisplayName
            obj.NameText.Position = Vector2.new(sp.X, sp.Y - bH/2 - 16)
            obj.NameText.Color    = _G.Colors.Name
        else obj.NameText.Visible = false end

        -- DISTANCE
        if _G.ESP_Distance then
            obj.DistText.Visible  = true
            obj.DistText.Text     = string.format("[%d]", math.floor(dist3D))
            obj.DistText.Position = Vector2.new(sp.X, sp.Y + bH/2 + 2)
            obj.DistText.Color    = _G.Colors.Distance
        else obj.DistText.Visible = false end

        -- TRACER
        if _G.Trackers_Enabled then
            obj.Tracer.Visible = true
            obj.Tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            obj.Tracer.To      = sp
            obj.Tracer.Color   = _G.Colors.Tracker
        else obj.Tracer.Visible = false end

        -- SKELETON
        if _G.ESP_Skeleton then
            local bones = char:FindFirstChild("UpperTorso") and BONES_R15 or BONES_R6
            for i, pair in ipairs(bones) do
                local a = char:FindFirstChild(pair[1])
                local b = char:FindFirstChild(pair[2])
                local ln = obj.Skel[i]
                if a and b and ln then
                    local aP, aV = WorldToScreen(a.Position)
                    local bP, bV = WorldToScreen(b.Position)
                    if aV or bV then
                        ln.Visible = true; ln.From = aP; ln.To = bP; ln.Color = _G.Colors.Skeleton
                    else ln.Visible = false end
                elseif ln then ln.Visible = false end
            end
        else for _,l in ipairs(obj.Skel) do l.Visible=false end end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    local obj = ESPObjects[p]
    if not obj then return end
    for k,d in pairs(obj) do
        if type(d)=="table" then for _,v in ipairs(d) do if v.Remove then v:Remove() end end
        elseif d.Remove then d:Remove() end
    end
    ESPObjects[p] = nil
end)

-- ============================================================
-- CHAMS
-- ============================================================
local ChamsHL = {}

local function ApplyChams(p)
    if p == LocalPlayer then return end
    local function attach(char)
        if ChamsHL[p] then ChamsHL[p]:Destroy(); ChamsHL[p]=nil end
        if not _G.ChamsEnabled then return end
        local h = Instance.new("Highlight")
        h.FillColor           = _G.Colors.Chams
        h.OutlineColor        = Color3.fromRGB(255,255,255)
        h.FillTransparency    = 0.4
        h.OutlineTransparency = 0
        h.DepthMode = _G.ChamsWallCheck and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        h.Adornee = char; h.Parent = char
        ChamsHL[p] = h
    end
    if p.Character then attach(p.Character) end
    p.CharacterAdded:Connect(attach)
end

for _, p in ipairs(Players:GetPlayers()) do ApplyChams(p) end
Players.PlayerAdded:Connect(ApplyChams)

local function RefreshChams()
    for p, h in pairs(ChamsHL) do
        if h and h.Parent then
            h.FillColor = _G.Colors.Chams
            h.DepthMode = _G.ChamsWallCheck and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        end
    end
end

-- ============================================================
-- FOV
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.NumSides = 64

local FOVFill = Drawing.new("Circle")
FOVFill.NumSides = 64; FOVFill.Filled = true; FOVFill.Transparency = 0.85

-- ============================================================
-- CROSSHAIR
-- ============================================================
local CXLines = {}
for i = 1,4 do CXLines[i] = NewDraw("Line", {Thickness=1.5, Visible=false}) end
local CXDot = NewDraw("Circle", {Filled=true, NumSides=16, Radius=2.5, Visible=false})

local function UpdateCrosshair()
    local c = ScreenCenter(); local gap = 6; local len = 12
    local show = _G.Crosshair; local style = _G.CrosshairStyle
    if style == "Dot" then
        for _,l in ipairs(CXLines) do l.Visible=false end
        CXDot.Visible=show; CXDot.Position=c; CXDot.Color=_G.Colors.Crosshair
    else
        CXDot.Visible = false
        local spread = 0
        if style == "Dynamic" then
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then local v=hrp.Velocity; spread=math.clamp(Vector3.new(v.X,0,v.Z).Magnitude*0.3,0,40) end
        end
        local g2 = gap + spread
        local dirs = {{Vector2.new(g2,0),Vector2.new(g2+len,0)},{Vector2.new(-g2,0),Vector2.new(-g2-len,0)},{Vector2.new(0,g2),Vector2.new(0,g2+len)},{Vector2.new(0,-g2),Vector2.new(0,-g2-len)}}
        for i=1,4 do CXLines[i].Visible=show; CXLines[i].From=c+dirs[i][1]; CXLines[i].To=c+dirs[i][2]; CXLines[i].Color=_G.Colors.Crosshair end
    end
end

-- ============================================================
-- HITMARKER
-- ============================================================
local HMLines = {}
for i=1,4 do HMLines[i] = NewDraw("Line", {Thickness=2, Visible=false}) end

local function ShowHitmarker()
    if not _G.HitmarkerEnabled then return end
    hitmarkerOn=true; hitmarkerTime=tick()
end

local function UpdateHitmarker()
    if hitmarkerOn and (tick()-hitmarkerTime) < _G.HitmarkerDuration then
        local c=ScreenCenter(); local sz=8; local g=3
        local dirs={{Vector2.new(g,g),Vector2.new(g+sz,g+sz)},{Vector2.new(-g,g),Vector2.new(-g-sz,g+sz)},{Vector2.new(g,-g),Vector2.new(g+sz,-g-sz)},{Vector2.new(-g,-g),Vector2.new(-g-sz,-g-sz)}}
        for i=1,4 do HMLines[i].Visible=true; HMLines[i].From=c+dirs[i][1]; HMLines[i].To=c+dirs[i][2]; HMLines[i].Color=_G.Colors.Hitmarker end
    else
        hitmarkerOn=false
        for _,l in ipairs(HMLines) do l.Visible=false end
    end
end

local function HookHPEvents(p)
    if p == LocalPlayer then return end
    local function hookChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.HealthChanged:Connect(function(hp) if hp < hum.MaxHealth then ShowHitmarker() end end) end
    end
    if p.Character then hookChar(p.Character) end
    p.CharacterAdded:Connect(hookChar)
end
for _,p in ipairs(Players:GetPlayers()) do HookHPEvents(p) end
Players.PlayerAdded:Connect(HookHPEvents)

-- ============================================================
-- FPS LABEL
-- ============================================================
local FPSLabel = NewDraw("Text", {Size=14, Outline=true, Visible=false, Color=Color3.fromRGB(0,255,100), Position=Vector2.new(8,8)})

-- ============================================================
-- FREECAM
-- ============================================================
UserInputService.InputChanged:Connect(function(input)
    if _G.FreeCam and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Delta
        cameraRotation = cameraRotation - Vector2.new(d.X*0.4, d.Y*0.4)
        cameraRotation = Vector2.new(cameraRotation.X, math.clamp(cameraRotation.Y, -89, 89))
    end
end)

-- ============================================================
-- MISC HELPERS
-- ============================================================
local function SetAntiAFK(on)
    if afkThread then task.cancel(afkThread); afkThread=nil end
    if on then
        afkThread = task.spawn(function()
            while _G.AntiAFK do
                task.wait(55)
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0,0,0.001) end
                end
            end
        end)
    end
end

local function SetAutoRespawn(on)
    if autoRespawnConn then autoRespawnConn:Disconnect(); autoRespawnConn=nil end
    if on then
        autoRespawnConn = LocalPlayer.CharacterRemoving:Connect(function()
            task.delay(0.5, function() if _G.AutoRespawn then LocalPlayer:LoadCharacter() end end)
        end)
    end
end

local function SetInvisible(on)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.LocalTransparencyModifier = on and 1 or 0
        end
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    fpsFrames=fpsFrames+1; fpsTimer=fpsTimer+dt
    if fpsTimer >= 0.5 then fpsValue=math.floor(fpsFrames/fpsTimer); fpsFrames=0; fpsTimer=0 end
    FPSLabel.Visible=_G.FPS_Counter; FPSLabel.Text="FPS: "..fpsValue

    FOVCircle.Visible=_G.FOV_Visible; FOVCircle.Radius=_G.FOV_Radius; FOVCircle.Position=ScreenCenter(); FOVCircle.Color=_G.Colors.FOV
    FOVFill.Visible=_G.FOV_Filled; FOVFill.Radius=_G.FOV_Radius; FOVFill.Position=ScreenCenter(); FOVFill.Color=_G.Colors.FOV

    UpdateCrosshair()
    UpdateHitmarker()

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
            local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 5 or 2
            local move  = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.Z) or UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            Camera.CFrame = Camera.CFrame + (move * speed)
        else
            if Camera.CameraType ~= Enum.CameraType.Custom then
                Camera.CameraType = Enum.CameraType.Custom
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end

        if not _G.FreeCam and hrp then
            if _G.SpeedBoost then hum.WalkSpeed = _G.SpeedValue
            else hum.WalkSpeed = hum.MoveDirection.Magnitude > 0 and _G.RunSpeed or _G.WalkSpeed end
            hum.JumpPower = _G.JumpPower

            if _G.FlyEnabled then
                local bv = hrp:FindFirstChild("__SHFly") or (function()
                    local v = Instance.new("BodyVelocity"); v.Name="__SHFly"; v.MaxForce=Vector3.new(1e5,1e5,1e5); v.Parent=hrp; return v
                end)()
                local bg = hrp:FindFirstChild("__SHGyro") or (function()
                    local g = Instance.new("BodyGyro"); g.Name="__SHGyro"; g.MaxTorque=Vector3.new(1e5,1e5,1e5); g.D=100; g.Parent=hrp; return g
                end)()
                local mv = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Z) then mv += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then mv -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.new(0,1,0) end
                bv.Velocity = mv * _G.FlySpeed; bg.CFrame = Camera.CFrame
            else
                local bv = hrp:FindFirstChild("__SHFly"); local bg = hrp:FindFirstChild("__SHGyro")
                if bv then bv:Destroy() end; if bg then bg:Destroy() end
            end
        end

        ApplyGunMods()

        if _G.AutoShoot then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then local fire = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
                if fire and fire:IsA("RemoteEvent") then fire:FireServer() end end
        end

        if _G.GodMode then hum.Health = hum.MaxHealth end
        if _G.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        if _G.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        if _G.NeoStrafe and hum.FloorMaterial == Enum.Material.Air and hrp then
            hrp.Velocity = Vector3.new(hum.MoveDirection.X*80, hrp.Velocity.Y, hum.MoveDirection.Z*80)
        end
        if _G.Invisible then SetInvisible(true) end
    end

    if _G.Aimbot and UserInputService:IsKeyDown(_G.AimbotKey) then
        local best = nil; local bestDist = _G.FOV_Radius; local center = ScreenCenter()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character
                and p.Character:FindFirstChildOfClass("Humanoid")
                and p.Character:FindFirstChildOfClass("Humanoid").Health > 0
                and not TeamMatch(p)
            then
                local bone = GetBone(p.Character, _G.AimPart)
                if bone and (not _G.VisibleCheck or IsVisible(bone)) then
                    local sp, onScreen = WorldToScreen(bone.Position)
                    if onScreen then
                        local mag = (sp - center).Magnitude
                        if mag < bestDist then bestDist=mag; best=p.Character end
                    end
                end
            end
        end
        if best then
            local bone = GetBone(best, _G.AimPart); local hrp2 = best:FindFirstChild("HumanoidRootPart")
            if bone and hrp2 then
                local predicted = bone.Position + (hrp2.Velocity * _G.Prediction)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), 1.1 - _G.Aimbot_Smoothing)
            end
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

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local HS       = game:GetService("HttpService")
local CFG_DIR  = "StapeHub"
local CFG_EXT  = ".json"

-- All keys that get saved/loaded
local SAVE_KEYS = {
    "Aimbot","TeamCheck","VisibleCheck","Prediction","FOV_Visible","FOV_Radius",
    "Aimbot_Smoothing","SilentAim","AimPart",
    "ESP_Enabled","ESP_Box","ESP_Skeleton","Trackers_Enabled","ESP_Names",
    "ESP_Distance","ESP_Health","ESP_MaxDist","ESP_TeamCheck","ESP_TeamColor",
    "FlyEnabled","FlySpeed","NoClip","FreeCam","GodMode","WalkSpeed","RunSpeed",
    "JumpPower","InfJump","NeoStrafe","BunnyHop","SpeedBoost","SpeedValue",
    "AntiAFK","AutoRespawn","Invisible",
    "InfAmmo","RapidFire","AutoReload","NoRecoil","NoSpread","AutoShoot",
    "TriggerBot","TriggerDelay",
    "Crosshair","CrosshairStyle","HitmarkerEnabled","HitmarkerDuration",
    "ChamsEnabled","ChamsWallCheck","FOV_Filled","FPS_Counter",
}

-- Encode Color3 to/from plain table so JSON can carry it
local function EncodeColor(c)
    return {r=math.floor(c.R*255), g=math.floor(c.G*255), b=math.floor(c.B*255)}
end
local function DecodeColor(t)
    return Color3.fromRGB(t.r or 255, t.g or 255, t.b or 255)
end

local function CollectData()
    local data = {}
    for _, k in ipairs(SAVE_KEYS) do data[k] = _G[k] end
    -- Serialize Colors table separately (Color3 not JSON-safe)
    data.__colors = {}
    for k, v in pairs(_G.Colors) do data.__colors[k] = EncodeColor(v) end
    return data
end

local function ApplyData(data)
    for _, k in ipairs(SAVE_KEYS) do
        if data[k] ~= nil then _G[k] = data[k] end
    end
    if data.__colors then
        for k, v in pairs(data.__colors) do
            if _G.Colors[k] then _G.Colors[k] = DecodeColor(v) end
        end
    end
end

-- Ensure folder exists
pcall(function()
    if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
end)

local function ListConfigs()
    local ok, files = pcall(listfiles, CFG_DIR)
    if not ok then return {} end
    local names = {}
    for _, f in ipairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    return names
end

local function SaveConfig(name)
    name = (name ~= "" and name) or "default"
    local path = CFG_DIR .. "/" .. name .. CFG_EXT
    local ok, err = pcall(writefile, path, HS:JSONEncode(CollectData()))
    if ok then Notify("Config", "Saved: " .. name, 2)
    else Notify("Config", "Save error: " .. tostring(err), 4) end
end

local function LoadConfig(name)
    name = (name ~= "" and name) or "default"
    local path = CFG_DIR .. "/" .. name .. CFG_EXT
    local ok, raw = pcall(readfile, path)
    if not ok or not raw then Notify("Config", "Not found: " .. name, 3); return end
    local ok2, data = pcall(function() return HS:JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then Notify("Config", "Corrupted: " .. name, 3); return end
    ApplyData(data)
    Notify("Config", "Loaded: " .. name, 2)
end

local function DeleteConfig(name)
    name = (name ~= "" and name) or "default"
    local path = CFG_DIR .. "/" .. name .. CFG_EXT
    local ok, err = pcall(delfile, path)
    if ok then Notify("Config", "Deleted: " .. name, 2)
    else Notify("Config", "Delete error: " .. tostring(err), 3) end
end

-- ============================================================
-- FLUENT UI
-- ============================================================
local Window = Fluent:CreateWindow({
    Title       = "STAPE HUB",
    SubTitle    = "V3.0",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(600, 500),
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.Insert,
})

local Tabs = {
    Combat   = Window:AddTab({ Title = "Combat",   Icon = "crosshair" }),
    Trigger  = Window:AddTab({ Title = "Trigger",  Icon = "zap"       }),
    GunMods  = Window:AddTab({ Title = "Gun Mods", Icon = "tool"      }),
    Visuals  = Window:AddTab({ Title = "Visuals",  Icon = "eye"       }),
    Player   = Window:AddTab({ Title = "Player",   Icon = "user"      }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "wind"      }),
    Misc     = Window:AddTab({ Title = "Misc",     Icon = "settings"  }),
    Config   = Window:AddTab({ Title = "Config",   Icon = "save"      }),
    Colors   = Window:AddTab({ Title = "Colors",   Icon = "palette"   }),
}

-- COMBAT
Tabs.Combat:AddToggle("AimbotToggle",  { Title="Aimbot Active",    Default=_G.Aimbot,           Callback=function(v) _G.Aimbot=v end })
Tabs.Combat:AddToggle("SilentAim",     { Title="Silent Aim",        Default=_G.SilentAim,        Callback=function(v) _G.SilentAim=v end })
Tabs.Combat:AddToggle("TeamCheck",     { Title="Team Check",        Default=_G.TeamCheck,        Callback=function(v) _G.TeamCheck=v end })
Tabs.Combat:AddToggle("VisCheck",      { Title="Visibility Check",  Default=_G.VisibleCheck,     Callback=function(v) _G.VisibleCheck=v end })
Tabs.Combat:AddToggle("FOVVisToggle",  { Title="Show FOV Circle",   Default=_G.FOV_Visible,      Callback=function(v) _G.FOV_Visible=v end })
Tabs.Combat:AddToggle("FOVFilled",     { Title="Filled FOV",        Default=_G.FOV_Filled,       Callback=function(v) _G.FOV_Filled=v end })
Tabs.Combat:AddSlider("SmoothSlider",  { Title="Smoothing",         Default=_G.Aimbot_Smoothing, Min=0.01, Max=0.99, Rounding=2, Callback=function(v) _G.Aimbot_Smoothing=v end })
Tabs.Combat:AddSlider("PredSlider",    { Title="Prediction",        Default=_G.Prediction,       Min=0, Max=0.5, Rounding=3, Callback=function(v) _G.Prediction=v end })
Tabs.Combat:AddSlider("FOVSlider",     { Title="FOV Radius",        Default=_G.FOV_Radius,       Min=10, Max=800, Rounding=0, Callback=function(v) _G.FOV_Radius=v end })
Tabs.Combat:AddDropdown("AimBone", { Title="Aim Bone", Values={"Head","HumanoidRootPart","UpperTorso","Neck"}, Default=1, Callback=function(v) _G.AimPart=v end })

-- TRIGGER
Tabs.Trigger:AddToggle("TrigBot",    { Title="Triggerbot (Hold T)", Default=_G.TriggerBot,   Callback=function(v) _G.TriggerBot=v end })
Tabs.Trigger:AddSlider("TrigDelay",  { Title="Trigger Delay (s)",   Default=_G.TriggerDelay, Min=0, Max=0.5, Rounding=3, Callback=function(v) _G.TriggerDelay=v end })

-- GUN MODS
Tabs.GunMods:AddToggle("InfAmmo",    { Title="Infinite Ammo", Default=_G.InfAmmo,    Callback=function(v) _G.InfAmmo=v end })
Tabs.GunMods:AddToggle("AutoReload", { Title="Auto Reload",   Default=_G.AutoReload, Callback=function(v) _G.AutoReload=v end })
Tabs.GunMods:AddToggle("RapidFire",  { Title="Rapid Fire",    Default=_G.RapidFire,  Callback=function(v) _G.RapidFire=v end })
Tabs.GunMods:AddToggle("AutoShoot",  { Title="Auto Shoot",    Default=_G.AutoShoot,  Callback=function(v) _G.AutoShoot=v end })
Tabs.GunMods:AddToggle("NoRecoil",   { Title="No Recoil",     Default=_G.NoRecoil,   Callback=function(v) _G.NoRecoil=v end })
Tabs.GunMods:AddToggle("NoSpread",   { Title="No Spread",     Default=_G.NoSpread,   Callback=function(v) _G.NoSpread=v end })

-- VISUALS
Tabs.Visuals:AddToggle("MasterESP",  { Title="Master ESP",           Default=_G.ESP_Enabled,      Callback=function(v) _G.ESP_Enabled=v end })
Tabs.Visuals:AddToggle("BoxESP",     { Title="Box ESP",               Default=_G.ESP_Box,          Callback=function(v) _G.ESP_Box=v end })
Tabs.Visuals:AddToggle("SkelESP",    { Title="Skeleton ESP",          Default=_G.ESP_Skeleton,     Callback=function(v) _G.ESP_Skeleton=v end })
Tabs.Visuals:AddToggle("Tracers",    { Title="Tracers",               Default=_G.Trackers_Enabled, Callback=function(v) _G.Trackers_Enabled=v end })
Tabs.Visuals:AddToggle("NamesESP",   { Title="Player Names",          Default=_G.ESP_Names,        Callback=function(v) _G.ESP_Names=v end })
Tabs.Visuals:AddToggle("DistESP",    { Title="Distance",              Default=_G.ESP_Distance,     Callback=function(v) _G.ESP_Distance=v end })
Tabs.Visuals:AddToggle("HealthESP",  { Title="Health Bars",           Default=_G.ESP_Health,       Callback=function(v) _G.ESP_Health=v end })
Tabs.Visuals:AddToggle("ESPTeamChk", { Title="ESP Team Check",        Default=_G.ESP_TeamCheck,    Callback=function(v) _G.ESP_TeamCheck=v end })
Tabs.Visuals:AddToggle("ESPTeamCol", { Title="ESP Team Color",        Default=_G.ESP_TeamColor,    Callback=function(v) _G.ESP_TeamColor=v end })
Tabs.Visuals:AddSlider("MaxDist",    { Title="Max ESP Distance",      Default=_G.ESP_MaxDist,      Min=50, Max=5000, Rounding=0, Callback=function(v) _G.ESP_MaxDist=v end })
Tabs.Visuals:AddToggle("Chams",      { Title="Chams",                 Default=_G.ChamsEnabled,     Callback=function(v)
    _G.ChamsEnabled=v
    for p, h in pairs(ChamsHL) do if h and h.Parent then h:Destroy() end; ChamsHL[p]=nil end
    if v then for _,p in ipairs(Players:GetPlayers()) do ApplyChams(p) end end
end })
Tabs.Visuals:AddToggle("ChamsWall",  { Title="Chams Through Walls",   Default=_G.ChamsWallCheck,   Callback=function(v) _G.ChamsWallCheck=v; RefreshChams() end })
Tabs.Visuals:AddToggle("Crosshair",  { Title="Custom Crosshair",      Default=_G.Crosshair,        Callback=function(v) _G.Crosshair=v end })
Tabs.Visuals:AddDropdown("CXStyle",  { Title="Crosshair Style", Values={"Cross","Dot","Dynamic"}, Default=1, Callback=function(v) _G.CrosshairStyle=v end })
Tabs.Visuals:AddToggle("Hitmarker",  { Title="Hitmarker",             Default=_G.HitmarkerEnabled, Callback=function(v) _G.HitmarkerEnabled=v end })
Tabs.Visuals:AddSlider("HMDur",      { Title="Hitmarker Duration",    Default=_G.HitmarkerDuration, Min=0.05, Max=1, Rounding=2, Callback=function(v) _G.HitmarkerDuration=v end })
Tabs.Visuals:AddToggle("FPSCounter", { Title="FPS Counter",           Default=_G.FPS_Counter,      Callback=function(v) _G.FPS_Counter=v end })

-- PLAYER
Tabs.Player:AddSlider("WalkSlider",    { Title="Walk Speed",  Default=_G.WalkSpeed,  Min=0, Max=250, Rounding=0, Callback=function(v) _G.WalkSpeed=v end })
Tabs.Player:AddSlider("RunSlider",     { Title="Run Speed",   Default=_G.RunSpeed,   Min=0, Max=400, Rounding=0, Callback=function(v) _G.RunSpeed=v end })
Tabs.Player:AddSlider("JumpSlider",    { Title="Jump Power",  Default=_G.JumpPower,  Min=0, Max=500, Rounding=0, Callback=function(v) _G.JumpPower=v end })
Tabs.Player:AddToggle("FlyToggle",     { Title="Fly Mode",    Default=_G.FlyEnabled, Callback=function(v) _G.FlyEnabled=v end })
Tabs.Player:AddSlider("FlySpeed",      { Title="Fly Speed",   Default=_G.FlySpeed,   Min=5, Max=300, Rounding=0, Callback=function(v) _G.FlySpeed=v end })
Tabs.Player:AddToggle("NoclipToggle",  { Title="No Clip",     Default=_G.NoClip,     Callback=function(v) _G.NoClip=v end })
Tabs.Player:AddToggle("FreecamToggle", { Title="Free Cam",    Default=_G.FreeCam,    Callback=function(v)
    _G.FreeCam=v
    if not v then Camera.CameraType=Enum.CameraType.Custom; UserInputService.MouseBehavior=Enum.MouseBehavior.Default
    else cameraRotation=Vector2.new(0,0) end
end })
Tabs.Player:AddToggle("GodToggle",     { Title="God Mode",    Default=_G.GodMode,    Callback=function(v) _G.GodMode=v end })
Tabs.Player:AddToggle("InfJump",       { Title="Infinite Jump",Default=_G.InfJump,   Callback=function(v) _G.InfJump=v end })
Tabs.Player:AddToggle("InvisToggle",   { Title="Invisible (Client)", Default=_G.Invisible, Callback=function(v) _G.Invisible=v; SetInvisible(v) end })

-- MOVEMENT
Tabs.Movement:AddToggle("NeoStrafe",  { Title="Neo Strafe",  Default=_G.NeoStrafe,  Callback=function(v) _G.NeoStrafe=v end })
Tabs.Movement:AddToggle("BHop",       { Title="Bunny Hop",   Default=_G.BunnyHop,   Callback=function(v) _G.BunnyHop=v end })
Tabs.Movement:AddToggle("SpeedBoost", { Title="Speed Boost", Default=_G.SpeedBoost, Callback=function(v) _G.SpeedBoost=v end })
Tabs.Movement:AddSlider("SpeedVal",   { Title="Speed Value", Default=_G.SpeedValue, Min=16, Max=1000, Rounding=0, Callback=function(v) _G.SpeedValue=v end })

-- MISC
Tabs.Misc:AddToggle("AntiAFK",     { Title="Anti-AFK",     Default=_G.AntiAFK,     Callback=function(v) _G.AntiAFK=v; SetAntiAFK(v) end })
Tabs.Misc:AddToggle("AutoRespawn", { Title="Auto Respawn", Default=_G.AutoRespawn, Callback=function(v) _G.AutoRespawn=v; SetAutoRespawn(v) end })

-- ============================================================
-- CONFIG TAB — dedicated full tab with name input via dropdown
-- ============================================================
-- Config name list — rebuilt each time Save is pressed
local configNames    = ListConfigs()
if #configNames == 0 then configNames = {"default"} end
local selectedConfig = configNames[1]

Tabs.Config:AddDropdown("ConfigList", {
    Title    = "Select Config",
    Values   = configNames,
    Default  = 1,
    Callback = function(v) selectedConfig = v end,
})

Tabs.Config:AddButton({ Title = "Save Config", Callback = function()
    SaveConfig(selectedConfig)
    -- Rebuild dropdown values with fresh file list
    local fresh = ListConfigs()
    if #fresh == 0 then fresh = {"default"} end
    configNames = fresh
end })

Tabs.Config:AddButton({ Title = "Load Config", Callback = function()
    LoadConfig(selectedConfig)
end })

Tabs.Config:AddButton({ Title = "Delete Config", Callback = function()
    DeleteConfig(selectedConfig)
    configNames = ListConfigs()
    if #configNames == 0 then configNames = {"default"} end
    selectedConfig = configNames[1]
end })

-- Quick-save presets for common loadouts
Tabs.Config:AddButton({ Title = "Quick Save: Rage",    Callback = function() SaveConfig("rage")    end })
Tabs.Config:AddButton({ Title = "Quick Save: Legit",   Callback = function() SaveConfig("legit")   end })
Tabs.Config:AddButton({ Title = "Quick Save: Visual",  Callback = function() SaveConfig("visual")  end })
Tabs.Config:AddButton({ Title = "Quick Load: Rage",    Callback = function() LoadConfig("rage")    end })
Tabs.Config:AddButton({ Title = "Quick Load: Legit",   Callback = function() LoadConfig("legit")   end })
Tabs.Config:AddButton({ Title = "Quick Load: Visual",  Callback = function() LoadConfig("visual")  end })

-- COLORS
Tabs.Colors:AddColorpicker("FOVColor",   { Title="FOV Circle",  Default=_G.Colors.FOV,       Callback=function(v) _G.Colors.FOV=v end })
Tabs.Colors:AddColorpicker("BoxColor",   { Title="Box ESP",     Default=_G.Colors.Box,       Callback=function(v) _G.Colors.Box=v end })
Tabs.Colors:AddColorpicker("SkelColor",  { Title="Skeleton",    Default=_G.Colors.Skeleton,  Callback=function(v) _G.Colors.Skeleton=v end })
Tabs.Colors:AddColorpicker("TrcColor",   { Title="Tracers",     Default=_G.Colors.Tracker,   Callback=function(v) _G.Colors.Tracker=v end })
Tabs.Colors:AddColorpicker("NameColor",  { Title="Names",       Default=_G.Colors.Name,      Callback=function(v) _G.Colors.Name=v end })
Tabs.Colors:AddColorpicker("DistColor",  { Title="Distance",    Default=_G.Colors.Distance,  Callback=function(v) _G.Colors.Distance=v end })
Tabs.Colors:AddColorpicker("HpColor",    { Title="Health High", Default=_G.Colors.Health,    Callback=function(v) _G.Colors.Health=v end })
Tabs.Colors:AddColorpicker("HpLowColor", { Title="Health Low",  Default=_G.Colors.HealthLow, Callback=function(v) _G.Colors.HealthLow=v end })
Tabs.Colors:AddColorpicker("CXColor",    { Title="Crosshair",   Default=_G.Colors.Crosshair, Callback=function(v) _G.Colors.Crosshair=v end })
Tabs.Colors:AddColorpicker("HMColor",    { Title="Hitmarker",   Default=_G.Colors.Hitmarker, Callback=function(v) _G.Colors.Hitmarker=v end })
Tabs.Colors:AddColorpicker("ChamsColor", { Title="Chams",       Default=_G.Colors.Chams,     Callback=function(v) _G.Colors.Chams=v; RefreshChams() end })

-- Auto-load default config on start
LoadConfig("default")

Window:SelectTab(1)

Fluent:Notify({
    Title   = "STAPE HUB V3.0",
    Content = "Loaded — " .. #Players:GetPlayers() .. " players in server.",
    Duration = 5
})
