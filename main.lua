time = 0

require("General")
require("Utility")
require("State")
require("TitleState")
require("HighScoreState")
require("GameState")
require("MenuState")
require("Group")
require("Button")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")

function love.load()
	TitleState:load()
	MenuState:load()
	HighScoreState:load()
	GameState:load()
	
	General:setState(TitleState)
	--current = TitleState
	--General.activeState:start()
	--current:start()
end

function love.update(dt)
	General.activeState:update(dt)
end

function love.draw()
	General.activeState:draw()
end

function love.keyreleased(key)
	General.activeState:keyreleased(key)
end
