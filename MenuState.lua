--- Menu screen state.
MenuState = {name = "MENU", time = 0}
setmetatable(MenuState, State)

function MenuState:load()
        self.font = love.graphics.newFont("fonts/Square.ttf", 40)
        self.width = self.font:getWidth(self.name)
        self.height = self.font:getHeight(self.name)
        self.song = love.audio.newSource("sounds/blast_network.mp3")
        self.song:setLooping(true)
	self.keyPressSound = love.audio.newSource("sounds/laser.wav")

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
                center(General.screenH*.3, self.height)
        )
        love.graphics.print(
                "1. Start",
                center(General.screenW, self.width),
                center(General.screenH*.5, self.height)
        )
        love.graphics.print(
                "2. High Scores",
                center(General.screenW, self.width),
                center(General.screenH*.7, self.height)
        )
        love.graphics.print(
                "3. Brightness",
                center(General.screenW, self.width),
                center(General.screenH*.9, self.height)
        )
        love.graphics.print(
                "4. Volume",
                center(General.screenW, self.width),
                center(General.screenH*1.1, self.height)
        )
        love.graphics.print(
                "5. Quit",
                center(General.screenW, self.width),
                center(General.screenH*1.3, self.height)
        )
end
function MenuState:keyreleased(key)
	self.keyPressSound:play()
	if key == "escape" or key == "5" then
		love.event.quit()
	elseif key == "1" then
		General:setState(GameState)
	elseif key == "2" then
		General:setState(HighScoreState)
	end
end
function MenuState:start()
        self.time = 0
        self.song:play()
end
function MenuState:stop()
        self.song:stop()
end
