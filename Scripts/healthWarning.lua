--Warn the player when they reach critical health

local player = GameState.player
if player.health <= 1 then
	if player.activeMode == "mech" then
		GameState.messageBox:show("Careful! The Aegis can't take much more! Switch to flight mode to recharge your shields!", "> Commander", true)
	else
		if player.shield > 1 then
			GameState.messageBox:show("Careful! The Aegis can't take much more! You should switch to mech mode and use your shield!", "> Commander", true)
		else
			GameState.messageBox:show("Careful! The Aegis can't take much more! Avoid being hit until your shields have recharged!", "> Commander", true)
		end
	end
	stage = -1
end

return stage