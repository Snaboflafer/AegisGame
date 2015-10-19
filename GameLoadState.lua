--- GameLoad screen state.
GameLoadState = {
	
}
GameLoadState.__index = GameLoadState
setmetatable(GameLoadState, State)

function GameLoadState:load()
	State.load(self)
	local cutScence = Sprite:new(0, 0, "images/scene_1.png")
	GameLoadState:add(cutScence)
	
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

