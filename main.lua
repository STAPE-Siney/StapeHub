-- [[ STAPE HUB - UNIVERSAL V2.5 FULL ]]
local HttpService, Players, RunService, UIS, TweenService = game:GetService("HttpService"), game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local LocalPlayer, Camera, Mouse = Players.LocalPlayer, workspace.CurrentCamera, Players.LocalPlayer:GetMouse()
local api_url, FILE_NAME, HWID = "https://stapebackend-production.up.railway.app/check", "stape_config.json", game:GetService("RbxAnalyticsService"):GetClientId()

local function SaveKeyLocal(k) writefile(FILE_NAME, HttpService:JSONEncode({key = k})) end
local function GetSavedKey() if isfile(FILE_NAME) then local s, d = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end) if s then return d.key end end return nil end

if game:GetService("CoreGui"):FindFirstChild("StapeLogin") then game:GetService("CoreGui").StapeLogin:Destroy() end
local LoginGui = Instance.new("ScreenGui", game:GetService("CoreGui")); LoginGui.Name = "StapeLogin"
local LoginFrame = Instance.new("Frame", LoginGui); LoginFrame.Size = UDim2.new(0, 300, 0, 180); LoginFrame.Position = UDim2.new(0.5, -150, 0.5, -90); LoginFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", LoginFrame)
local LoginStroke = Instance.new("UIStroke", LoginFrame); LoginStroke.Color = Color3.fromRGB(150, 0, 255); LoginStroke.Thickness = 2
local KeyInput = Instance.new("TextBox", LoginFrame); KeyInput.Size = UDim2.new(0, 240, 0, 35); KeyInput.Position = UDim2.new(0.5, -120, 0.4, 0); KeyInput.PlaceholderText = "Entrez votre clé..."; KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25); KeyInput.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", KeyInput)
local LoginBtn = Instance.new("TextButton", LoginFrame); LoginBtn.Size = UDim2.new(0, 240, 0, 35); LoginBtn.Position = UDim2.new(0.5, -120, 0.7, 0); LoginBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 200); LoginBtn.Text = "VÉRIFIER"; LoginBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", LoginBtn)

local function StartCheat(exp)
    if LoginGui then LoginGui:Destroy() end
    _G.Aimbot, _G.FOV_Radius, _G.Prediction, _G.Aimbot_Smoothing = false, 150, 0.165, 0.4
    _G.ESP_Enabled, _G.ESP_Box, _G.ESP_Skeleton, _G.Trackers_Enabled = false, false, false, false
    _G.AutoFarm, _G.FarmDistance, _G.WalkSpeed, _G.FlyEnabled, _G.NoClip = false, 12, 16, false, false
    _G.Colors = {Main = Color3.fromRGB(150, 0, 255), BG = Color3.fromRGB(10, 10, 10), Section = Color3.fromRGB(18, 18, 18), FOV = Color3.fromRGB(150, 0, 255), Box = Color3.new(1,1,1), Skeleton = Color3.new(1,1,1), Tracker = Color3.new(0,1,0)}

    local function Equip() local bp = LocalPlayer.Backpack:GetChildren() if #bp > 0 and not LocalPlayer.Character:FindFirstChildOfClass("Tool") then bp[1].Parent = LocalPlayer.Character end end
    local function Attack() local v = game:GetService("VirtualUser") v:CaptureController() v:Button1Down(Vector2.new(0,0), Camera.CFrame) task.wait(0.05) v:Button1Up(Vector2.new(0,0), Camera.CFrame) end
    
    local function GetMob()
        local t, d = nil, math.huge
        local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Mobs"), workspace}
        for _, f in pairs(folders) do if f then for _, v in pairs(f:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v ~= LocalPlayer.Character then
                local r = v:FindFirstChild("HumanoidRootPart")
                if r then local dist = (LocalPlayer.Character.HumanoidRootPart.Position - r.Position).Magnitude if dist < d then d = dist; t = v end end
            end
        end end end return t
    end

    local function TryQuest()
        for _, v in pairs(workspace:GetDescendants()) do
            if (v.Name:find("Quest") or v.Name:find("Giver")) and v:FindFirstChild("HumanoidRootPart") then
                if (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 100 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    game:GetService("VirtualUser"):SetKeyDown("e") task.wait(0.1) game:GetService("VirtualUser"):SetKeyUp("e") return true
                end
            end
        end
    end

    -- UI HUB
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui")); ScreenGui.Name = "STAPE_V25"
    local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 550, 0, 400); Main.Position = UDim2.new(0.5, -275, 0.5, -200); Main.BackgroundColor3 = _G.Colors.BG; Instance.new("UICorner", Main)
    local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Sidebar)
    local PageHolder = Instance.new("Frame", Main); PageHolder.Size = UDim2.new(1, -140, 1, -20); PageHolder.Position = UDim2.new(0, 140, 0, 10); PageHolder.BackgroundTransparency = 1
    local List = Instance.new("UIListLayout", Sidebar); List.Padding = UDim.new(0, 5)

    local Pages = {}
    local function NewPage(n)
        local p = Instance.new("ScrollingFrame", PageHolder); p.Size = UDim2.new(1,0,1,0); p.Visible = false; p.BackgroundTransparency = 1; p.ScrollBarThickness = 0
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
        local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, -10, 0, 30); b.Text = n; b.BackgroundColor3 = Color3.fromRGB(25,25,25); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() for _, v in pairs(Pages) do v.Visible = false end p.Visible = true end)
        Pages[n] = p; return p
    end

    local function NewToggle(n, v, p)
        local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = _G.Colors.Section; b.Text = n..": OFF"; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() _G[v] = not _G[v] b.Text = n..(_G[v] and ": ON" or ": OFF") b.TextColor3 = _G[v] and _G.Colors.Main or Color3.new(1,1,1) end)
    end

    local fP = NewPage("Auto Farm"); NewToggle("Enable Farm", "AutoFarm", fP)
    local cP = NewPage("Combat"); NewToggle("Aimbot", "Aimbot", cP)
    local vP = NewPage("Visuals"); NewToggle("ESP Master", "ESP_Enabled", vP); NewToggle("Box", "ESP_Box", vP)
    local plP = NewPage("Player"); NewToggle("Fly", "FlyEnabled", plP)
    Pages["Auto Farm"].Visible = true

    -- Loops
    task.spawn(function()
        while true do task.wait()
            if _G.AutoFarm and LocalPlayer.Character then
                local m = GetMob()
                if m then Equip() LocalPlayer.Character.HumanoidRootPart.CFrame = m.HumanoidRootPart.CFrame * CFrame.new(0, _G.FarmDistance, 0) Attack()
                else TryQuest() end
            end
            if _G.NoClip and LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if _G.Aimbot and UIS:IsKeyDown(_G.AimbotKey or Enum.KeyCode.E) then
            local t, d = nil, _G.FOV_Radius
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                    local pos, os = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if os then local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude if mag < d then d = mag; t = p.Character end end
                end
            end
            if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Head.Position), 1.1 - _G.Aimbot_Smoothing) end
        end
    end)
end

local function Check(k, auto)
    local r = game:HttpGet(api_url.."?key="..k.."&hwid="..HWID)
    if r == "success" then if not auto then SaveKeyLocal(k) end StartCheat(9999999999) else if not auto then LoginBtn.Text = "CLÉ INVALIDE" end end
end

local sk = GetSavedKey() if sk then task.spawn(function() Check(sk, true) end) end
LoginBtn.MouseButton1Click:Connect(function() Check(KeyInput.Text:gsub("%s+", ""), false) end)
