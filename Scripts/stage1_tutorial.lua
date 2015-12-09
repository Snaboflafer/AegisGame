--Warn the layer if their shields are broken

if stage == 1 then
	GameState.advanceTriggerDistance = false
	local keyAttack
	local keyJump
	if Input.useGamepad then
		keyAttack = string.upper(Input.map_gamepad[Input.PRIMARY])
		keyJump = string.upper(Input.map_gamepad[Input.SECONDARY])
	else
		keyAttack = string.upper(Input.map_keyboard[Input.PRIMARY])
		keyJump = string.upper(Input.map_keyboard[Input.SECONDARY])
		if keyAttack == " " then
			keyAttack = "SPACE"
		end
		if keyJump == " " then
			keyJump = "SPACE"
		end
	end
	GameState.messageBox:show("Make sure you figure out how to pilot that thing before you advance! " ..
						"The Aegis mech can jump by pressing '" .. keyJump .. "' and your weapons are " ..
						"activated by holding '" .. keyAttack .. "'.", "> Commander", true)
	
	stage = stage + 1
elseif stage == 2 then
	if not GameState.messageBox.alive then
		timer = 0
		stage = stage + 1
	end
elseif stage == 3 then
	if timer >= 3 then
		if Input.useGamepad then
			GameState.messageBox:show("You can aim your weapons up or down using the DPad. Test that they're " ..
				"calibrated by firing at the drones up ahead.", "> Commander", true)
		else
			GameState.messageBox:show("You can aim your weapons using '" .. string.upper(Input.map_keyboard[Input.UP]) ..
				"' or '" .. string.upper(Input.map_keyboard[Input.DOWN]) .. "'. Test that they're " ..
				"calibrated by firing at the drones up ahead.", "> Commander", true)
		end
		stage = stage + 1
	end
elseif stage == 4 then
	if not GameState.messageBox.alive then
		GameState:spawnEnemyGroup(3, 1)
		stage = stage + 1
	end
elseif stage == 5 then
	if GameState:isWaveClear() then
		GameState.messageBox:show("Good work with those. Be careful, the main enemy force is " ..
						"ahead. If you feel you're in danger or need additional mobility, press '" ..
						string.upper(Input:getBoundControl(Input.TERTIARY)) ..
						"' to transform your Aegis unit into flight mode.", ">Commander", true)
		stage = stage + 1
	end
elseif stage == 6 then
	if not GameState.messageBox.alive then
		GameState.advanceTriggerDistance = true
		stage = -1
	end
end


return stage