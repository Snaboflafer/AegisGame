--- Menu screen state.
MenuState = {
	title = "MENU",
	options = {
		"[1]\tStart",
		"[2]\tHigh Scores",
		"[3]\tBrightness",
		"[4]\tVolume",
		"[5]\tQuit"
	},
	time = 0,
	highlight = 1
}
setmetatable(MenuState, State)

function MenuState:load()
	State.load(self)
	self.headerFont = love.graphics.newFont("fonts/Square.ttf", 96)
	self.subFont = love.graphics.newFont("fonts/04b09.ttf", 32)
	--self.width = self.font:getWidth(self.name)
	--self.height = self.font:getHeight(self.name)
	self.song = love.audio.newSource("sounds/blast_network.mp3")
	self.song:setLooping(true)
	self.keyPressSound = love.audio.newSource("sounds/laser.wav")
	
	--self.sprite1 = Sprite:new(128, 128,"images/button_256x64.png")
	--MenuState:add(sprite1)
end

function MenuState:draw()
	State:draw()
	
	love.graphics.setFont(self.headerFont)
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print(
		self.title,
		Utility:mid(self.headerFont:getWidth(self.title), General.screenW),
		Utility:mid(self.headerFont:getHeight(self.title), General.screenH*.3)
	)
	
	love.graphics.setFont(self.subFont)
	for k,v in pairs(self.options) do
		if k == self.highlight then
			love.graphics.setColor({255, 255, 0, 255})
			love.graphics.print(
				self.options[k],
				Utility:mid(0, General.screenW * .5),
				Utility:mid(0, General.screenH * .75) + self.subFont:getHeight("")*k
			)
			love.graphics.setColor({255, 255, 255, 255})
		else
			love.graphics.print(
				self.options[k],
				Utility:mid(0, General.screenW * .5),
				Utility:mid(0, General.screenH * .75) + self.subFont:getHeight("")*k
			)
		end
	end
end

function MenuState:keyreleased(key)
	self.keyPressSound:play()
	if key == "escape" or key == "5" then
		love.event.quit()
	elseif key == "1" then
		General:setState(GameState)
	elseif key == "2" then
		General:setState(HighScoreState, false)
	elseif key == "w" then 
                if (self.highlight > 1) then self.highlight = self.highlight - 1 end
    elseif key == "s" then
                if (self.highlight < 5) then self.highlight = self.highlight + 1 end
    elseif key == "return" then
            if self.highlight == 1 then General:setState(GameState)
            elseif self.highlight == 2 then General:setState(HighScoreState, false)
            elseif self.highlight == 5 then love.event.quit()
            end
    end
end

function MenuState:start()
	self.time = 0
	self.song:play()
end

function MenuState:stop()
	self.song:stop()
end
