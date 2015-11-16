
--[[ Custom action (script demo)
	Displays letterbox bars
]]

local player = GameState.player
if stage == 1 then
	player.enableControls = false
	GameState.camera:letterbox(true)
	if player.activeMode == "ship" then
		GameState:togglePlayerMode(true)
	end
	--Clear timer, and advance stage
	timer = 0
	stage = stage + 1
elseif stage == 2 then
	if timer > .5 then
		GameState.messageBox:show(
			"Well done stealing the Aegis prototype. This is how we'll win the war. " ..
			"Our satellites are showing heavy enemy resistance blocking your escape. " ..
			"Imperial forces want their weapon back. " .. 
			"Let's not give it to them. " ..
			"(WASD to move, space to shoot) ")
		stage = stage + 1
	end
elseif stage == 3 then
	if not GameState.messageBox.visible then
		player.enableControls = true
		GameState.camera:letterbox(false)
		GameState.advanceTriggerDistance = true
	end
end

return stage