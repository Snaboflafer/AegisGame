--[[
	Steven Austin sausti12@jhu.edu
	Nathaniel Rhodes nrhodes5@jhu.edu
	Jung Yang jyang99@jhu.edu
	Andrew Shiau ashiau1@jhu.edu
	Team: SOL
]]

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
	current = TitleState
	current:start()
end

function love.update(dt)
	current:update(dt)
end

function love.draw()
	current:draw()
end

function love.keyreleased(key)
	current:keyreleased(key)
end
