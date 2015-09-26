GameEndedState = {
	title = "GAME OVER"
}
setmetatable(GameEndedState, State)
GameEndedState.__index = GameEndedState

function GameEndedState:load()
    self.headerFont = love.graphics.newFont("fonts/Square.ttf", 96)
    self.song = love.audio.newSource("sounds/blast_network.mp3")
	self.song:setLooping(true)
end

function GameEndedState:update()
    if self.time > 5 then
		General:setState(HighScoreState)
    end
end

function GameEndedState:draw()
	love.graphics.setFont(self.headerFont)
	love.graphics.print(
		self.title,
		Utility:mid(self.headerFont:getWidth(self.title), General.screenW),
		Utility:mid(self.headerFont:getHeight(self.title), General.screenH*.6)
	)
end
function GameEndedState:keyreleased(key)
    General:setState(HighScoreState)
end
function GameEndedState:start()
    self.time = 0
    self.song:play()
end
function GameEndedState:stop()
end

