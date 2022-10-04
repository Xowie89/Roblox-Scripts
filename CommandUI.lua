--[[
Height 0%
Width 0%
Head 100%
Proportions 100%
Body Type 0%
]]

repeat
	wait()
until game:IsLoaded()

local Players = game:GetService('Players')
local TeleportService = game:GetService('TeleportService')
local httpservice = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local UIS = game:GetService('UserInputService')

local sethidden = sethiddenproperty or set_hidden_property or set_hidden_prop
local gethidden = gethiddenproperty or get_hidden_property or get_hidden_prop
local setsimulation = setsimulationradius or set_simulation_radius
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local Me = Players.LocalPlayer
local mouse = Me:GetMouse()

local Noclipping = nil
local swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
local viewing = nil

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

--// Shrink \\--

local shrink = function()
	wait(3)
	local suc, err = pcall(function()
		local Hum = Me.Character:FindFirstChild("Humanoid")
		if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
		
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
end

--// Server Hop \\--

local function ServerHop()
	local foundserver = false
	local searched = false
	local maximum = Players.MaxPlayers - 1
	local minimum = math.ceil(Players.MaxPlayers ^ 0.9)
	local pid = game.PlaceId --PlaceId
	local Servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"))
	Me:Kick("\nDo not leave.\nSearching for a server with a max of "..maximum.." players and a min of "..minimum.." players.")
	
	repeat
		if searched then
			if not Servers.nextPageCursor then
				warn("All servers searched")
			end
			Servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100&cursor="..Servers.nextPageCursor))
		end
		
		for i,v in pairs(Servers.data) do
			if v.playing <= maximum and v.playing >= minimum then
				foundserver = true
				TeleportService:TeleportToPlaceInstance(pid, v.id)
			end
		end
		
		searched = true
		wait(1)
	until foundserver == true
end

--// Teleporter \\--

local loop_Tele = false
local target = false

function Tele(plr)
	repeat
		local tPlr = Players:FindFirstChild(string.sub(plr, 1, string.find(plr, " ") - 1))
		if tPlr then
			local myChar = Me.Character
			local tChar = tPlr.Character
			if myChar and tChar then
				local myRoot = myChar:FindFirstChild("HumanoidRootPart")
				local tRoot = tChar:FindFirstChild("HumanoidRootPart")
				if myRoot and tRoot then
					myRoot.CFrame = tRoot.CFrame
				end
			end
		end
		wait()
	until not loop_Tele or target ~= plr or not plr or not tPlr or not target
end

function getPlayers()
	local Plrs = {}
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= Me then
			table.insert(Plrs, v.Name.." - "..v.DisplayName)
		end
	end
	return Plrs
end

--// Fly \\--

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1

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
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
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
	if Me.Character:FindFirstChildOfClass('Humanoid') then
		Me.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

--// Functions \\--

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function onDied()
	task.spawn(function()
		if pcall(function() Me.Character:FindFirstChildOfClass('Humanoid') end) and Me.Character:FindFirstChildOfClass('Humanoid') then
			Me.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				--Add Stuff later
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

local refreshCmd = false

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
	Title = "Fly"
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
				Text = "Makes your character lay down. (Use twice)"
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

--// Teleport \\--

Title_2_Object_1 = Title_2.Toggle({
	Text = "Click Teleport (Hold Left Contol/Shift)",
	Callback = function(Value)
		getgenv().settings.click_Tele = Value
		saveSettings()
	end,
	Enabled = getgenv().settings.click_Tele
})

Title_2_Object_2 = Title_2.Toggle({
	Text = "Loop Tele",
	Callback = function(Value)
		loop_Tele = Value
		if Value then
			Tele(target)
		end
	end,
	Enabled = false
})

Title_2_Object_3 = Title_2.Dropdown({
	Text = "Teleport To",
	Callback = function(Value)
		target = Value
		Tele(Value)
	end,
	Options = getPlayers()
})

Title_2_Object_4 = Title_2.Button({
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
})


Title_2_Object_5 = Title_2.Dropdown({
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
	Options = getPlayers()
})

--// Server \\--

Title_3_Object_1 = Title_3.Button({
	Text = "Server Hop",
	Callback = function(Value)
		ServerHop()
	end,
})

Title_3_Object_2 = Title_3.Button({
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
})

--// Fly \\--

Title_4_Object_1 = Title_4.Slider({
	Text = "Fly Speed",
	Callback = function(Value)
		iyflyspeed = Value
		vehicleflyspeed = Value
	end,
	Min = 1,
	Max = 5,
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

--// Teleport Player List Update \\--

function onPlayerAdded(plr)
	Title_2_Object_3:SetOptions(getPlayers())
	Title_2_Object_5:SetOptions(getPlayers())
end

Players.PlayerRemoving:Connect(function(plr)
	Title_2_Object_3:SetOptions(getPlayers())
	Title_2_Object_5:SetOptions(getPlayers())
	
	if viewing ~= nil and player == viewing then
		workspace.CurrentCamera.CameraSubject = Me.Character
		viewing = nil
		
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
	end
end)

Players.PlayerAdded:Connect(onPlayerAdded)

for _,v in pairs(getPlayers()) do
	onPlayerAdded(v)
end

--// Left Control/Shift Click Teleport \\--

local Held_Button = false

mouse.Button1Down:Connect(function()
	if Held_Button and getgenv().settings.click_Tele then
		local root = Me.Character.HumanoidRootPart
		local pos = mouse.Hit.Position+Vector3.new(0, 2.5, 0)
		local offset = pos-root.Position
		root.CFrame = root.CFrame+offset
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