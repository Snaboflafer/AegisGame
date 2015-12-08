--- Menu screen state.
MenuState = {
	loaded = false,
	selected = 1
}
MenuState.__index = MenuState
setmetatable(MenuState, State)

function MenuState:load()
	State.load(self)
	
	local txtTitle = "MENU"
	local txtOptions = {"Start", "High Scores", "Options", "Quit"}
	local txtInfo = "[Press ~ for debug]"
	local typeFace = LevelManager:getFont()
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtTitle, typeFace, 64)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(255, 255, 255, 255)
	headerText:setShadow(255, 90, 0, 255)
	MenuState:add(headerText)
	
	self.options = Group:new()
	self.selected = 1
	for i=1, table.getn(txtOptions), 1 do
		local curText = Text:new(General.screenW * .3, General.screenH * .5 + 48 * (i-1),
						txtOptions[i], typeFace, 48)
		self.options:add(curText)
	end
	MenuState:add(self.options)
	
	local debugInfo = Text:new(General.screenW, General.screenH - 16,
						txtInfo, typeFace, 16)
	debugInfo:setAlign(Text.RIGHT)
	MenuState:add(debugInfo)
	
	self.optionSound = love.audio.newSource("sounds/menu_sounds/cw_sound27.wav")
	self.selectSound = love.audio.newSource("sounds/menu_sounds/cw_sound44.wav")
	self.failSound = love.audio.newSource("sounds/menu_sounds/cw_sound39.wav")
	self.exitSound = love.audio.newSource("sounds/menu_sounds/cw_sound34.wav")
end

function MenuState:start()
	Input:gamepadBindMenu()
	State.start(self)
	SoundManager:playBgm("sounds/blast_network.mp3")
end
function MenuState:stop()
	State.stop(self)
	SoundManager:stopBgm()
end

function MenuState:update()
	if Input:justPressed(Input.UP) then
		self.optionSound:rewind() 
		self.optionSound:play()
		self.selected = (self.selected + self.options:getSize() - 2) % self.options:getSize() + 1
	elseif Input:justPressed(Input.DOWN) then
		self.optionSound:rewind() 
		self.optionSound:play()
		self.selected = (self.selected + self.options:getSize()) % self.options:getSize() + 1
	elseif Input:justPressed(Input.SELECT) or Input:justPressed(Input.PRIMARY) then
		if self.selected == 1 then
			General:getCamera():fade({255,255,255}, .2)
			SoundManager:stopBgm()
			Timer:new(.3, self, MenuState.loadGame)
			--General:setState(GameLoadState) 
			--HighScoreState.loaded = false
		elseif self.selected == 2 then
			self.selectSound:rewind()
			self.selectSound:play()
			General:setState(HighScoreState)
		elseif self.selected == 3 then
			self.failSound:rewind()
			self.failSound:play()
			General:setState(OptionState)
		elseif self.selected == 4 then
			self.exitSound:rewind()
			self.exitSound:play()
			love.event.quit()
		end
	end

	for k, v in pairs(self.options.members) do
		if k == self.selected then
			v.x = General.screenW * .3 - 64
			v:setColor(255, 201, 0, 255)
		else
			v.x = General.screenW * .3
			v:setColor(255,255,255,255)
		end
	end
	
	State.update(self)
end

function MenuState:draw()
	State.draw(self)
end

function MenuState:loadGame()
	General:setState(GameState)
end

