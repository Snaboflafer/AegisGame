-- Option State
OptionState = {
	loaded = false,
}

OptionState.__index = OptionState
setmetatable(OptionState, State)

function OptionState:load()
	State.load(self)
	
	local txtTitle = "OPTIONS"
	local volume = "Volume"
	local typeFace = LevelManager:getFont()
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtTitle, typeFace, 64)

	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 255)
	headerText:setShadow(0, 150, 150, 255)
	OptionState:add(headerText)

	self.volumeText = Text:new(General.screenW * .3, General.screenH * .5 + 48 * (1-1),
						volume, typeFace, 48)
	self.volumeText:setColor(255,255,0,255)

	OptionState:add(self.volumeText)

	self.volumeBox= Sprite:new()
	self.volumeBox:createGraphic(117, 30, {255,255,0}, 65)
	self.volumeBox.x = self.volumeText.x + 200
	self.volumeBox.y = self.volumeText.y + self.volumeText.height / 2

	OptionState:add(self.volumeBox)

	self.volumeBoxSlider = Sprite:new()
	self.volumeBoxSlider:createGraphic(4, 45, {255,255,0}, 255)
	self.volumeBoxSlider.x = self.volumeBox.x
	self.volumeBoxSlider.y = self.volumeBox.y - (self.volumeBoxSlider.height - self.volumeBox.height) / 2

	OptionState:add(self.volumeBoxSlider)

	OptionState:setVolumeSlider()
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
	State.update(self)
end

function OptionState:draw()
	State.draw(self)
end

function OptionState:keypressed(key)
	if key == "escape" then
		General:setState(MenuState)
    elseif key == "d" or key == "right" then
		General:incrementVolume()
		OptionState:updateVolume()
		OptionState:setVolumeSlider()
	elseif key == "a" or key == "left" then
		General:decrementVolume()
		OptionState:setVolumeSlider()
		OptionState:updateVolume()
	end
end

function OptionState:setVolumeSlider()
	local newSliderPos = General:getVolume() * 13
	self.volumeBoxSlider.x = self.volumeBox.x + newSliderPos
end

function OptionState:loadGame()
	General:setState(GameState)
end

function OptionState:updateVolume()
	love.audio.setVolume(General:getVolume())
end