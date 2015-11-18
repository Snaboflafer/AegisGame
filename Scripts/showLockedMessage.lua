--Show a message box on the screen, and prevent stage triggers from advancing

if stage == 1 then
	GameState.advanceTriggerDistance = false
	GameState.messageBox:show(value, "> Commander", true)

	stage = stage + 1
elseif stage == 2 then
	if not GameState.messageBox.alive then
		GameState.advanceTriggerDistance = true
		stage = -1
	end
end

return stage