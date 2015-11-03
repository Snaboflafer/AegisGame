--[[ Custom action (script demo)
	Makes the player jump, hover, and shoot. With EXPLOSIONS.
]]

local player = GameState.player
if player.activeMode ~= "mech" then
	stage = 1
	return
end
if stage == 1 then
	--Disable player controls first
	player.enableControls = false
	--Make player jump, and do an EXPLOSION
	player:jump()
	GameState.explosion:play(player.x, player.y)
	--Clear timer, and advance stage
	timer = 0
	stage = 2
elseif stage == 2 then
	--Try to turn on mech jets
	if not player:jetOn() then
		timer = 0
	end
	--Show the message box.
	GameState.messageBox.visible = true
	--Advance timer, until 2 seconds has passed
	if timer > 2 then
		player:jetOff()
		stage = 3
	end
elseif stage == 3 then
	--Another EXPLOSION, and make player attack
	GameState.explosion:play(player.x, player.y)
	player:attackStart()
	--Mark stage with finished flag, and re-enable controls
	stage = -1
	GameState.messageBox.visible = false
	player.enableControls = true
end

return stage