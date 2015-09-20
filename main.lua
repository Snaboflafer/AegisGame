time = 0

require("General")
require("Utility")
require("State")
require("GameState")
require("MenuState")
require("Group")
require("Button")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")

function love.load()
	GameState:load()
	MenuState:load()
	current = MenuState
	current:start()
end

function love.update(dt)
	current:update(dt)
end

function love.draw()
	current:draw()
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	else
		current:keyreleased(key)
	end

end
