local Me = game.Players.LocalPlayer
local Tycoon = nil

for _, v in pairs(workspace.Tycoons:GetChildren()) do
	if v.Environment.SpawnLocation.TeamColor == Me.TeamColor then
		Tycoon = v
	end
end

function RemoveAnnoyances()
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
end

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
					local touch_part = v
					game:GetService("ReplicatedStorage").RemoteFunctions.BuyButton:InvokeServer(touch_part.name)
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
    }
}

--// Run
spawn(function()
    while true do
		RemoveAnnoyances()
        config.func.collect_cash()
		wait(1)
        config.func.buy_all()
    end
end)

--// Manual Dropper
spawn(function()
	while true do
		wait()
		config.func.manual_drop()
	end
end)