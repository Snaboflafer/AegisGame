--Display a cutscene. Locks stage advance and player movement.

local player = GameState.player
if stage == 1 then
	GameState.advanceTriggerDistance = false
	Player.enableControls = false
	GameState.camera:letterbox(true)

	--Clear timer, and advance stage
	timer = 0
	stage = stage + 1
elseif stage == 2 then
	if timer > .5 then
		GameState.messageBox:show(LevelManager:getScene(value)["text"])
		stage = stage + 1
	end
elseif stage == 3 then
	if not GameState.messageBox.visible then
		Player.enableControls = true
		GameState.camera:letterbox(false)
		GameState.advanceTriggerDistance = true
		stage = -1
	end
end

return stage