--- Paused screen state.
PauseState = {
	title = "GAME PAUSED",
	options = {
		"Resume",
		"Brightness",
		"Volume",
		"Quit"
	}
}
PauseState.__index = PauseState
setmetatable(PauseState, MenuState)

function PauseState:keyreleased(key)
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
        elseif self.highlight == 4 then
        	love.event.quit()
        end
    end
end
--function PauseState:load()
