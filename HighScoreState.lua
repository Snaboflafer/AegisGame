--- HighScoreState screen state.
HighScoreState = {
	name = "High Scores",
	players = "Steven Austin 5000\nDavid Kimberk 4545\nEddie Snowden 3000\n",
	time = 0
}
HighScoreState.__index = HighScoreState
setmetatable(HighScoreState, State)

function HighScoreState:load()
	State.load(self)
	self.width = General.headerFont:getWidth(self.name)
	self.height = General.headerFont:getHeight(self.name)
	self.subWidth = General.headerFont:getWidth(self.players)
	self.subHeight = General.headerFont:getHeight(self.players)
end

function HighScoreState:draw()
	State:draw()

	love.graphics.setFont(General.headerFont)
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.printf(
		self.name,
		0,
		Utility:mid(self.height, General.screenH*.5),
		General.screenW,
		'center'
	)
	love.graphics.setFont(General.subFont)
	love.graphics.printf(
		highScores,
		0,
		Utility:mid(self.subHeight, General.screenH),
		General.screenW,
		'center'
	)
end


local function readHighScores(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = ""
    local name = ""
    local score = ""
	repeat
	    content = content .. name .. " " .. score .. "\n"
	    name = file:read "*l"
	    score = file:read "*n"
	    file:read "*L"
	until score == nil
	file:close()
    return content
end

highScores = readHighScores("highScores.txt");

function HighScoreState:keyreleased(key)
	General:setState(MenuState)
end
function HighScoreState:start()
end

function HighScoreState:stop()
end
--[[
function HighScoreState:keyreleased(key)
	self.keyPressSound:rewind() 
	self.keyPressSound:play()
end
--]]