--- Menu screen state.
MenuState = {
	title = "MENU",
	options = {
		"Start",
		"High Scores",
		"Brightness",
		"Volume",
		"Quit"
	},
	time = 0,
	highlight = 1
}
MenuState.__index = MenuState
setmetatable(MenuState, State)

function MenuState:load()
	State.load(self)
	--self.width = self.font:getWidth(self.name)
	--self.height = self.font:getHeight(self.name)
	self.song = love.audio.newSource("sounds/blast_network.mp3")
	self.song:setLooping(true)
	self.keyPressSound = love.audio.newSource("sounds/laser.wav")
	self.titleText = Text:new(General.screenW/2,General.screenH/2, "fonts/Square.ttf",96)
	self.titleText:setAlign(Text.CENTER)
	self.titleText:lockToScreen()
	MenuState:add(self.titleText)
	--self.sprite1 = Sprite:new(128, 128,"images/button_256x64.png")
	--MenuState:add(sprite1)
end

function MenuState:draw()
	State:draw()
	
	love.graphics.setFont(General.headerFont)
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print(
		self.title,
		Utility:mid(General.headerFont:getWidth(self.title), General.screenW),
		Utility:mid(General.headerFont:getHeight(self.title), General.screenH*.5)
	)
	
	love.graphics.setFont(General.subFont)
	for k,v in pairs(self.options) do
		if k == self.highlight then
			love.graphics.setColor({255, 255, 0, 255})
			love.graphics.print(
				self.options[k],
				Utility:mid(General.headerFont:getWidth(MenuState.title) + General.screenW/10, General.screenW),
				Utility:mid(0, General.screenH * .75) + General.subFont:getHeight("")*k
			)
			love.graphics.setColor({255, 255, 255, 255})
		else
			love.graphics.print(
				self.options[k],
				Utility:mid(General.headerFont:getWidth(MenuState.title), General.screenW),
				Utility:mid(0, General.screenH * .75) + General.subFont:getHeight("")*k
			)
		end
	end
end

function MenuState:keyreleased(key)
	self.keyPressSound:rewind() 
	self.keyPressSound:play()
	if key == "escape" then
		love.event.quit()
	elseif key == "w" or key == "up" or key == "a" or key == "left" then 
	        self.highlight = (self.highlight + table.getn(self.options) - 2) % table.getn(self.options) + 1
    elseif key == "s" or key == "down" or key == "d" or key == "right" then
            self.highlight = (self.highlight + table.getn(self.options)) % table.getn(self.options) + 1
    elseif key == "return" or key == " " then
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
