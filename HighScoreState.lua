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
	self.headerFont = love.graphics.newFont("fonts/Square.ttf", 96)
	self.subFont = love.graphics.newFont("fonts/04b09.ttf", 32)
	self.width = self.headerFont:getWidth(self.name)
	self.height = self.headerFont:getHeight(self.name)
	self.subWidth = self.headerFont:getWidth(self.players)
	self.subHeight = self.headerFont:getHeight(self.players)
end

function HighScoreState:draw()
	State:draw()

	love.graphics.setFont(self.headerFont)
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.printf(
		self.name,
		0,
		Utility:mid(self.height, General.screenH*.5),
		General.screenW,
		'center'
	)
	love.graphics.setFont(self.subFont)
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