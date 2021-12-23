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
        fb1 = function(button)
            for i, signal in next, getconnections(button.MouseButton1Click) do
                signal:Fire()
            end
            for i, signal in next, getconnections(button.MouseButton1Down) do
                signal:Fire()
            end
            for i, signal in next, getconnections(button.Activated) do
                signal:Fire()
            end
        end,
        collect_cash = function()
			local touch_part = Tycoon.Environment.CashZone.CashArea.CashCollector
			firetouchinterest(Me.Character.RightFoot, touch_part, getgenv().num)
        end,
		buy_all = function()
            for _, v in pairs(Tycoon.BuyButtons:GetChildren()) do
                pcall(function()
					local touch_part = v
					firetouchinterest(Me.Character.LeftFoot, touch_part, 0)
                end)
            end
        end,
    }
}

--// Collect Cash
spawn(function()
    while true do
        wait(1)
        if getgenv().num == 1 then
            wait(1)
            getgenv().num = 0
        else
            wait(1)
            getgenv().num = 1
        end
        config.func.collect_cash()
    end
end)

 --// Auto Buy
spawn(function()
	while true do
		RemoveAnnoyances()
		wait(1)
        config.func.buy_all()
    end
end)
