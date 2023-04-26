local StarterGui = game:GetService("StarterGui")

-- Anime Training Simulator
if game.PlaceId == 7114796110 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Anime%20Training%20Simulator.lua"))()
-- Hospital Tycoon
elseif game.PlaceId == 7050008107 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Hospital%20Tycoon.lua"))()
-- Factory Simulator
elseif game.PlaceId == 6769764667 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Factory%20Simulator%20%5BOVERHAUL%5D.lua"))()
-- Mall Tycoon
elseif game.PlaceId == 5736409216 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Mall%20Tycoon.lua"))()
-- Item Factory
elseif game.PlaceId == 7280506312 or game.PlaceId == 8384895168 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Item%20Factory.lua"))()
else
	StarterGui:SetCore("SendNotification", {
		Title = "ERROR",
		Text = "This game is not supported!",
		Duration = 30
	})
end
