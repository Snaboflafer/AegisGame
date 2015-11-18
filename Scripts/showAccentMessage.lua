--Displays an autoadvancing message, with letterbox

local player = GameState.player
if stage == 1 then
	GameState.camera:letterbox(true)

	--Clear timer, and advance stage
	timer = 0
	stage = stage + 1
elseif stage == 2 then
	if timer > .5 then
		GameState.messageBox:show(value, "> Commander", true)
		stage = stage + 1
	end
elseif stage == 3 then
	if not GameState.messageBox.visible then
		GameState.camera:letterbox(false)
		stage = -1
	end
end

return stage