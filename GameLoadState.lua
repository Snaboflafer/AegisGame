--- GameLoad screen state.
GameLoadState = {
	
}
GameLoadState.__index = GameLoadState
setmetatable(GameLoadState, State)

function GameLoadState:load()
	State.load(self)

	local currentLevel = General:getCurrentLevel()
	print(currentLevel)
	if currentLevel == 1 then
		cutScene = Sprite:new(0, 0, "images/scene_1.png")
	else
		cutScene = Sprite:new(0, 0, "images/scene_2.png")
	end

	GameLoadState:add(cutScene)
	
	self.skipPrompt = Group:new()
end

function GameLoadState:start()
	State.start(self)
end
function GameLoadState:stop()
	State.stop(self)
end

function GameLoadState:update()
	State.update(self)
end

function GameLoadState:draw()
	State.draw(self)
end

function GameLoadState:keypressed(key)
	General:setState(GameState)
end

