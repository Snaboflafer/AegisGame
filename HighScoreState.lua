--- HighScoreState screen state.
HighScoreState = {
	name = "High Scores",
	players = "Steven Austin 5000\nDavid Kimberk 4545\nEddie Snowden 3000\n",
	time = 0}
setmetatable(HighScoreState, State)

function HighScoreState:load()
	self.font = love.graphics.newFont("fonts/Square.ttf", 64)
	self.subFont = love.graphics.newFont("fonts/04b09.ttf", 20)
	self.width = self.font:getWidth(self.name)
	self.height = self.font:getHeight(self.name)
	self.subWidth = self.font:getWidth(self.players)
	self.subHeight = self.font:getHeight(self.players)
end

function HighScoreState:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print(
		self.name,
		Utility:mid(self.width, General.screenW),
		Utility:mid(self.height, General.screenH*.6)
	)
	love.graphics.setFont(self.subFont)
	love.graphics.print(
		self.players,
		Utility:mid(self.subWidth, General.screenW * 1.5),
		Utility:mid(self.subHeight, General.screenH)
	)
end

function HighScoreState:keyreleased(key)
	if key == "escape" then
		General:setState(MenuState)
	end
end

function HighScoreState:start()
end
function HighScoreState:stop()
end
