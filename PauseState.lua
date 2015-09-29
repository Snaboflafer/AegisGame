--- Paused screen state. Currently just copies menu state.
PauseState = {
	selected = 1
}
PauseState.__index = PauseState
setmetatable(PauseState, MenuState)

function PauseState:load()
	State.load(self)
	
	local txtTitle = "Game Paused"
	local txtOptions = {"Resume", "Options", "Main Menu"}
	
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtTitle, "fonts/Commodore.ttf", 64)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 255)
	headerText:setShadow(0, 150, 150, 255)
	PauseState:add(headerText)
	
	self.options = Group:new()
	self.selected = 1
	for i=1, table.getn(txtOptions), 1 do
		local curText = Text:new(General.screenW * .3, General.screenH * .5 + 48 * (i-1),
						txtOptions[i], "fonts/Commodore.ttf", 48)
		self.options:add(curText)
	end
	PauseState:add(self.options)
	
	self.optionSound = love.audio.newSource("sounds/select_1.wav")
	self.selectSound = love.audio.newSource("sounds/select_2.wav")
end

function PauseState:start()
	State.start(self)
end
function PauseState:stop()
	State.stop(self)
end

function PauseState:update()
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

function PauseState:draw()
	State.draw(self)
end

function PauseState:keyreleased(key)
	if key == "escape" then
		General:setState(GameState)
	end
end
function PauseState:keypressed(key)
	if key == "w" or key == "up" then 
		self.optionSound:rewind() 
		self.optionSound:play()
		self.selected = (self.selected + self.options:getSize() - 2) % self.options:getSize() + 1
    elseif key == "s" or key == "down" then
		self.optionSound:rewind() 
		self.optionSound:play()
		self.selected = (self.selected + self.options:getSize()) % self.options:getSize() + 1
    elseif key == "return" or key == " " then
		self.selectSound:rewind()
		self.selectSound:play()
		if self.selected == 1 then 
			General:setState(GameState)
		elseif self.selected == 2 then
			--General:setState(OptionsState, false)
		elseif self.selected == 3 then
	--DONT CLOSE GAMESTATE until state state closure is properly worked out
			--General:closeState(GameState)
			General:setState(MenuState)
		end
    end
end