--// Auto shrink scale settings \\--

--[[
Height 0%
Width 0%
Head 100%
Proportions 100%
Body Type 0%
]]

local Run_It = true
if not Run_It then return end

local COREGUI = game:GetService("CoreGui")
if not game:IsLoaded() then
	game.Loaded:Wait()
end

--// Variables \\--

local TeleportService = game:GetService('TeleportService')
local VirtualUser = game:GetService("VirtualUser")
local httpservice = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local UIS = game:GetService('UserInputService')
local Lighting = game:GetService('Lighting')
local Players = game:GetService('Players')

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local sethidden = sethiddenproperty or set_hidden_property or set_hidden_prop
local gethidden = gethiddenproperty or get_hidden_property or get_hidden_prop
local setsimulation = setsimulationradius or set_simulation_radius

local Me = Players.LocalPlayer
local mouse = Me:GetMouse()

local oldgrav = workspace.Gravity
local vehicleflyspeed = 1
local iyflyspeed = 1
local spinSpeed = 20
local Held_Button = false
local refreshCmd = false
local loop_Tele = false
local ESPenabled = false
local Tracers_Visible = false
local Hide_Team = false
local target = false
local FLYING = false
local QEfly = true
local Noclipping = nil
local brightLoop = nil
local bangLoop = nil
local bangAnim = nil
local bangDied = nil
local swimbeat = nil
local viewing = nil
local lastDeath
local minimumPlayers = 1
local maximumPlayers = Players.MaxPlayers - 1

local origsettings = {abt = Lighting.Ambient, oabt = Lighting.OutdoorAmbient, brt = Lighting.Brightness, time = Lighting.ClockTime, fe = Lighting.FogEnd, fs = Lighting.FogStart, gs = Lighting.GlobalShadows}
local temp_List = {"Player", "List", "Will", "Replace", "This"}

--// Anti AFK \\--

local GC = getconnections or get_signal_cons
if GC then
	for i,v in pairs(GC(Me.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
		elseif v["Disconnect"] then
			v["Disconnect"](v)
		end
	end
else
	Me.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end

--// Settings Save/Load \\--

getgenv().settings = {}

if isfile("CommandUISettings.txt") then
	getgenv().settings = httpservice:JSONDecode(readfile('CommandUISettings.txt'))
end

local sNames = {"auto_Shrink", "click_Tele"}
local sValues = {false, false}

if #getgenv().settings ~= sNames then
	for i, v in ipairs(sNames) do
		if getgenv().settings[v] == nil then
			getgenv().settings[v] = sValues[i]
		end
	end
	
	writefile('CommandUISettings.txt', httpservice:JSONEncode(getgenv().settings))
end

local settingsLock = true

local function saveSettings()
	if settingsLock == false then
		print('Settings saved.')
		writefile('CommandUISettings.txt', httpservice:JSONEncode(getgenv().settings))
	end
end

--// Functions \\--

function GetUp()
	if Me.Character:FindFirstChildOfClass('Humanoid') and Me.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		Me.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function getTorso(x)
	x = x or Me.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

--// Shrink \\--

local shrink = function()
	task.spawn(function()
		wait(3)
		local suc, err = pcall(function()
			local Hum = Me.Character:FindFirstChild("Humanoid")
			if Hum and r15(Me) then
			
				local function rm()
					for _, v in pairs(Me.Character:GetDescendants()) do
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
	if minimumPlayers > maximumPlayers then return end
	local foundserver = false
	local searched = false
	local pid = game.PlaceId
	local Servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"))
	Me:Kick("\nDo not leave.\nSearching for a server with a minimum of "..minimumPlayers.." and a maximum of "..maximumPlayers.." players.")
	task.spawn(function()
		repeat
			if searched then
				if not Servers.nextPageCursor then
					warn("All servers searched")
				end
				Servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100&cursor="..Servers.nextPageCursor))
			end
			
			for i,v in pairs(Servers.data) do
				if v.playing <= maximumPlayers and v.playing >= minimumPlayers then
					foundserver = true
					TeleportService:TeleportToPlaceInstance(pid, v.id)
				end
			end
			
			searched = true
			wait(1)
		until foundserver
	end)
end

--// Teleporter \\--

function Tele(plr)
	task.spawn(function()
		repeat
			local tPlr = Players:FindFirstChild(string.sub(plr, 1, string.find(plr, " ") - 1))
			if tPlr then
				local myChar = Me.Character
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
		until not loop_Tele or target ~= plr or not plr or not tPlr or not target
	end)
end

function getPlayers()
	local Plrs = {}
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= Me then
			if v.Name ~= v.DisplayName then
				table.insert(Plrs, v.Name.." - "..v.DisplayName)
			else
				table.insert(Plrs, v.Name)
			end
		end
	end
	return Plrs
end

--// Fly \\--

function sFLY(vfly)
	repeat wait() until Me and Me.Character and getRoot(Me.Character) and Me.Character:FindFirstChildOfClass("Humanoid")
	repeat wait() until mouse
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

	local T = getRoot(Me.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
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
				if not vfly and Me.Character:FindFirstChildOfClass('Humanoid') then
					Me.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			
			if Me.Character:FindFirstChildOfClass('Humanoid') then
				Me.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	
	flyKeyDown = mouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed) * 2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = - (vfly and vehicleflyspeed or iyflyspeed) * 2
		end
		
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	
	flyKeyUp = mouse.KeyUp:Connect(function(KEY)
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
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	
	if Me.Character then
		if Me.Character:FindFirstChildOfClass('Humanoid') then
			Me.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		end
	end
	
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

--// Bang \\--

function Bang(plr)
	Unbang()
	wait()
	local tPlr = Players:FindFirstChild(string.sub(plr, 1, string.find(plr, " ") - 1))
	if tPlr then
	
		bangAnim = Instance.new("Animation")
		if not r15(Me) then
			bangAnim.AnimationId = "rbxassetid://148840371"
		else
			bangAnim.AnimationId = "rbxassetid://5918726674"
		end
		
		bang = Me.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(bangAnim)
		bang:Play(.1, 1, 1)
		bang:AdjustSpeed(3)
		
		local bangplr = tPlr
		bangDied = Me.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			bangLoop = bangLoop:Disconnect()
			bang:Stop()
			bangAnim:Destroy()
			bangDied:Disconnect()
		end)
		
		local bangOffet = CFrame.new(0, 0, 1.1)
		bangLoop = RunService.Stepped:Connect(function()
			pcall(function()
				local otherRoot = getTorso(tPlr.Character)
				getRoot(Me.Character).CFrame = otherRoot.CFrame * bangOffet
			end)
		end)
	end
end

function Unbang()
	if bangLoop then
		bangLoop = bangLoop:Disconnect()
		bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
	end
end

--// ESP \\--

function ESP(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		
		if not ESPenabled then return end
		
		wait()
		
		if plr.Character and plr ~= Me and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			
			repeat wait() until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					if Hide_Team and plr.TeamColor == Me.TeamColor then
						a.Transparency = 1
					else
						a.Transparency = .5
					end
					a.Color = plr.TeamColor
				end
			end
			
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(10, 0, 3, 0)
				BillboardGui.SizeOffset = Vector2.new(0, .75)
				BillboardGui.AlwaysOnTop = true
				
				local TextLabel = Instance.new("TextLabel")
				TextLabel.BackgroundTransparency = 1
				TextLabel.Size = UDim2.new(1, 0, 1, 0)
				TextLabel.TextScaled = true
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextYAlignment = Enum.TextYAlignment.Center
				TextLabel.Text = plr.Name
				TextLabel.ZIndex = 10
				
				if Hide_Team and plr.TeamColor == Me.TeamColor then
					TextLabel.TextTransparency = 1
					TextLabel.TextStrokeTransparency = 1
				else
					TextLabel.TextTransparency = 0
					TextLabel.TextStrokeTransparency = 0
				end
				
				TextLabel.Parent = BillboardGui
				
				local espLoopFunc
				local teamChange
				local addedFunc
				
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait() until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait() until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Me.Character and getRoot(Me.Character) and Me.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor(Me:DistanceFromCharacter(getRoot(plr.Character).Position))
							if plr.Name ~= plr.DisplayName then
								TextLabel.Text = plr.Name..'\n'..plr.DisplayName..'\n'..pos
							else
								TextLabel.Text = plr.Name..'\n'..pos
							end
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

--// Tracers \\--

function activateTracers(Plr)
	if Plr ~= Me then
		local TracerLine = Drawing.new("Line")

		RunService.RenderStepped:Connect(function()
			if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
				local HumanoidRootPart_Position, HumanoidRootPart_Size = Plr.Character.HumanoidRootPart.CFrame, Plr.Character.HumanoidRootPart.Size * 1
				local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart_Position * CFrame.new(0, -HumanoidRootPart_Size.Y, 0).p)
				
				TracerLine.Thickness = 1
				TracerLine.Transparency = .5
				TracerLine.Color = Plr.TeamColor.Color

				TracerLine.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)

				if OnScreen then
					TracerLine.To = Vector2.new(Vector.X, Vector.Y)
					if Hide_Team then
						if Plr.TeamColor == Me.TeamColor then
							TracerLine.Visible = false
						else
							TracerLine.Visible = Tracers_Visible
						end
					else
						TracerLine.Visible = Tracers_Visible
					end
				else
					TracerLine.Visible = false
				end
			else
				TracerLine.Visible = false
			end
		end)

		Players.PlayerRemoving:Connect(function(plr)
			if plr == v then
				TracerLine.Visible = false
			end
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

function respawn(plr)
	local char = plr.Character
	
	if char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid"):ChangeState(15) 
	end
	
	char:ClearAllChildren()
	
	local newChar = Instance.new("Model")
	newChar.Parent = workspace
	plr.Character = newChar
	wait()
	plr.Character = char
	newChar:Destroy()
end

function refresh(plr)
	refreshCmd = true
	local Human = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid", true)
	local pos = Human and Human.RootPart and Human.RootPart.CFrame
	local pos1 = workspace.CurrentCamera.CFrame
	
	respawn(plr)
	
	task.spawn(function()
		plr.CharacterAdded:Wait():WaitForChild("Humanoid").RootPart.CFrame, workspace.CurrentCamera.CFrame = pos, wait() and pos1
		refreshCmd = false
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
				if Me.Character ~= nil then
					for _, child in pairs(Me.Character:GetDescendants()) do
						if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
							child.CanCollide = false
						end
					end
				end
			end
			
			Noclipping = RunService.Stepped:Connect(NoclipLoop)
		end
		
		if not Value and Noclipping then
			Noclipping:Disconnect()
		end
	end,
	Enabled = false
})

Title_1_Object_3 = Title_1.Toggle({
	Text = "Swim",
	Callback = function(Value)
		if Value and Me and Me.Character and Me.Character:FindFirstChildWhichIsA("Humanoid") then
			oldgrav = workspace.Gravity
			workspace.Gravity = 0
			
			local swimDied = function()
				workspace.Gravity = oldgrav
			end
			
			local Humanoid = Me.Character:FindFirstChildWhichIsA("Humanoid")
			gravReset = Humanoid.Died:Connect(swimDied)
			
			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			
			for i, v in pairs(enums) do
				Humanoid:SetStateEnabled(v, false)
			end
			
			Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
			
			swimbeat = RunService.Heartbeat:Connect(function()
				pcall(function()
					Me.Character.HumanoidRootPart.Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and Me.Character.HumanoidRootPart.Velocity or Vector3.new())
				end)
			end)
		elseif not Value and Me and Me.Character and Me.Character:FindFirstChildWhichIsA("Humanoid") then
			workspace.Gravity = oldgrav
			
			if gravReset then
				gravReset:Disconnect()
			end
			
			if swimbeat ~= nil then
				swimbeat:Disconnect()
				swimbeat = nil
			end
			
			local Humanoid = Me.Character:FindFirstChildWhichIsA("Humanoid")
			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			
			for i, v in pairs(enums) do
				Humanoid:SetStateEnabled(v, true)
			end
		end
	end,
	Enabled = false
})

Title_1_Object_4 = Title_1.Button({
	Text = "Lay",
	Callback = function(Value)
		local Human = Me.Character and Me.Character:FindFirstChildOfClass('Humanoid')
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

Title_1_Object_5 = Title_1.Button({
	Text = "Respawn",
	Callback = function(Value)
		respawn(Me)
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Respawns you."
			})
		end
	}
})

Title_1_Object_6 = Title_1.Button({
	Text = "Refresh",
	Callback = function(Value)
		refresh(Me)
	end,
	Menu = {
		Info = function(self)
			MainGui.Banner({
				Text = "Respawns and brings you back to the same position."
			})
		end
	}
})

Title_1_Object_7 = Title_1.Slider({
	Text = "Spin Speed",
	Callback = function(Value)
		spinSpeed = Value
		for i,v in pairs(getRoot(Me.Character):GetChildren()) do
			if v.Name == "Spinning" then
				v.AngularVelocity = Vector3.new(0,spinSpeed,0)
			end
		end
	end,
	Min = 1,
	Max = 100,
	Def = 20
})

Title_1_Object_8 = Title_1.Toggle({
	Text = "Spin",
	Callback = function(Value)
		if Value then
			local Spin = Instance.new("BodyAngularVelocity")
			Spin.Name = "Spinning"
			Spin.Parent = getRoot(Me.Character)
			Spin.MaxTorque = Vector3.new(0, math.huge, 0)
			Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
		elseif not Value and Me.Character then
			for i,v in pairs(getRoot(Me.Character):GetChildren()) do
				if v.Name == "Spinning" then
					v:Destroy()
				end
			end
		end
	end,
	Enabled = false
})

Title_1_Object_9 = Title_1.Button({
	Text = "Split",
	Callback = function(Value)
		if r15(Me) then
			local waist = Me.Character.UpperTorso:FindFirstChild("Waist")
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

--// Teleport \\--

Title_2_Object_1 = Title_2.Toggle({
	Text = "Click Teleport (Hold Left Contol/Shift)",
	Callback = function(Value)
		getgenv().settings.click_Tele = Value
		saveSettings()
	end,
	Enabled = getgenv().settings.click_Tele
})

Title_2_Object_2 = Title_2.Button({
	Text = "Flashback",
	Callback = function(Value)
		if lastDeath then
			if Me.Character:FindFirstChildOfClass('Humanoid') and Me.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				Me.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(Me.Character).CFrame = lastDeath
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
		loop_Tele = Value
		if Value then
			Tele(target)
		end
	end,
	Enabled = false
})

Title_2_Object_4 = Title_2.Dropdown({
	Text = "Teleport To",
	Callback = function(Value)
		target = Value
		Tele(Value)
	end,
	Options = temp_List
})

Title_2_Object_5 = Title_2.Button({
	Text = "Unview",
	Callback = function(Value)
		StopFreecam()
		
		if viewing ~= nil then
			viewing = nil
		end
		
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		
		workspace.CurrentCamera.CameraSubject = Me.Character
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
		
		local plr = Value
		local tPlr = Players:FindFirstChild(string.sub(plr, 1, string.find(plr, " ") - 1))
		if tPlr then
			if viewDied then
				viewDied:Disconnect()
				viewChanged:Disconnect()
			end
			
			viewing = tPlr
			workspace.CurrentCamera.CameraSubject = viewing.Character
			
			local function viewDiedFunc()
				repeat wait() until viewing.Character ~= nil and getRoot(viewing.Character)
				workspace.CurrentCamera.CameraSubject = viewing.Character
			end
			
			viewDied = viewing.CharacterAdded:Connect(viewDiedFunc)
			
			local function viewChangedFunc()
				workspace.CurrentCamera.CameraSubject = viewing.Character
			end
			
			viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
		end
	end,
	Options = temp_List
})

Title_2_Object_7 = Title_2.Dropdown({
	Text = "Headsit",
	Callback = function(Value)
		local plr = Value
		local tPlr = Players:FindFirstChild(string.sub(plr, 1, string.find(plr, " ") - 1))
		if tPlr then
			if headSit then
				headSit:Disconnect() 
			end
			
			Me.Character:FindFirstChildOfClass('Humanoid').Sit = true
			
			headSit = RunService.Heartbeat:Connect(function()
				if tPlr.Character ~= nil and getRoot(tPlr.Character) and getRoot(Me.Character) and Me.Character:FindFirstChildOfClass('Humanoid').Sit == true then
					getRoot(Me.Character).CFrame = getRoot(tPlr.Character).CFrame * CFrame.Angles(0, math.rad(0), 0) * CFrame.new(0, 1.6, .5)
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
		minimumPlayers = Value
	end,
	Min = 1,
	Max = maximumPlayers,
	Def = 1
})

Title_3_Object_2 = Title_3.Slider({
	Text = "Max Players",
	Callback = function(Value)
		maximumPlayers = Value
	end,
	Min = 1,
	Max = maximumPlayers,
	Def = maximumPlayers
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
			Me:Kick("\nRejoining...")
			wait()
			TeleportService:Teleport(game.PlaceId, Me)
		else
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Me)
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
		iyflyspeed = Value
		vehicleflyspeed = Value
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
		QEfly = Value
	end,
	Enabled = QEfly
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
		local plr = Value
		local tPlr = Players:FindFirstChild(string.sub(plr, 1, string.find(plr, " ") - 1))
		if tPlr then
			if headSit then
				headSit:Disconnect()
			end
			
			Me.Character:FindFirstChildOfClass('Humanoid').Sit = true
			
			headSit = RunService.Heartbeat:Connect(function()
				if tPlr.Character ~= nil and getRoot(tPlr.Character) and getRoot(Me.Character) and Me.Character:FindFirstChildOfClass('Humanoid').Sit == true then
					getRoot(Me.Character).CFrame = getRoot(tPlr.Character).CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 1.25, 1)
				else
					headSit:Disconnect()
				end
			end)
		end
	end,
	Options = temp_List
})

--// Lighting \\--

Title_5_Object_1 = Title_5.Button({
	Text = "Fullbright",
	Callback = function(Value)
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
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
		Lighting.Ambient = origsettings.abt
		Lighting.OutdoorAmbient = origsettings.oabt
		Lighting.Brightness = origsettings.brt
		Lighting.ClockTime = origsettings.time
		Lighting.FogEnd = origsettings.fe
		Lighting.FogStart = origsettings.fs
		Lighting.GlobalShadows = origsettings.gs
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
				Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			end

			brightLoop = RunService.RenderStepped:Connect(brightFunc)
		elseif not Value and brightLoop then
			brightLoop:Disconnect()
		end
	end,
	Enabled = false
})

--// ESP \\--

Title_1_Object_1 = Title_6.Toggle({
	Text = "ESP",
	Callback = function(Value)
		ESPenabled = Value
		
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= Me then
				ESP(v)
			end
		end
	end,
	Enabled = false
})

Title_1_Object_2 = Title_6.Toggle({
	Text = "Tracers",
	Callback = function(Value)
		Tracers_Visible = Value
	end,
	Enabled = false
})

Title_1_Object_3 = Title_6.Toggle({
	Text = "Hide Team",
	Callback = function(Value)
		Hide_Team = Value
		
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= Me then
				ESP(v)
			end
		end
	end,
	Enabled = false
})

--// Player List Update \\--

function GetList()
	local plr_List = getPlayers()
	Title_2_Object_4:SetOptions(plr_List)
	Title_2_Object_6:SetOptions(plr_List)
	Title_2_Object_7:SetOptions(plr_List)
	Title_4_Object_6:SetOptions(plr_List)
	Title_4_Object_7:SetOptions(plr_List)
end

function onDied()
	task.spawn(function()
		if pcall(function() Me.Character:FindFirstChildOfClass('Humanoid') end) and Me.Character:FindFirstChildOfClass('Humanoid') then
			Me.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(Me.Character) then
					lastDeath = getRoot(Me.Character).CFrame
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

Players.PlayerAdded:Connect(function(plr)
	GetList()
	activateTracers(plr)
	
	if ESPenabled then
		repeat wait() until plr.Character and getRoot(plr.Character)
		if Hide_Team and plr.TeamColor ~= Me.TeamColor then
			ESP(plr)
		elseif not Hide_Team then
			ESP(plr)
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	GetList()
	
	if ESPenabled then
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
	end
	
	if viewing ~= nil and plr == viewing then
		workspace.CurrentCamera.CameraSubject = Me.Character
		viewing = nil
		
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
	end
end)

GetList()

--// Left Control/Shift Click Teleport \\--

mouse.Button1Down:Connect(function()
	if Held_Button and getgenv().settings.click_Tele then
		local root = Me.Character.HumanoidRootPart
		local pos = mouse.Hit.Position + Vector3.new(0, 2.5, 0)
		local offset = pos-root.Position
		GetUp()
		root.CFrame = root.CFrame + offset
	end
end)

UIS.InputBegan:Connect(function(key, gp)
	if key.KeyCode == Enum.KeyCode.LeftControl or key.KeyCode == Enum.KeyCode.LeftShift then
		Held_Button = true
	end
end)

UIS.InputEnded:Connect(function(key, gp)
	if key.KeyCode == Enum.KeyCode.LeftControl or key.KeyCode == Enum.KeyCode.LeftShift then
		Held_Button = false
	end
end)

settingsLock = false

--// Respawn \\--

Me.CharacterAdded:Connect(function(char)
	NOFLY()
	repeat wait() until getRoot(char)
	onDied()
end)

onDied()

--// Tracers Start \\--
for _, v in pairs(Players:GetPlayers()) do
	activateTracers(v)
end
