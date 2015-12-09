--- Paused screen state. Currently just copies menu state.
PauseState = {
	loaded = false,
	selected = 1
}
PauseState.__index = PauseState
setmetatable(PauseState, State)

function PauseState:load()
	State.load(self)
	
	local txtTitle = "Game Paused"
	local txtOptions = {"Resume", "Main Menu"}
	
	local typeFace = LevelManager:getFont()

	local bgLayer = Sprite:new(0,0)
	bgLayer:createGraphic(General.screenW, General.screenW, {0,0,0}, 100)
	bgLayer.scrollFactorX = 0
	bgLayer.scrollFactorY = 0
	PauseState:add(bgLayer)
	
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtTitle, typeFace, 64)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(255, 255, 255, 255)
	headerText:setShadow(255, 90, 0, 255)
	PauseState:add(headerText)
	
	self.options = Group:new()
	self.selected = 1
	for i=1, table.getn(txtOptions), 1 do
		local curText = Text:new(General.screenW * .3, General.screenH * .5 + 48 * (i-1),
						txtOptions[i], typeFace, 48)
		curText:setShadow(50,50,50,255)
		self.options:add(curText)
	end
	PauseState:add(self.options)
	
	self.optionSound = love.audio.newSource("sounds/menu_sounds/cw_sound27.wav")
	self.selectSound = love.audio.newSource("sounds/menu_sounds/cw_sound44.wav")
	self.failSound = love.audio.newSource("sounds/menu_sounds/cw_sound39.wav")
	self.exitSound = love.audio.newSource("sounds/menu_sounds/cw_sound34.wav")
end

function PauseState:start()
	Input:gamepadBindMenu()
	State.start(self)
end
function PauseState:stop()
	State.stop(self)
end

function PauseState:update()
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
			self.selectSound:rewind()
			self.selectSound:play()
			General:setState(GameState)
		elseif self.selected == 2 then
			self.exitSound:rewind()
			self.exitSound:play()
			General:closeState(GameState)
			General:setState(MenuState)
		end
	elseif Input:justReleased(Input.MENU) then
		General:setState(GameState)
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

function PauseState:draw()
	State.draw(self)
end
