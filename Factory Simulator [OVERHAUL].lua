--// This script is mainly just for some quick cash at the start of each tier and to complete harvest quests. To make lots of money you need to set up your factory.

--// Don't edit anything below this point unless you know what you are doing \\--

--// Settings
local Running = false
local AutoPickup = true
local AutoSell = false
local AntiAFK = true
local AutoStore = false
local Target = "Tree" --// Type item you want to harvest here. Not necesary select item in the gui.

--// All possible items to harvest. \\--
--// Tier 0: Tree, Rock 
--// Tier 1: CopperOre, Sand
--// Tier 2: GoldOre, IronOre, HardwoodTree
--// Tier 3: SuperwoodTree, ResiniteOre, TitaniumOre, Diamond, UraniumOre
--// Tier 4: UltrawoodTree, IceCrystal, RedmetalOre, BluemetalOre, LavaCrystal, TungstenOre

--// Variables
local Container = false
local Sellzone = false
local SelectContainerToggle = false
local SelectSellzoneToggle = false
local LP = game.Players.LocalPlayer

--// Selection Boxes
local PM = LP:GetMouse()
local ContainerSelectionBox = Instance.new("SelectionBox")
ContainerSelectionBox.LineThickness = .25
ContainerSelectionBox.Color3 = Color3.new(1,0,0)
local SellzoneSelectionBox = ContainerSelectionBox:Clone()

--// Find our grid
local MyGrid
for _,Grids in pairs(workspace.Grids:GetDescendants()) do
	if Grids.Name == "Owner" and Grids.Value == LP then
		MyGrid = Grids.Parent
	end
end

--// Material Lua Gui Library // Made By: Twink Marie
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local X = Material.Load({
	Title = "Made By: Guybrush Threepwood#8178",
	Style = 1,
	SizeX = 300,
	SizeY = 500,
	Theme = "Dark"
})

local Y = X.New({
	Title = "Factory Simulator [OVERHAUL]"
})

local A = Y.Toggle({
	Text = "Enabled",
	Callback = function(Value)
		Running = Value
	end,
	Enabled = false
})

local B = Y.Toggle({
	Text = "Auto Pickup",
	Callback = function(Value)
		AutoPickup = Value
	end,
	Enabled = true
})

local C = Y.Toggle({
	Text = "Auto Sell (Requires Sellzone)",
	Callback = function(Value)
		AutoSell = Value
	end,
	Enabled = false
})

local D = Y.Button({
	Text = "Select Sellzone",
	Callback = function()
		SelectSellzoneToggle = true
	end,
	Menu = {
		Information = function(self)
			X.Banner({
				Text = "You must select a sellzone before you can use auto sell. Click the Select Sellzone button and click a sellzone to select it. Red outline = Selecting, Green outline = Selected. You can not use auto sell and auto store at the same time it will just auto sell."
			})
		end
	}
})

local E = Y.Toggle({
	Text = "Auto Store (Requires Container)",
	Callback = function(Value)
		AutoStore = Value
	end,
	Enabled = false
})

local F = Y.Button({
	Text = "Select Container",
	Callback = function()
		SelectContainerToggle = true
	end,
	Menu = {
		Information = function(self)
			X.Banner({
				Text = "You must select a container before you can use auto store. Click the Select Container button and click a container to select it. Red outline = Selecting, Green outline = Selected. You can not use auto sell and auto store at the same time it will just auto sell."
			})
		end
	}
})

local G = Y.Toggle({
	Text = "Anti AFK",
	Callback = function(Value)
		AntiAFK = Value
	end,
	Enabled = true
})

local H = Y.Dropdown({
	Text = "Resource:",
	Callback = function(Value)
		Target = Value
	end,
	
	Options = {"Tree", "Rock", "Sand", "CopperOre", "HardwoodTree", "GoldOre", "IronOre", "SuperwoodTree", "ResiniteOre", "TitaniumOre", "UraniumOre", "Diamond", "UltrawoodTree", "RedmetalOre", "BluemetalOre", "LavaCrystal", "IceCrystal", "TungstenOre"
	},
})

--// Container/Sellzone selection mouse functions
PM.Move:Connect(function()
	if SelectContainerToggle and PM.Target and PM.Target.Parent.Name == "BasicContainer" then
		ContainerSelectionBox.Color3 = Color3.new(1,0,0)
		ContainerSelectionBox.Adornee = PM.Target.Parent.Center
		ContainerSelectionBox.Parent = PM.Target.Parent
	elseif SelectContainerToggle then
		ContainerSelectionBox.Adornee = nil
		ContainerSelectionBox.Parent = nil
		ContainerSelectionBox.Color3 = Color3.new(1,0,0)
	end
	
	if SelectSellzoneToggle and PM.Target and PM.Target.Parent.Name == "SellZone" then
		SellzoneSelectionBox.Color3 = Color3.new(1,0,0)
		SellzoneSelectionBox.Adornee = PM.Target.Parent.Boundary
		SellzoneSelectionBox.Parent = PM.Target.Parent
	elseif SelectSellzoneToggle then
		SellzoneSelectionBox.Adornee = nil
		SellzoneSelectionBox.Parent = nil
		SellzoneSelectionBox.Color3 = Color3.new(1,0,0)
	end
end)

PM.Button1Down:Connect(function()
	if SelectContainerToggle and PM.Target and PM.Target.Parent.Name == "BasicContainer" then
		SelectContainerToggle = false
		ContainerSelectionBox.Color3 = Color3.new(0,1,0)
		ContainerSelectionBox.Adornee = PM.Target.Parent.Center
		ContainerSelectionBox.Parent = PM.Target.Parent
		Container = PM.Target.Parent
	end
	
	if SelectSellzoneToggle and PM.Target and PM.Target.Parent.Name == "SellZone" then
		SelectSellzoneToggle = false
		SellzoneSelectionBox.Color3 = Color3.new(0,1,0)
		SellzoneSelectionBox.Adornee = PM.Target.Parent.Boundary
		SellzoneSelectionBox.Parent = PM.Target.Parent
		Sellzone = PM.Target.Parent
	end
end)

--// Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
	if AntiAFK then
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end
end)

--// Main script
while true do
	wait()
	pcall(function()
		--// Auto harvest when near.
		for _,Cut in pairs(workspace.Harvestable:GetDescendants()) do
			if Running and Cut:IsA("Model") and Cut.Name == Target and Cut.Parent.Parent.Name == "Harvestable" then
				local CutPositon = Cut:FindFirstChildWhichIsA("BasePart").Position
				LP.Character:MoveTo(CutPosition)
				wait(.5)
				if LP:DistanceFromCharacter(Cut:FindFirstChildWhichIsA("BasePart").Position) <= 30 then
					game:GetService("ReplicatedStorage").Events.Harvest.Harvest:FireServer(Cut)
					wait(.5)
					--// Auto pickup when near. You can only carry one type of item and only 15 of that type. (Vehicles hold more but this is not currently set up to use them)
					if AutoPickup then
						for _,Pickitup in pairs(MyGrid.Entities:GetChildren()) do
							if Pickitup:IsA("BasePart") and LP:DistanceFromCharacter(Pickitup.Position) <= 30 then
								wait(.5)
								game:GetService("ReplicatedStorage").Events.Inventory.PickUp:FireServer(Pickitup)
								wait(.5)
								--// Auto sell harvested items when at capacity at selected Sellzone.
								if AutoSell and Sellzone then
									local Carried = LP.Character:FindFirstChild("CarriedItem")
									if Carried and tonumber(Carried.Handle.AmountGui.Amount.Text) >= 15 then
										LP.Character:MoveTo(Sellzone:FindFirstChildWhichIsA("BasePart").Position)
										wait(.5)
										game:GetService("ReplicatedStorage").Events.Inventory.PickUp:FireServer(Carried.Handle)
										wait(.5)
									end
								end
								--// Auto store harvested resource in selected container.
								if AutoStore and Container then
									local Carried = LP.Character:FindFirstChild("CarriedItem")
									if Carried and tonumber(Carried.Handle.AmountGui.Amount.Text) >= 15 then
										LP.Character:MoveTo(Container:FindFirstChildWhichIsA("BasePart").Position)
										wait(.5)
										game:GetService("ReplicatedStorage").Events.Inventory.ContainerInteraction:FireServer(Container)
										wait(.5)
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end
