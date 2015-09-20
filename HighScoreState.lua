--- HighScoreState screen state.
HighScoreState = {name = "High Scores", time = 0}
setmetatable(HighScoreState, State)

function HighScoreState:load()
        self.font = love.graphics.newFont("fonts/Square.ttf", 64)
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
       
end

function HighScoreState:keyreleased(key)
        if key == "escape" then
                switchTo(MenuState)
        end
end

function HighScoreState:start()

end
function HighScoreState:stop()
end
