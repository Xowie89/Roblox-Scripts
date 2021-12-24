local Me = game.Players.LocalPlayer
local Tycoon = nil
local Auto_Collect = false
local Auto_Buy = false
local Auto_Destroy = false
local Auto_Gather = false
local Auto_Manual = false

for _, v in pairs(workspace.Tycoons:GetChildren()) do
	if v.Environment.SpawnLocation.TeamColor == Me.TeamColor then
		Tycoon = v
	end
end

local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local MainGui = Material.Load({
	Title = "Made By: Guybrush Threepwood#8178",
	Style = 1,
	SizeX = 250,
	SizeY = 300,
	Theme = "Dark"
})

local Title_1 = MainGui.New({
	Title = "Main"
})

local Title_1_Object_1 = Title_1.Toggle({
	Text = "Auto Collect",
	Callback = function(Value)
		Auto_Collect = Value
	end,
	Enabled = true
})

local Title_1_Object_2 = Title_1.Toggle({
	Text = "Auto Buy",
	Callback = function(Value)
		Auto_Buy = Value
	end,
	Enabled = true
})

local Title_1_Object_3 = Title_1.Toggle({
	Text = "Gather Presents",
	Callback = function(Value)
		Auto_Gather = Value
	end,
	Enabled = true
})

local Title_1_Object_4 = Title_1.Toggle({
	Text = "Auto Manual Dropper",
	Callback = function(Value)
		Auto_Manual = Value
	end,
	Enabled = true
})

local Title_1_Object_5 = Title_1.Toggle({
	Text = "Destroy Annoyances",
	Callback = function(Value)
		Auto_Destroy = Value
	end,
	Enabled = true
})

wait(1)

--// Configurations
config = {
    func = {
        collect_cash = function()
			pcall(function()
				local touch_part = Tycoon.Environment.CashZone.CashArea.CashCollector
				game:GetService("ReplicatedStorage").RemoteFunctions.CollectCurrency:InvokeServer("Cash", touch_part)
			end)
        end,
		buy_all = function()
            for _, v in pairs(Tycoon.BuyButtons:GetChildren()) do
                pcall(function()
					game:GetService("ReplicatedStorage").RemoteFunctions.BuyButton:InvokeServer(v.name)
                end)
            end
        end,
		manual_drop = function()
			pcall(function()
				local Dropper = Tycoon.Purchases:FindFirstChild("ManualDropper_0")
				if Dropper then
					local Prompt = Dropper.ManualDropper:FindFirstChild("InteractionPrompt")
					if Prompt then
						fireproximityprompt(Prompt, 1)
					end
				end
			end)
		end,
		remove_annoyances = function()
			pcall(function()
				for _, v in pairs(Tycoon.BuyButtons:GetChildren()) do
					if v.Color == Color3.new(1,1,0) then
						v:Destroy()
					end
				end
				
				local Gay1 = Tycoon.Environment:FindFirstChild("CashPrompts")
				if Gay1 then
					Gay1:Destroy()
				end
				
				local Gay2 = Tycoon.Environment:FindFirstChild("PremiumTools")
				if Gay2 then
					Gay2:Destroy()
				end
				
				local Gay3 = Me.PlayerGui.GameGui.Screen:FindFirstChild("Top")
				if Gay3 then
					Gay3:Destroy()
				end
				
				local Gay4 = Me.PlayerGui.GameGui.Screen.Middle:FindFirstChild("Cash")
				if Gay4 then
					Gay4:Destroy()
				end
				
				local Gay5 = game:GetService("Lighting"):FindFirstChild("UIBlur")
				if Gay5 then
					Gay5:Destroy()
				end
				
				local F1 = Tycoon.Purchases:FindFirstChild("Floor_1")
				if F1 then
					local Gay6 = F1:FindFirstChild("Cash")
					if Gay6 then
						Gay6:Destroy()
					end
				end
				
				local F2 = Tycoon.Purchases:FindFirstChild("Floor_2")
				if F2 then
					local Gay7 = F2:FindFirstChild("Cash")
					if Gay7 then
						Gay7:Destroy()
					end
				end
				
				local F3 = Tycoon.Purchases:FindFirstChild("RooftopFloor_0")
				if F3 then
					local Gay8 = F3:FindFirstChild("Cash")
					if Gay8 then
						Gay8:Destroy()
					end
				end
				
				for _, v in pairs(Tycoon.Effects:GetChildren()) do
					if string.match(v.Name, "Robux") then
						v:Destroy()
					end
				end
			end)
		end,
		gather_presents = function()
			pcall(function()
				for _,v in pairs(workspace.Loots:GetChildren()) do
					wait(.1)
					v.Detector.CFrame = Me.Character.HumanoidRootPart.CFrame
				end
			end)
		end,
    }
}

--// Run
spawn(function()
	while true do
		wait(1)
		if Auto_Collect then
			config.func.collect_cash()
		end
	end
end)

spawn(function()
	while true do
		wait(1)
		if Auto_Gather then
			config.func.gather_presents()
		end
	end
end)

spawn(function()
	while true do
		wait(1)
		if Auto_Buy then
			config.func.buy_all()
		end
	end
end)

spawn(function()
	while true do
		wait(1)
		if Auto_Destroy then
			config.func.remove_annoyances()
		end
	end
end)

spawn(function()
	while true do
		wait()
		if Auto_Manual then
			config.func.manual_drop()
		end
	end
end)
