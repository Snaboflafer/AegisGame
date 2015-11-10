--- HighScoreState screen state.
HighScoreState = {
	loaded = false,
	name = "High Scores",
	time = 0,
	highScores = nil
}
HighScoreState.__index = HighScoreState
setmetatable(HighScoreState, State)

function HighScoreState:load()
	State.load(self)
	
	local txtHeader = "High Scores"
	
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtHeader, "fonts/Commodore.ttf", 64)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 240, 255)
	headerText:setShadow(180, 130, 0, 255)
	HighScoreState:add(headerText)
	
	local highScores = HighScoreState:readHighScores("highScores.json")
	local scoresText = Text:new(General.screenW * .1, General.screenH * .5,
						highScores, "fonts/Commodore.ttf", 32)
	scoresText:setAlign(Text.LEFT)
	HighScoreState:add(scoresText)

	self.exitSound = love.audio.newSource("sounds/menu_sounds/cw_sound34.wav")

end

function HighScoreState:start()
	State.start(self)
end
function HighScoreState:stop()
	State.stop(self)
end

function HighScoreState:update()
	State.update(self)
end

function HighScoreState:draw()
	State.draw(self)
end

function HighScoreState:readHighScores(path)
	local contents, size = love.filesystem.read(path, size)
	local jsonObject = JSON:decode(contents)
	local highScores = jsonObject["highScores"]

    local content = ""

	for k, scoreObject in pairs(highScores) do
		content = content .. scoreObject["name"] .. " " .. scoreObject["score"] .. "\n"
	end
	return content
end

function HighScoreState:keypressed(key)
	self.exitSound:rewind()
	self.exitSound:play()
	General:setState(MenuState)
end
