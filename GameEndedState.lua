GameEndedState = {
	title = "GAME OVER"
}
setmetatable(GameEndedState, State)
GameEndedState.__index = GameEndedState

function GameEndedState:load()
	State.load(self)
	self.loaded = true
end

function GameEndedState:start()
	State.start(self)
end

function GameEndedState:stop()
	State.stop(self)
end

function GameEndedState:update()
	State.update(self)
    if State.time > 5 then
    	--patchwork fix for GameState improper closing bug
    	love.event.push('quit')
		--General:setState(HighScoreState)
    end
end

function GameEndedState:draw()
	State.draw(self)
	love.graphics.setFont(General.headerFont)
	love.graphics.print(
		self.title,
		Utility:mid(General.headerFont:getWidth(self.title), General.screenW),
		Utility:mid(General.headerFont:getHeight(self.title), General.screenH)
	)
end
function GameEndedState:keypressed(key)
	--patchwork fix for GameState improper closing bug
	love.event.push('quit')
    --General:setState(HighScoreState)
end



