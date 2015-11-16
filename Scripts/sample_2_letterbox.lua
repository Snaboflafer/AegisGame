
--[[ Custom action (script demo)
	Displays letterbox bars
]]

local player = GameState.player
if stage == 1 then
	Player.enableControls = false
	GameState.camera:letterbox(true)
	--Clear timer, and advance stage
	timer = 0
	stage = stage + 1
elseif stage == 2 then
	if timer > .5 then
		GameState.messageBox:show("Lorem ipsum dolor sit amet, consectetur adipiscing elit. " ..
			"Suspendisse cursus ante in aliquam aliquam. In tempor mi nec accumsan lobortis. " ..
			"Maecenas pulvinar, nunc id fringilla, urna enim semper odio, sed varius " ..
			"lorem massa eget ex.")
		stage = stage + 1
	end
elseif stage == 3 then
	if not GameState.messageBox.visible then
		Player.enableControls = true
		GameState.camera:letterbox(false)
		GameState.advanceTriggerDistance = true
	end
end

return stage