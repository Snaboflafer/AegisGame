--- GameLoad screen state.
GameLoadState = {
	
}
GameLoadState.__index = GameLoadState
setmetatable(GameLoadState, State)

function GameLoadState:load()
	State.load(self)

	local currentLevel = General:getCurrentLevel()
	print(currentLevel)
	local cutScene
	if currentLevel == 1 then
		cutScene = Sprite:new(0, 0, "images/scene_1.png")
	else
		cutScene = Sprite:new(0, 0, "images/scene_2.png")
	end
	cutScene.scrollFactorX = 0
	cutScene.scrollFactorY = 0

	GameLoadState:add(cutScene)
end

function GameLoadState:start()
	State.start(self)
end
function GameLoadState:stop()
	State.stop(self)
end


function GameLoadState:keypressed(key)
	General:setState(GameState)
end

