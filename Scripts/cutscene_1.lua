
if stage == 1 then
	
	GameState.player:jump()
	timer = 0
	stage = 2
elseif stage == 2 then
	if timer > .3 then
		timer = 0
		stage = 3
	end
elseif stage == 3 then
	GameState.player:jetOn()
	if timer > 1 then
		GameState.player:jetOff()
		stage = 4
	end
elseif stage == 4 then
	GameState.explosion:play(GameState.player.x, GameState.player.y)
	GameState.player:attackStart()
	stage = -1
end

return stage