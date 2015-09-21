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
	time = 0
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
		love.graphics.print(
			self.options[k],
			Utility:mid(0, General.screenW * .5),
			Utility:mid(0, General.screenH * .75) + self.subFont:getHeight("")*k
		)
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
	end
end

function MenuState:start()
	self.time = 0
	self.song:play()
end

function MenuState:stop()
	self.song:stop()
end
