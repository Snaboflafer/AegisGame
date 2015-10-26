JSON = (loadfile "Utility/JSON.lua")()

NewHighScoreState = {
	name = ""	
}

NewHighScoreState.__index = NewHighScoreState
setmetatable(NewHighScoreState, State)

function NewHighScoreState:load()

	if NewHighScoreState:isHighScore() == false then
		General:setState(HighScoreState)
	end

	State.load(self)
	local txtHeader = "Enter your name"
	
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtHeader, "fonts/Commodore.ttf", 44)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 240, 255)
	headerText:setShadow(180, 130, 0, 25)
	NewHighScoreState:add(headerText)

	self.nameText = Text:new(General.screenW * .5, General.screenH * .5,
						NewHighScoreState.name, "fonts/Commodore.ttf", 32)
	self.nameText:setAlign(Text.CENTER)
	self.nameText:setColor(240, 240, 240, 240, 255)
	self.nameText:setShadow(180, 130, 0, 25)
	NewHighScoreState:add(self.nameText)
end

function HighScoreState:update()
	State.update(self)
end

function HighScoreState:draw()
	State.draw(self)
end

function NewHighScoreState:start()
	State.start(self)
end

function NewHighScoreState:stop()
	State.stop(self)
end

function NewHighScoreState:keypressed(key)
	if key == "return" then
		local score = General:getScore()
		NewHighScoreState:updateHighScores(NewHighScoreState.name, score)
		General:setState(GameEndedState)
	elseif key == "backspace" then
		NewHighScoreState.name = string.sub(NewHighScoreState.name, 1, string.len(NewHighScoreState.name) - 1)
	else
		NewHighScoreState.name = NewHighScoreState.name .. key
	end

	NewHighScoreState.name = string.upper(NewHighScoreState.name)
	self.nameText:setLabel(NewHighScoreState.name)
end

function NewHighScoreState:isHighScore() 
	local contents, size = love.filesystem.read("highScores.json", size)
	local jsonObject = JSON:decode(contents)
	local highScores = jsonObject["highScores"]

	local score = General:getScore()
	local isHighScore = false
	
	for k, scoreObject in pairs(highScores) do
		if score > scoreObject["score"] then
			isHighScore = true
			break
		end
	end

	return isHighScore
end


function NewHighScoreState:updateHighScores(name, score)
	local contents, size = love.filesystem.read("highScores.json", size)
	local jsonObject = JSON:decode(contents)
	local highScores = jsonObject["highScores"]

	local position = 1
	for k, scoreObject in pairs(highScores) do
		if score > scoreObject["score"] then
			table.remove(highScores, 5)
			table.insert(highScores, position, {["name"]=name, ["score"]=score}) 
			break
		end
		position = position + 1
	end

	jsonObject["highScores"] = highScores

	local outJSON = JSON:encode_pretty(jsonObject)
	love.filesystem.write("highScores.json", outJSON)
end

