--Warn the layer if their shields are broken

local player = GameState.player
if player.shield <= 0 and player.activeMode == "mech" then
	GameState.messageBox:show("Your shields have been depleted! Switch to flight mode with 'LSHIFT' so they can recharge!", "> Commander", true)
	stage = -1
end

return stage