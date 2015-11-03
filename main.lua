--[[
	Steven Austin sausti12@jhu.edu
	Nathaniel Rhodes nrhodes5@jhu.edu
	Jung Yang jyang99@jhu.edu
	Andrew Shiau ashiau1@jhu.edu
	Team: SOL
]]

time = 0

require("Utility/General")
require("Utility/Utility")
require("Utility/LevelManager")
require("Utility/Group")
require("Utility/Camera")
require("Utility/Timer")
require("Utility/Effect")
require("Utility/Emitter")
require("Utility/SoundManager")
require("Utility/Script")
require("States/State")
require("States/TitleState")
require("States/MenuState")
require("States/HighScoreState")
require("States/GameLoadState")
require("States/GameState")
require("States/PauseState")
require("States/GameEndedState")
require("States/NewHighScoreState")
require("Sprites/Sprite")
require("Sprites/Text")
require("Sprites/MessageBox")
require("Sprites/Player")
require("Sprites/PlayerShip")
require("Sprites/PlayerMech")
require("Sprites/Enemy")
require("Sprites/Enemy1")
require("Sprites/Enemy2")
require("Sprites/Enemy3")
require("Sprites/Boss")

function love.load()
	General:init()
	--Camera:newCamera(General.screenW/2,General.screenH/2)

	debugText = Text:new(0,0, "fonts/lucon.ttf", 12)
	debugText.visible = false
	
	
	frameTimes = {60}	--First value is average
	frameStartTime = os.time()
	
	General:setState(TitleState)
	General:setCurrentLevel(1)

	LevelManager:parseJSON("game.json")

end

function love.update(dt)
	General.elapsed = dt * General.timeScale
	time = time + General.elapsed
	General.activeState:update()
    SoundManager:update(dt)
	--Update stored frame times
	if os.time() == frameStartTime then
		table.insert(frameTimes, General.elapsed)
	else
		frameTimes = { (frameTimes[1] + 1/(table.getn(frameTimes)-1)) / 2 }
		frameStartTime = os.time()
	end
	
	--Debug text
	debugStr = ""

	--Game speed info
	debugStr = debugStr .. "Frame time = " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. math.floor(10/frameTimes[1])/10 .. " FPS\n"
	debugStr = debugStr .. "Speed x" .. math.floor(10 * General.timeScale) / 10 .. "\n"

	if TitleState.loaded then 
		debugStr = debugStr .. "TitleState (" .. tostring(TitleState) .. ") is loaded\n"
	end
	if GameState.loaded then 
		debugStr = debugStr .. "GameState (" .. tostring(GameState) .. ") is loaded\n"
	end
	if PauseState.loaded then 
		debugStr = debugStr .. "PauseState (" .. tostring(PauseState) .. ") is loaded\n"
	end
	if MenuState.loaded then
		debugStr = debugStr .. "MenuState (" .. tostring(MenuState) .. ") is loaded\n" 
	end
	if HighScoreState.loaded then 
		debugStr = debugStr .. "HighScoreState (" .. tostring(HighScoreState) .. ") is loaded\n"
	end
	if GameEndedState.loaded then 
		debugStr = debugStr .. "GameEndedState (" .. tostring(GameEndedState) .. ") is loaded\n"
	end
	if NewHighScoreState.loaded then 
		debugStr = debugStr .. "NewHighScoreState (" .. tostring(NewHighScoreState) .. ") is loaded\n"
	end


	debugStr = debugStr .. "Registered loaded states:\n"
	if General.loadedStates ~= nil then
		for i=1, General.loadedStates:getSize(), 1 do
			debugStr = debugStr .. "\t(" .. tostring(General.loadedStates.members[i]) .. ")\n"
		end
	end
	debugStr = debugStr .. "Active state:\n\t(" .. tostring(General.activeState) .. ")\n"
	
	
	--Get debug for all members of active state
	for k,v in pairs(General.activeState.members) do
		if v.showDebug then
			debugStr = debugStr .. v:getDebug()	
		end
	end

	debugText:setLabel(debugStr)
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	General:draw()
	
	Text.draw(debugText)
end

function love.keyreleased(key)
	General.activeState:keyreleased(key)
	
	if key == "`" then
		debugText.visible = not debugText.visible
	elseif key == "p" then
		General.timeScale = (math.floor(General.timeScale) + 1) % 2
	end
end

function love.keypressed(key)
	General.activeState:keypressed(key)
	
	if key == "down" then
		debugText.y = debugText.y - 140
	end
	if key == "up" then
		debugText.y = debugText.y + 140
	end
	if key == "=" then
		General.timeScale = General.timeScale - .5
	end
	if key == "-" then
		General.timeScale = General.timeScale + .5
	end
end
