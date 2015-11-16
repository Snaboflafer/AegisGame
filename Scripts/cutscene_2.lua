
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
			"Great work Taylor. Our airstrikes destroyed what was left of the weapons lab. " ..
			"Every assault we make on the capital is thwarted. The Empire's moon based defense " ..
			"system is too strong. We need you to destroy it. " ..
			"Unfortunately, Aegis is incapable of space flight. You'll have to fight your " ..
			"way into the Empire's launch facility and commandeer a shuttle. " ..
			"Be careful you're entering enemy controlled territory.")
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