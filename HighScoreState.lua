--- HighScoreState screen state.
HighScoreState = {name = "High Scores", players="Steven Austin 5000\nDavid Kimberk 4545\nEddie Snowden 3000\n", time = 0}
setmetatable(HighScoreState, State)

function HighScoreState:load()
        self.font = love.graphics.newFont("fonts/Square.ttf", 64)
        self.subFont = love.graphics.newFont("fonts/Square.ttf", 20)
        self.width = self.font:getWidth(self.name)
        self.height = self.font:getHeight(self.name)
        self.subWidth = self.font:getWidth(self.players)
        self.subHeight = self.font:getHeight(self.players)
        self.song = love.audio.newSource("sounds/runawayHorses.mp3")
        self.song:setLooping(true)
end
function HighScoreState:update(dt)
        self.time = self.time + dt
end
function HighScoreState:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print(
		self.name,
		center(General.screenW, self.width),
		center(General.screenH*.6, self.height)
	)
	love.graphics.setFont(self.subFont)
	love.graphics.print(
		self.players,
		center(General.screenW * 1.5, self.subWidth),
		center(General.screenH, self.subHeight))
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
