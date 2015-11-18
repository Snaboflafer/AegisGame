--Show initial movement hint image

if not GameState.messageBox.visible then
	local inputHint = Sprite:new(150, 200)
	inputHint:loadSpriteSheet(LevelManager:getImage("inputHint"), 144, 96)
	inputHint:addAnimation("default", {1,2,1,3}, .4, true)
	inputHint:playAnimation("default")
	
	GameState:add(inputHint)
	
	Timer:new(4, inputHint, Sprite.hide)
	return -1
else
	return stage
end

