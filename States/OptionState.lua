-- Option State
OptionState = {
	loaded = false,
	selected = 1
}

OptionState.__index = OptionState
setmetatable(OptionState, State)

function OptionState:load()
	State.load(self)
	
	local txtTitle = "OPTIONS"
	local volume = "Volume " .. General:getVolume()
	local contrast = "Contrast"
	local typeFace = LevelManager:getFont()
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtTitle, typeFace, 64)

	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 255)
	headerText:setShadow(0, 150, 150, 255)
	OptionState:add(headerText)
	
	self.selected = 1

	self.options = Group:new()

	local volumeText = Text:new(General.screenW * .3, General.screenH * .5 + 48 * (1-1),
						volume, typeFace, 48)
	self.options:add(volumeText)

	local contrastText = Text:new(General.screenW * .3, General.screenH * .5 + 48 * (2-1),
						contrast, typeFace, 48)
	self.options:add(contrastText)

	OptionState:add(self.options)
	
	self.optionSound = love.audio.newSource("sounds/menu_sounds/cw_sound27.wav")
	self.selectSound = love.audio.newSource("sounds/menu_sounds/cw_sound44.wav")
	self.failSound = love.audio.newSource("sounds/menu_sounds/cw_sound39.wav")
	self.exitSound = love.audio.newSource("sounds/menu_sounds/cw_sound34.wav")
end

function OptionState:start()
	State.start(self)
	SoundManager:playBgm("sounds/blast_network.mp3")
end
function OptionState:stop()
	State.stop(self)
	SoundManager:stopBgm()
end

function OptionState:update()	
	for k, v in pairs(self.options.members) do
		if k == self.selected then
			v.x = General.screenW * .3 - 64
			v:setColor(255,255,0,255)
		else
			v.x = General.screenW * .3
			v:setColor(255,255,255,255)
		end
	end
	
	State.update(self)
end

function OptionState:draw()
	State.draw(self)
end

function OptionState:keypressed(key)
	if key == "escape" then
		General:setState(MenuState)
	elseif key == "w" or key == "up" then 
		self.optionSound:rewind() 
		self.optionSound:play()
		self.selected = (self.selected + self.options:getSize() - 2) % self.options:getSize() + 1
    elseif key == "s" or key == "down" then
		self.optionSound:rewind() 
		self.optionSound:play()
		self.selected = (self.selected + self.options:getSize()) % self.options:getSize() + 1
    elseif key == "d" or key == "right" then
		if self.selected == 1 then
			General:incrementVolume()
			self.options.members[1]:setLabel("Volume " .. General:getVolume() )
		elseif self.selected == 2 then
						
		end
		OptionState:updateVolume()
	elseif key == "a" or key == "left" then
		if self.selected == 1 then
			General:decrementVolume()
			self.options.members[1]:setLabel("Volume " .. General:getVolume() )
		elseif self.selected == 2 then	
		end
		OptionState:updateVolume()
	end
end

function OptionState:loadGame()
	General:setState(GameState)
end

function OptionState:updateVolume()
	love.audio.setVolume(General:getVolume())
end