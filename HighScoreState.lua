--- HighScoreState screen state.
HighScoreState = {name = "High Score", time = 0}
setmetatable(HighScoreState, State)

function HighScoreState:load()
        self.font = love.graphics.newFont("fonts/CaesarDressing-Regular.ttf", 64)
        self.width = self.font:getWidth(self.name)
        self.height = self.font:getHeight(self.name)
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
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.setColor({255, 255, 255, 255})
        love.graphics.print(love.timer.getFPS(), 10, 10)
end

function HighScoreState:keyreleased(key)
        if key == "1" then
                switchTo(GameState)
        end
end

function HighScoreState:start()

end
function HighScoreState:stop()
end
