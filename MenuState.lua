--- Menu screen state.
MenuState = {name = "[MENU STATE]", time = 0}
setmetatable(MenuState, State)

function MenuState:load()
        self.font = love.graphics.newFont("fonts/Square.ttf", 64)
        self.width = self.font:getWidth(self.name)
        self.height = self.font:getHeight(self.name)
        self.song = love.audio.newSource("sounds/runawayHorses.mp3")
        self.song:setLooping(true)
end
function MenuState:update(dt)
        self.time = self.time + dt
end
function MenuState:draw()
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
function MenuState:keyreleased(key)
        if key == "escape" then
                love.event.quit()
        end
        switchTo(GameState)
end
function MenuState:start()
        self.time = 0
        self.song:play()
end
function MenuState:stop()
        self.song:stop()
end
