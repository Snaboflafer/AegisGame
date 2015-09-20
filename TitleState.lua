TitleState = {name = "Mishima"}
setmetatable(TitleState, State)

function TitleState:fadein()
        if self.time < 16 then
                local c = lerp(0, 255, self.time/16)
                return {c, c, c, 255}
        else
                return {255, 255, 255, 255}
        end
end
function TitleState:load()
        self.font = love.graphics.newFont("fonts/Square.ttf", 94)
        self.width = self.font:getWidth(self.name)
        self.height = self.font:getHeight(self.name)
        self.sound = love.audio.newSource("sounds/runawayHorses.mp3")
end

function TitleState:update(dt)
        self.time = self.time + dt
        if self.time > 28 then
                switchTo(MenuState)
        end
end
function TitleState:draw()
        love.graphics.setFont(self.font)
        love.graphics.setColor(self:fadein())
        love.graphics.print(
                self.name,
                center(General.screenW, self.width), center(General.screenH, self.height)
        )
end
function TitleState:keyreleased(key)
        switchTo(MenuState)
end
function TitleState:start()
        self.time = 0
        self.sound:play()
end
function TitleState:stop()
        self.sound:stop()
end

