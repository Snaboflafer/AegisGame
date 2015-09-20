TitleState = {name = "Mishima", 
	team = "by SOL Game", 
	authors = {"Steven Austin", "Nathaniel Rhodes", "Andrew Shiau", "Jung Yang"}
}
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
    self.sound = love.audio.newSource("sounds/mission_ui.mp3")
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
                center(General.screenW, self.width), center(General.screenH*.6, self.height)
        )
	love.graphics.print(
                self.team,
                center(General.screenW, self.font:getWidth(self.team)*.5), 
		center(General.screenH*.8, self.font:getHeight(self.team)*.5),
		0,
		.5,
		.5
        )
	for k,author in pairs(self.authors) do
		love.graphics.print(
                	author,
                	center(General.screenW,self.font:getWidth(author)*(.3)), 
                	center(General.screenH + General.screenH*(k*.1), self.font:getHeight(author)*.3),
                	0,
                	.3,
                	.3
        	)
	end
end
function TitleState:keyreleased(key)
    General:setState(MenuState)
end
function TitleState:start()
    self.time = 0
    self.sound:play()
end
function TitleState:stop()
    self.sound:stop()
end

