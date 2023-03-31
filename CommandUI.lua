--// Auto shrink scale settings \\--

--[[
Height 0%
Width 0%
Head 100%
Proportions 100%
Body Type 0%
]]

local COREGUI = game:GetService("CoreGui")
if not game:IsLoaded() then
	game.Loaded:Wait()
end

--// Services \\--

local UserInputService = game:GetService('UserInputService')
local TeleportService = game:GetService('TeleportService')
local TweenService = game:GetService('TweenService')
local VirtualUser = game:GetService('VirtualUser')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local Lighting = game:GetService('Lighting')
local Players = game:GetService('Players')

--// Cache \\--

local pcall, getgenv, next, setmetatable, mathTan, mathRad, mathFloor, mathRound, Vector2new, CFramenew, Color3fromRGB, Drawingnew, TweenInfonew, stringupper, mousemoverel = pcall, getgenv, next, setmetatable, math.tan, math.rad, math.floor, math.round, Vector2.new, CFrame.new, Color3.fromRGB, Drawing.new, TweenInfo.new, string.upper, mousemoverel or (Input and Input.MouseMove)

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local sethidden = sethiddenproperty or set_hidden_property or set_hidden_prop
local gethidden = gethiddenproperty or get_hidden_property or get_hidden_prop
local setsimulation = setsimulationradius or set_simulation_radius

--// Environment \\--

local temp_List = {"Player", "List", "Will", "Replace", "This"}

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}

getgenv().CommandUI = {
	Player_Variables = {
		refreshCmd = false,
		Noclipping = nil,
		lastDeath = nil,
		bangLoop = nil,
		bangAnim = nil,
		bangDied = nil,
		swimbeat = nil,
		viewing = nil,
		spinSpeed = 20
	},
	
	Server_Variables = {
		maximumPlayers = Players.MaxPlayers - 1,
		minimumPlayers = 1
	},
	
	Fly_Variables = {
		Old_Grav = workspace.Gravity,
		vehicleflyspeed = 1,
		iyflyspeed = 1,
		FLYING = false,
		QEfly = true
	},
	
	ESP_Variables = {
		Tracers_Visible = false,
		Highlight_ESP = false,
		Show_Info = false,
		Hide_Team = false,
		Body_ESP = false,
		Box_ESP = false
	},
	
	Teleport_Variables = {
		Held_Button = false,
		loop_Tele = false,
		target = false
	},
	
	Lighting_Variables = {
		brightLoop = nil,
		origsettings = {
			oabt = Lighting.OutdoorAmbient,
			gs = Lighting.GlobalShadows,
			brt = Lighting.Brightness,
			time = Lighting.ClockTime,
			abt = Lighting.Ambient,
			fs = Lighting.FogStart,
			fe = Lighting.FogEnd
		}
	},
	
	Aimbot_Variables = {
		FOVCircle = Drawingnew("Circle"),
		LockedColor = Color3fromRGB(255, 0, 0),
		Color = Color3fromRGB(255, 255, 255),
		LockPart = "HumanoidRootPart",
		TriggerKey = "MouseButton2",
		Third_Person = false,
		Team_Check = true,
		Wall_Check = true,
		Aimbot = false
	}
}

local Environment = getgenv().CommandUI
local teleportVariables = Environment.Teleport_Variables
local lightingVariables = Environment.Lighting_Variables
local playerVariables = Environment.Player_Variables
local serverVariables = Environment.Server_Variables
local aimbotVariables = Environment.Aimbot_Variables
local flyVariables = Environment.Fly_Variables
local espVariables = Environment.ESP_Variables

--// Anti AFK \\--

local GC = getconnections or get_signal_cons
if GC then
	for i,v in pairs(GC(LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
		elseif v["Disconnect"] then
			v["Disconnect"](v)
		end
	end
else
	LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2new())
	end)
end

--// Settings Save/Load \\--

getgenv().settings = {}

if isfile("CommandUISettings.txt") then
	getgenv().settings = HttpService:JSONDecode(readfile('CommandUISettings.txt'))
end

local sNames = {"auto_Shrink", "click_Tele"}
local sValues = {false, false}

if #getgenv().settings ~= sNames then
	for i, v in ipairs(sNames) do
		if getgenv().settings[v] == nil then
			getgenv().settings[v] = sValues[i]
		end
	end
	
	writefile('CommandUISettings.txt', HttpService:JSONEncode(getgenv().settings))
end

local settingsLock = true

local function saveSettings()
	if settingsLock == false then
		print('Settings saved.')
		writefile('CommandUISettings.txt', HttpService:JSONEncode(getgenv().settings))
	end
end

--// Functions \\--

function GetUp()
	if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') and LocalPlayer.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function r15(Plr)
	if Plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function getTorso(x)
	x = x or LocalPlayer.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

function getPlayerFromString(String)
	local Player
	if string.find(String, "-") then
		Player = Players:FindFirstChild(string.sub(String, 2, string.find(String, " ") - 1))
	else
		Player = Players:FindFirstChild(string.sub(String, 2, #String))
	end
	return Player
end

--// Aimbot Functions \\--

local function ConvertVector(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local function CancelLock()
	aimbotVariables.Locked = nil
	aimbotVariables.FOVCircle.Color = aimbotVariables.Color
	UserInputService.MouseDeltaSensitivity = OriginalSensitivity

	if Animation then
		Animation:Cancel()
	end
end

local function GetClosestPlayer()
	if not aimbotVariables.Locked then
		RequiredDistance = 120

		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(aimbotVariables.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
				if aimbotVariables.Team_Check and v.TeamColor == LocalPlayer.TeamColor then continue end
				if v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
				if aimbotVariables.Wall_Check and #(Camera:GetPartsObscuringTarget({v.Character[aimbotVariables.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

				local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[aimbotVariables.LockPart].Position); Vector = ConvertVector(Vector)
				local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance = Distance
					aimbotVariables.Locked = v
				end
			end
		end
	elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(aimbotVariables.Locked.Character[aimbotVariables.LockPart].Position))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

local function Load()
	OriginalSensitivity = UserInputService.MouseDeltaSensitivity

	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if aimbotVariables.Aimbot then
			aimbotVariables.FOVCircle.Radius = 120
			aimbotVariables.FOVCircle.Thickness = 1
			aimbotVariables.FOVCircle.Filled = false
			aimbotVariables.FOVCircle.NumSides = 60
			aimbotVariables.FOVCircle.Color = aimbotVariables.Color
			aimbotVariables.FOVCircle.Transparency = .5
			aimbotVariables.FOVCircle.Visible = aimbotVariables.Aimbot
			aimbotVariables.FOVCircle.Position = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			aimbotVariables.FOVCircle.Visible = false
		end

		if Running and aimbotVariables.Aimbot then
			GetClosestPlayer()

			if aimbotVariables.Locked then
				if aimbotVariables.Third_Person then
					local Vector = Camera:WorldToViewportPoint(aimbotVariables.Locked.Character[aimbotVariables.LockPart].Position)
					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * 1, (Vector.Y - UserInputService:GetMouseLocation().Y) * 1)
				else
					Camera.CFrame = CFramenew(Camera.CFrame.Position, aimbotVariables.Locked.Character[aimbotVariables.LockPart].Position)
					UserInputService.MouseDeltaSensitivity = 0
				end

				aimbotVariables.FOVCircle.Color = aimbotVariables.LockedColor
			end
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[#aimbotVariables.TriggerKey == 1 and stringupper(aimbotVariables.TriggerKey) or aimbotVariables.TriggerKey] or Input.UserInputType == Enum.UserInputType[aimbotVariables.TriggerKey] then
					Running = true
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[#aimbotVariables.TriggerKey == 1 and stringupper(aimbotVariables.TriggerKey) or aimbotVariables.TriggerKey] or Input.UserInputType == Enum.UserInputType[aimbotVariables.TriggerKey] then
					Running = false; CancelLock()
				end
			end)
		end
	end)
end

--// Shrink \\--

local shrink = function()
	task.spawn(function()
		wait(3)
		local suc, err = pcall(function()
			local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
			if Hum and r15(LocalPlayer) then
			
				local function rm()
					for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
						if v:IsA("BasePart") then
							if v.Name ~= "Head" then
								for _, cav in pairs(v:GetDescendants()) do
									if cav:IsA("Attachment") then
										local OP = cav:FindFirstChild("OriginalPosition")
										if OP then
											OP:Destroy()
										end
									end
								end
								
								local OS = v:FindFirstChild("OriginalSize")
								if OS then
									OS:Destroy()
								end
								
								local APST = v:FindFirstChild("AvatarPartScaleType")
								if APST then
									APST:Destroy()
								end
							end
						end
					end
				end
				
				rm()
				wait(0.5)
				
				local BTS = Hum:FindFirstChild("BodyTypeScale")
				if BTS then
					BTS:Destroy()
				end
				
				wait(0.5)
				rm()
				wait(0.5)
				
				local BWS = Hum:FindFirstChild("BodyWidthScale")
				if BWS then
					BWS:Destroy()
				end
				
				wait(0.5)
				rm()
				wait(0.5)
				
				local BDS = Hum:FindFirstChild("BodyDepthScale")
				if BDS then
					BDS:Destroy()
				end
				
				wait(0.5)
				rm()
				wait(0.5)
				
				local HS = Hum:FindFirstChild("HeadScale")
				if HS then
					HS:Destroy()
				end
			end
		end)
		
		if not suc then
			warn(err)
		end
	end)
end

--// Server Hop \\--

local function ServerHop()
	if serverVariables.minimumPlayers > serverVariables.maximumPlayers then return end
	local foundserver = false
	local searched = false
	local pid = game.PlaceId
	local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"))
	LocalPlayer:Kick("\nDo not leave.\nSearching for a server with a minimum of "..serverVariables.minimumPlayers.." and a maximum of "..serverVariables.maximumPlayers.." players.")
	task.spawn(function()
		repeat
			if searched then
				if not Servers.nextPageCursor then
					warn("All servers searched")
				end
				Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100&cursor="..Servers.nextPageCursor))
			end
			
			for i,v in pairs(Servers.data) do
				if v.playing <= serverVariables.maximumPlayers and v.playing >= serverVariables.minimumPlayers then
					foundserver = true
					TeleportService:TeleportToPlaceInstance(pid, v.id)
				end
			end
			
			searched = true
			wait(1)
		until foundserver
	end)
end

--// Teleport \\--

function Tele(Plr)
	task.spawn(function()
		repeat
			local tPlr = getPlayerFromString(Plr)
			if tPlr then
				local myChar = LocalPlayer.Character
				local tChar = tPlr.Character
				if myChar and tChar then
					local myRoot = myChar:FindFirstChild("HumanoidRootPart")
					local tRoot = tChar:FindFirstChild("HumanoidRootPart")
					if myRoot and tRoot then
						GetUp()
						myRoot.CFrame = tRoot.CFrame
					end
				end
			end
			wait()
		until not teleportVariables.loop_Tele or teleportVariables.target ~= Plr or not Plr or not tPlr or not teleportVariables.target
	end)
end

function getPlayers()
	local Plrs = {}
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer then
			if v.Name ~= v.DisplayName then
				table.insert(Plrs, "@"..v.Name.." | "..v.DisplayName)
			else
				table.insert(Plrs, "@"..v.Name)
			end
		end
	end
	return Plrs
end

--// Fly \\--

function sFLY(vfly)
	repeat wait() until LocalPlayer.Character and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	
	local T = getRoot(LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0
	
	local function FLY()
		flyVariables.FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		
		task.spawn(function()
			repeat wait()
				if not vfly and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((Camera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((Camera.CoordinateFrame * CFramenew(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - Camera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((Camera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((Camera.CoordinateFrame * CFramenew(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - Camera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				
				BG.cframe = Camera.CoordinateFrame
			until not flyVariables.FLYING
			
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			
			if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	
	flyKeyDown = Mouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and flyVariables.vehicleflyspeed or flyVariables.iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and flyVariables.vehicleflyspeed or flyVariables.iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and flyVariables.vehicleflyspeed or flyVariables.iyflyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and flyVariables.vehicleflyspeed or flyVariables.iyflyspeed)
		elseif flyVariables.QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and flyVariables.vehicleflyspeed or flyVariables.iyflyspeed) * 2
		elseif flyVariables.QEfly and KEY:lower() == 'q' then
			CONTROL.E = - (vfly and flyVariables.vehicleflyspeed or flyVariables.iyflyspeed) * 2
		end
		
		pcall(function() Camera.CameraType = Enum.CameraType.Track end)
	end)
	
	flyKeyUp = Mouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	flyVariables.FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	
	if LocalPlayer.Character then
		if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		end
	end
	
	pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
end

--// Bang \\--

function Bang(Plr)
	Unbang()
	wait()
	local tPlr = getPlayerFromString(Plr)
	if tPlr then
		playerVariables.bangAnim = Instance.new("Animation")
		if not r15(LocalPlayer) then
			playerVariables.bangAnim.AnimationId = "rbxassetid://148840371"
		else
			playerVariables.bangAnim.AnimationId = "rbxassetid://5918726674"
		end
		
		bang = LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(playerVariables.bangAnim)
		bang:Play(.1, 1, 1)
		bang:AdjustSpeed(3)
		
		local bangplr = tPlr
		playerVariables.bangDied = LocalPlayer.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			playerVariables.bangLoop = playerVariables.bangLoop:Disconnect()
			bang:Stop()
			playerVariables.bangAnim:Destroy()
			playerVariables.bangDied:Disconnect()
		end)
		
		local bangOffet = CFramenew(0, 0, 1.1)
		playerVariables.bangLoop = RunService.Stepped:Connect(function()
			pcall(function()
				local otherRoot = getTorso(tPlr.Character)
				getRoot(LocalPlayer.Character).CFrame = otherRoot.CFrame * bangOffet
			end)
		end)
	end
end

function Unbang()
	if playerVariables.bangLoop then
		playerVariables.bangLoop = playerVariables.bangLoop:Disconnect()
		playerVariables.bangDied:Disconnect()
		bang:Stop()
		playerVariables.bangAnim:Destroy()
	end
end

--// All ESP \\--

local round = function(...) 
	local a = {}
	for i,v in next, table.pack(...) do
		a[i] = mathRound(v)
	end
	return unpack(a)
end

local wtvp = function(...)
	local a, b = Camera.WorldToViewportPoint(Camera, ...)
	return Vector2new(a.X, a.Y), b, a.Z
end

local function show_Data(Obj)
	if Obj then
		if espVariables.Show_Info then
			Obj.TextTransparency = 0
			Obj.TextStrokeTransparency = 0
		else
			Obj.TextTransparency = 1
			Obj.TextStrokeTransparency = 1
		end
	end
end

local function Show_Body(Plr)
	local BodyESPfolder = COREGUI:FindFirstChild(Plr.Name.."_Body")
	if BodyESPfolder and Plr and #BodyESPfolder:GetChildren() > 0 then
		for _,v in pairs(BodyESPfolder:GetChildren()) do
			if espVariables.Hide_Team and Plr.TeamColor == LocalPlayer.TeamColor then
				v.Transparency = 1
			else
				v.Transparency = .25
			end
		end
	end
end

function Esp_Activation(Plr)
	if Plr ~= LocalPlayer then
		local DataESPholder = Instance.new("Folder")
		DataESPholder.Name = Plr.Name..'_Data'
		DataESPholder.Parent = COREGUI
		
		local BodyESPholder = Instance.new("Folder")
		BodyESPholder.Name = Plr.Name..'_Body'
		BodyESPholder.Parent = COREGUI
		
		local HighlightESPholder = Instance.new("Folder")
		HighlightESPholder.Name = Plr.Name..'_Highlight'
		HighlightESPholder.Parent = COREGUI
		
		local BBG = Instance.new("BillboardGui")
		BBG.Name = Plr.Name
		BBG.Size = UDim2.new(8, 0, 3, 0)
		BBG.SizeOffset = Vector2new(0, .75)
		BBG.AlwaysOnTop = true
		BBG.Parent = DataESPholder
		
		local TL = Instance.new("TextLabel")
		TL.Name = "Here"
		TL.BackgroundTransparency = 1
		TL.Size = UDim2.new(1, 0, 1, 0)
		TL.TextScaled = true
		TL.TextColor3 = Color3.new(1, 1, 1)
		TL.TextYAlignment = Enum.TextYAlignment.Center
		TL.Text = Plr.Name
		TL.ZIndex = 10
		TL.Parent = BBG
		
		local Highlight = Instance.new("Highlight")
		Highlight.FillTransparency = 1
		Highlight.Enabled = espVariables.Highlight_ESP
		Highlight.DepthMode = "AlwaysOnTop"
		Highlight.Parent = HighlightESPholder
		
		local TracerLine = Drawingnew("Line")
		local TracerBox = Drawingnew("Square")
		
		RunService.RenderStepped:Connect(function()
			if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
				local Human = Plr.Character:FindFirstChildOfClass("Humanoid")
				
				local DataESPfolder = COREGUI:FindFirstChild(Plr.Name.."_Data")
				local BodyESPfolder = COREGUI:FindFirstChild(Plr.Name.."_Body")
				local HighlightESPfolder = COREGUI:FindFirstChild(Plr.Name.."_Highlight")
				local HL
				local BBG
				local TL
				
				local HumanoidRootPart_Position, HumanoidRootPart_Size = Plr.Character.HumanoidRootPart.CFrame, Plr.Character.HumanoidRootPart.Size * 1
				local Vector, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart_Position * CFramenew(0, -HumanoidRootPart_Size.Y, 0).p)
				
				local cframe = Plr.Character:GetModelCFrame()
				local position, visible, depth = wtvp(cframe.Position)
				local scaleFactor = 1 / (depth * mathTan(mathRad(Camera.FieldOfView / 2)) * 2) * 1000
				local width, height = round(4 * scaleFactor, 5 * scaleFactor)
				local x, y = round(position.X, position.Y)
				
				TracerLine.Thickness = 1
				TracerLine.Transparency = .75
				TracerLine.ZIndex = 10
				TracerLine.Color = Plr.TeamColor.Color
				
				TracerBox.Thickness = 2
				TracerBox.Transparency = .75
				TracerBox.ZIndex = 10
				TracerBox.Color = Plr.TeamColor.Color
				TracerBox.Filled = false
				
				TracerLine.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				
				if DataESPfolder then
					BBG = DataESPfolder:FindFirstChild(Plr.Name)
					if BBG then
						TL = BBG:FindFirstChild("Here")
					end
				end
				
				if HighlightESPfolder then
					HL = HighlightESPfolder:FindFirstChild("Highlight")
				end
				
				local Adorned = true
				if BodyESPfolder and espVariables.Body_ESP then
					if #BodyESPfolder:GetChildren() == 0 then
						Adorned = false
					else
						for _,v in pairs(BodyESPfolder:GetChildren()) do
							if not v.Adornee or v.Adornee.Parent == nil then
								Adorned = false
								v:Destroy()
							end
						end
					end
					
					if not Adorned and Plr.Character and getRoot(Plr.Character) then
						for _,v in pairs(Plr.Character:GetChildren()) do
							if v:IsA("BasePart") then
								local a = Instance.new("BoxHandleAdornment")
								a.Name = v.Name
								a.Adornee = v
								a.AlwaysOnTop = true
								a.ZIndex = 10
								a.Size = v.Size
								a.Transparency = .25
								a.Color = Plr.TeamColor
								a.Parent = BodyESPfolder
							end
						end
					end
				elseif BodyESPfolder and not espVariables.Body_ESP then
					if #BodyESPfolder:GetChildren() > 0 then
						for _,v in pairs(BodyESPfolder:GetChildren()) do
							v:Destroy()
						end
					end
				end
				
				if HL then
					if Plr.Character and HL.Adornee ~= Plr.Character then
						HL.Adornee = Plr.Character
					end
					
					HL.OutlineColor = Plr.TeamColor.Color
				end
				
				if OnScreen and visible and Human then
					if Human.Health > 0 then
						TracerLine.To = Vector2new(Vector.X, Vector.Y)
						TracerBox.Size = Vector2new(width, height)
						TracerBox.Position = Vector2new(round(x - width / 2, y - height / 2))
						
						if espVariables.Hide_Team then
							if Plr.TeamColor == LocalPlayer.TeamColor then
								TracerLine.Visible = false
								TracerBox.Visible = false
								
								if TL then
									TL.TextTransparency = 1
									TL.TextStrokeTransparency = 1
								end
								
								Show_Body(Plr)
								
								if HL then
									HL.Enabled = false
								end
							else
								TracerLine.Visible = espVariables.Tracers_Visible
								TracerBox.Visible = espVariables.Box_ESP
								
								if TL then
									show_Data(TL)
								end
								
								Show_Body(Plr)
								
								if HL then
									HL.Enabled = espVariables.Highlight_ESP
								end
							end
						else
							TracerLine.Visible = espVariables.Tracers_Visible
							TracerBox.Visible = espVariables.Box_ESP
							
							if TL then
								show_Data(TL)
							end
							
							Show_Body(Plr)
							
							if HL then
								HL.Enabled = espVariables.Highlight_ESP
							end
						end
					else
						TracerLine.Visible = false
						TracerBox.Visible = false
						
						if TL then
							TL.TextTransparency = 1
							TL.TextStrokeTransparency = 1
						end
						
						if HL then
							HL.Enabled = false
						end
					end
				else
					TracerLine.Visible = false
					TracerBox.Visible = false
					
					if TL then
						TL.TextTransparency = 1
						TL.TextStrokeTransparency = 1
					end
					
					if HL then
						HL.Enabled = false
					end
				end
			else
				TracerLine.Visible = false
				TracerBox.Visible = false
				
				if TL then
					TL.TextTransparency = 1
					TL.TextStrokeTransparency = 1
				end
				
				if HL then
					HL.Enabled = false
				end
			end
			
			if BBG and TL then
				if Plr.Character and Plr.Character:FindFirstChild('Head') and getRoot(Plr.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
					BBG.Adornee = Plr.Character.Head
					
					local pos = mathFloor(LocalPlayer:DistanceFromCharacter(getRoot(Plr.Character).Position))
					if Plr.Name ~= Plr.DisplayName then
						TL.Text = '@'..Plr.Name..'\n['..Plr.DisplayName..']\n('..pos..')'
					else
						TL.Text = '@'..Plr.Name..'\n('..pos..')'
					end
				end
			end
		end)
		
		Players.PlayerRemoving:Connect(function()
			TracerLine.Visible = false
			TracerBox.Visible = false
		end)
	end
end

--// Other Functions \\--

function StopFreecam()
	if not fcRunning then return end
	
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
	workspace.Camera.FieldOfView = 70
	fcRunning = false
end

function respawn(Plr)
	local char = Plr.Character
	
	if char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid"):ChangeState(15)
	end
	
	char:ClearAllChildren()
	
	local newChar = Instance.new("Model")
	newChar.Parent = workspace
	Plr.Character = newChar
	wait()
	Plr.Character = char
	newChar:Destroy()
end

function refresh(Plr)
	playerVariables.refreshCmd = true
	local Human = Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid", true)
	local pos = Human and Human.RootPart and Human.RootPart.CFrame
	local pos1 = Camera.CFrame
	
	respawn(Plr)
	
	task.spawn(function()
		Plr.CharacterAdded:Wait():WaitForChild("Humanoid").RootPart.CFrame, Camera.CFrame = pos, wait() and pos1
		playerVariables.refreshCmd = false
	end)
end

--// UI \\--

local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

MainGui = Material.Load({
	Title = "Command UI",
	Style = 1,
	SizeX = 400,
	SizeY = 500,
	Theme = "Dark"
})

Title_1 = MainGui.New({
	Title = "Player"
})

Title_2 = MainGui.New({
	Title = "Tele/Spy"
})

Title_3 = MainGui.New({
	Title = "Server"
})

Title_4 = MainGui.New({
	Title = "Fly/Perv"
})

Title_5 = MainGui.New({
	Title = "Lighting"
})

Title_6 = MainGui.New({
	Title = "ESP"
})

--// Player \\--

Title_1_Object_1 = Title_1.Toggle({
	Text = "Auto Shrink",
	Callback = function(Value)
		getgenv().settings.auto_Shrink = Value
		saveSettings()
		if getgenv().settings.auto_Shrink then
			spawn(shrink)
		end
	end,
	Enabled = getgenv().settings.auto_Shrink
})

Title_1_Object_2 = Title_1.Toggle({
	Text = "Noclip",
	Callback = function(Value)
		if Value then
			local function NoclipLoop()
				if LocalPlayer.Character ~= nil then
					for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
						if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
							child.CanCollide = false
						end
					end
				end
			end
			
			playerVariables.Noclipping = RunService.Stepped:Connect(NoclipLoop)
		end
		
		if not Value and playerVariables.Noclipping then
			playerVariables.Noclipping:Disconnect()
		end
	end,
	Enabled = false
})

Title_1_Object_3 = Title_1.Button({
	Text = "Lay",
	Callback = function(Value)
		local Human = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
		if not Human then
			return
		end
		
		Human.Sit = true
		task.wait(.1)
		Human.RootPart.CFrame = Human.RootPart.CFrame * CFrame.Angles(math.pi * .5, 0, 0)
		
		for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Makes your character lay down."
			})
		end
	}
})

Title_1_Object_4 = Title_1.Button({
	Text = "Respawn",
	Callback = function(Value)
		respawn(LocalPlayer)
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Respawns you."
			})
		end
	}
})

Title_1_Object_5 = Title_1.Button({
	Text = "Refresh",
	Callback = function(Value)
		refresh(LocalPlayer)
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Respawns and brings you back to the same position."
			})
		end
	}
})

Title_1_Object_6 = Title_1.Slider({
	Text = "Spin Speed",
	Callback = function(Value)
		playerVariables.spinSpeed = Value
		for i,v in pairs(getRoot(LocalPlayer.Character):GetChildren()) do
			if v.Name == "Spinning" then
				v.AngularVelocity = Vector3.new(0, playerVariables.spinSpeed, 0)
			end
		end
	end,
	Min = 1,
	Max = 100,
	Def = 20
})

Title_1_Object_7 = Title_1.Toggle({
	Text = "Spin",
	Callback = function(Value)
		if Value then
			local Spin = Instance.new("BodyAngularVelocity")
			Spin.Name = "Spinning"
			Spin.Parent = getRoot(LocalPlayer.Character)
			Spin.MaxTorque = Vector3.new(0, math.huge, 0)
			Spin.AngularVelocity = Vector3.new(0, playerVariables.spinSpeed, 0)
		elseif not Value and LocalPlayer.Character then
			for i,v in pairs(getRoot(LocalPlayer.Character):GetChildren()) do
				if v.Name == "Spinning" then
					v:Destroy()
				end
			end
		end
	end,
	Enabled = false
})

Title_1_Object_8 = Title_1.Button({
	Text = "Split",
	Callback = function(Value)
		if r15(LocalPlayer) then
			local waist = LocalPlayer.Character.UpperTorso:FindFirstChild("Waist")
			if waist then
				waist:Destroy()
			end
		end
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Splits your character in half."
			})
		end
	}
})

--// Teleport/Spy \\--

Title_2_Object_1 = Title_2.Toggle({
	Text = "Click Teleport (Hold LContol/LShift)",
	Callback = function(Value)
		getgenv().settings.click_Tele = Value
		saveSettings()
	end,
	Enabled = getgenv().settings.click_Tele
})

Title_2_Object_2 = Title_2.Button({
	Text = "Flashback",
	Callback = function(Value)
		if playerVariables.lastDeath then
			if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') and LocalPlayer.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(LocalPlayer.Character).CFrame = playerVariables.lastDeath
		end
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Teleport back to the last place you died."
			})
		end
	}
})

Title_2_Object_3 = Title_2.Toggle({
	Text = "Loop Tele",
	Callback = function(Value)
		teleportVariables.loop_Tele = Value
		if Value then
			Tele(teleportVariables.target)
		end
	end,
	Enabled = false
})

Title_2_Object_4 = Title_2.Dropdown({
	Text = "Teleport To",
	Callback = function(Value)
		teleportVariables.target = Value
		Tele(Value)
	end,
	Options = temp_List
})

Title_2_Object_5 = Title_2.Button({
	Text = "Unview",
	Callback = function(Value)
		StopFreecam()
		
		if playerVariables.viewing then
			playerVariables.viewing = nil
		end
		
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		
		Camera.CameraSubject = LocalPlayer.Character
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Stops spying."
			})
		end
	}
})

Title_2_Object_6 = Title_2.Dropdown({
	Text = "View",
	Callback = function(Value)
		StopFreecam()
		local tPlr = getPlayerFromString(Value)
		if tPlr then
			if viewDied then
				viewDied:Disconnect()
				viewChanged:Disconnect()
			end
			
			playerVariables.viewing = tPlr
			Camera.CameraSubject = playerVariables.viewing.Character
			
			local function viewDiedFunc()
				repeat wait() until playerVariables.viewing.Character and getRoot(playerVariables.viewing.Character)
				Camera.CameraSubject = playerVariables.viewing.Character
			end
			
			viewDied = playerVariables.viewing.CharacterAdded:Connect(viewDiedFunc)
			
			local function viewChangedFunc()
				Camera.CameraSubject = playerVariables.viewing.Character
			end
			
			viewChanged = Camera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
		end
	end,
	Options = temp_List
})

Title_2_Object_7 = Title_2.Dropdown({
	Text = "Headsit",
	Callback = function(Value)
		local tPlr = getPlayerFromString(Value)
		if tPlr then
			if headSit then
				headSit:Disconnect() 
			end
			
			LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = true
			
			headSit = RunService.Heartbeat:Connect(function()
				if tPlr.Character ~= nil and getRoot(tPlr.Character) and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit == true then
					getRoot(LocalPlayer.Character).CFrame = getRoot(tPlr.Character).CFrame * CFrame.Angles(0, mathRad(0), 0) * CFramenew(0, 1.6, .5)
				else
					headSit:Disconnect()
				end
			end)
		end
	end,
	Options = temp_List
})

--// Server \\--

Title_3_Object_1 = Title_3.Slider({
	Text = "Min Players",
	Callback = function(Value)
		serverVariables.minimumPlayers = Value
	end,
	Min = 1,
	Max = serverVariables.maximumPlayers,
	Def = 1
})

Title_3_Object_2 = Title_3.Slider({
	Text = "Max Players",
	Callback = function(Value)
		serverVariables.maximumPlayers = Value
	end,
	Min = 1,
	Max = serverVariables.maximumPlayers,
	Def = serverVariables.maximumPlayers
})

Title_3_Object_3 = Title_3.Button({
	Text = "Server Hop",
	Callback = function(Value)
		ServerHop()
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Hops to the first server that has between Min and Max amount of players."
			})
		end
	}
})

Title_3_Object_4 = Title_3.Button({
	Text = "Rejoin",
	Callback = function(Value)
		if #Players:GetPlayers() <= 1 then
			LocalPlayer:Kick("\nRejoining...")
			wait()
			TeleportService:Teleport(game.PlaceId, LocalPlayer)
		else
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Rejoins the current server."
			})
		end
	}
})

--// Fly/Perv \\--

Title_4_Object_1 = Title_4.Slider({
	Text = "Fly Speed",
	Callback = function(Value)
		flyVariables.iyflyspeed = Value
		flyVariables.vehicleflyspeed = Value
	end,
	Min = 1,
	Max = 25,
	Def = 1
})

Title_4_Object_2 = Title_4.Toggle({
	Text = "Fly",
	Callback = function(Value)
		if Value then
			NOFLY()
			wait()
			sFLY()
		else
			NOFLY()
		end
	end,
	Enabled = false
})

Title_4_Object_3 = Title_4.Toggle({
	Text = "Vehicle Fly",
	Callback = function(Value)
		if Value then
			NOFLY()
			wait()
			sFLY(true)
		else
			NOFLY()
		end
	end,
	Enabled = false
})

Title_4_Object_4 = Title_4.Toggle({
	Text = "Q/E Fly",
	Callback = function(Value)
		flyVariables.QEfly = Value
	end,
	Enabled = flyVariables.QEfly
})

Title_4_Object_5 = Title_4.Button({
	Text = "Unbang",
	Callback = function(Value)
		Unbang()
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Stops banging."
			})
		end
	}
})

Title_4_Object_6 = Title_4.Dropdown({
	Text = "Bang",
	Callback = function(Value)
		Bang(Value)
	end,
	Options = temp_List
})

Title_4_Object_7 = Title_4.Dropdown({
	Text = "Facesit",
	Callback = function(Value)
		local tPlr = getPlayerFromString(Value)
		if tPlr then
			if headSit then
				headSit:Disconnect()
			end
			
			LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = true
			
			headSit = RunService.Heartbeat:Connect(function()
				if tPlr.Character ~= nil and getRoot(tPlr.Character) and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit == true then
					getRoot(LocalPlayer.Character).CFrame = getRoot(tPlr.Character).CFrame * CFrame.Angles(0, mathRad(180), 0) * CFramenew(0, 1.25, 1)
				else
					headSit:Disconnect()
				end
			end)
		end
	end,
	Options = temp_List
})

Title_4_Object_8 = Title_4.Toggle({
	Text = "Swim",
	Callback = function(Value)
		if Value and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
			flyVariables.Old_Grav = workspace.Gravity
			workspace.Gravity = 0
			
			local swimDied = function()
				workspace.Gravity = flyVariables.Old_Grav
			end
			
			local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
			gravReset = Humanoid.Died:Connect(swimDied)
			
			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			
			for i, v in pairs(enums) do
				Humanoid:SetStateEnabled(v, false)
			end
			
			Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
			
			playerVariables.swimbeat = RunService.Heartbeat:Connect(function()
				pcall(function()
					LocalPlayer.Character.HumanoidRootPart.Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and LocalPlayer.Character.HumanoidRootPart.Velocity or Vector3.new())
				end)
			end)
		elseif not Value and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
			workspace.Gravity = flyVariables.Old_Grav
			
			if gravReset then
				gravReset:Disconnect()
			end
			
			if playerVariables.swimbeat then
				playerVariables.swimbeat:Disconnect()
				playerVariables.swimbeat = nil
			end
			
			local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			
			for i, v in pairs(enums) do
				Humanoid:SetStateEnabled(v, true)
			end
		end
	end,
	Enabled = false
})

--// Lighting \\--

Title_5_Object_1 = Title_5.Button({
	Text = "Fullbright",
	Callback = function(Value)
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3fromRGB(128, 128, 128)
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Makes it all bright."
			})
		end
	}
})

Title_5_Object_2 = Title_5.Slider({
	Text = "Set Time",
	Callback = function(Value)
		Lighting.ClockTime = Value
	end,
	Min = 1,
	Max = 24,
	Def = Lighting.ClockTime
})

Title_5_Object_3 = Title_5.Button({
	Text = "No Fog",
	Callback = function(Value)
		Lighting.FogEnd = 100000
		for i,v in pairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Gets rid of fog."
			})
		end
	}
})

Title_5_Object_4 = Title_5.Toggle({
	Text = "Global Shadows",
	Callback = function(Value)
		Lighting.GlobalShadows = Value
	end,
	Enabled = Lighting.GlobalShadows
})

Title_5_Object_5 = Title_5.Button({
	Text = "Restore Lighting",
	Callback = function(Value)
		Lighting.Ambient = lightingVariables.origsettings.abt
		Lighting.OutdoorAmbient = lightingVariables.origsettings.oabt
		Lighting.Brightness = lightingVariables.origsettings.brt
		Lighting.ClockTime = lightingVariables.origsettings.time
		Lighting.FogEnd = lightingVariables.origsettings.fe
		Lighting.FogStart = lightingVariables.origsettings.fs
		Lighting.GlobalShadows = lightingVariables.origsettings.gs
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Returns lighting to its original state."
			})
		end
	}
})

Title_5_Object_6 = Title_5.Toggle({
	Text = "Fullbright Loop",
	Callback = function(Value)
		if Value then
			local function brightFunc()
				Lighting.Brightness = 2
				Lighting.ClockTime = 14
				Lighting.FogEnd = 100000
				Lighting.GlobalShadows = false
				Lighting.OutdoorAmbient = Color3fromRGB(128, 128, 128)
			end
			
			lightingVariables.brightLoop = RunService.RenderStepped:Connect(brightFunc)
		elseif not Value and lightingVariables.brightLoop then
			lightingVariables.brightLoop:Disconnect()
		end
	end,
	Enabled = false
})

--// ESP \\--

Title_6_Object_1 = Title_6.Toggle({
	Text = "Body ESP",
	Callback = function(Value)
		espVariables.Body_ESP = Value
	end,
	Enabled = espVariables.Body_ESP
})

Title_6_Object_2 = Title_6.Toggle({
	Text = "Box ESP",
	Callback = function(Value)
		espVariables.Box_ESP = Value
	end,
	Enabled = espVariables.Box_ESP
})

Title_6_Object_3 = Title_6.Toggle({
	Text = "Highlight ESP",
	Callback = function(Value)
		espVariables.Highlight_ESP = Value
	end,
	Enabled = espVariables.Highlight_ESP
})

Title_6_Object_4 = Title_6.Toggle({
	Text = "Tracers",
	Callback = function(Value)
		espVariables.Tracers_Visible = Value
	end,
	Enabled = espVariables.Tracers_Visible
})

Title_6_Object_5 = Title_6.Toggle({
	Text = "Show Info",
	Callback = function(Value)
		espVariables.Show_Info = Value
	end,
	Enabled = espVariables.Show_Info
})

Title_6_Object_6 = Title_6.Toggle({
	Text = "Hide Team",
	Callback = function(Value)
		espVariables.Hide_Team = Value
	end,
	Enabled = espVariables.Hide_Team
})

Title_6_Object_7 = Title_6.Toggle({
	Text = "Aimbot",
	Callback = function(Value)
		aimbotVariables.Aimbot = Value
	end,
	Enabled = aimbotVariables.Aimbot
})

Title_6_Object_8 = Title_6.Toggle({
	Text = "Team Check",
	Callback = function(Value)
		aimbotVariables.Team_Check = Value
	end,
	Enabled = aimbotVariables.Team_Check
})

Title_6_Object_9 = Title_6.Toggle({
	Text = "Wall Check",
	Callback = function(Value)
		aimbotVariables.Wall_Check = Value
	end,
	Enabled = aimbotVariables.Wall_Check
})

Title_6_Object_10 = Title_6.Toggle({
	Text = "Third Person",
	Callback = function(Value)
		aimbotVariables.Third_Person = Value
	end,
	Enabled = aimbotVariables.Third_Person
})

Title_6_Object_11 = Title_6.Dropdown({
	Text = "Target",
	Callback = function(Value)
		aimbotVariables.LockPart = Value
	end,
	Options = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}
})

--// Player List Update \\--

function GetList()
	local Plr_List = getPlayers()
	Title_2_Object_4:SetOptions(Plr_List)
	Title_2_Object_6:SetOptions(Plr_List)
	Title_2_Object_7:SetOptions(Plr_List)
	Title_4_Object_6:SetOptions(Plr_List)
	Title_4_Object_7:SetOptions(Plr_List)
end

function onDied()
	task.spawn(function()
		if pcall(function() LocalPlayer.Character:FindFirstChildOfClass('Humanoid') end) and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(LocalPlayer.Character) then
					playerVariables.lastDeath = getRoot(LocalPlayer.Character).CFrame
				end
			end)
			
			if getgenv().settings.auto_Shrink then
				spawn(shrink)
			end
		else
			wait(2)
			onDied()
		end
	end)
end

Players.PlayerAdded:Connect(function(Plr)
	GetList()
	Esp_Activation(Plr)
end)

Players.PlayerRemoving:Connect(function(Plr)
	GetList()
	
	for i,v in pairs(COREGUI:GetChildren()) do
		if v.Name == Plr.Name..'_Data' or v.Name == Plr.Name..'_Body' or v.Name == Plr.Name.."_Highlight" then
			v:Destroy()
		end
	end
	
	if playerVariables.viewing and Plr == playerVariables.viewing then
		Camera.CameraSubject = LocalPlayer.Character
		playerVariables.viewing = nil
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
	end
end)

GetList()

--// Click Teleport \\--

Mouse.Button1Down:Connect(function()
	if teleportVariables.Held_Button and getgenv().settings.click_Tele then
		local root = LocalPlayer.Character.HumanoidRootPart
		local pos = Mouse.Hit.Position + Vector3.new(0, 2.5, 0)
		local offset = pos-root.Position
		GetUp()
		root.CFrame = root.CFrame + offset
	end
end)

UserInputService.InputBegan:Connect(function(key, gp)
	if key.KeyCode == Enum.KeyCode.LeftControl or key.KeyCode == Enum.KeyCode.LeftShift then
		teleportVariables.Held_Button = true
	end
end)

UserInputService.InputEnded:Connect(function(key, gp)
	if key.KeyCode == Enum.KeyCode.LeftControl or key.KeyCode == Enum.KeyCode.LeftShift then
		teleportVariables.Held_Button = false
	end
end)

--// Respawn \\--

LocalPlayer.CharacterAdded:Connect(function(char)
	NOFLY()
	repeat wait() until getRoot(char)
	onDied()
end)

onDied()

--// Typing Check \\--

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Load Aimbot/ESP \\--

Load()

for _, v in pairs(Players:GetPlayers()) do
	Esp_Activation(v)
end

--// Settings Lock \\--

settingsLock = false
