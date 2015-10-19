--- GameLoad screen state.
GameLoadState = {
	
}
GameLoadState.__index = GameLoadState
setmetatable(GameLoadState, State)

function GameLoadState:load()
	State.load(self)
	
	local txtTitle = "GameLoad"
	
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtTitle, "fonts/Commodore.ttf", 64)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 255)
	headerText:setShadow(0, 150, 150, 255)
	GameLoadState:add(headerText)
	
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

