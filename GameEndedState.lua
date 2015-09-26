GameEndedState = {
	title = "GAME OVER"
}
setmetatable(GameEndedState, State)
GameEndedState.__index = GameEndedState

function GameEndedState:load()
end

function GameEndedState:update()
	State:update()
    if State.time > 5 then
		General:setState(HighScoreState)
    end
end

function GameEndedState:draw()
	love.graphics.setFont(General.headerFont)
	love.graphics.print(
		self.title,
		Utility:mid(General.headerFont:getWidth(self.title), General.screenW),
		Utility:mid(General.headerFont:getHeight(self.title), General.screenH*.6)
	)
end
function GameEndedState:keyreleased(key)
    General:setState(HighScoreState)
end
function GameEndedState:start()
	State.time = 0
end
function GameEndedState:stop()
end

