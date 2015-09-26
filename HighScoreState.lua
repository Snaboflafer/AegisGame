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
		content,
		0,
		Utility:mid(self.subHeight, General.screenH),
		General.screenW,
		'center'
	)
end

local open = io.open

local function read_file(path)
    local file = open("highScores.txt", "rb") -- r read mode and b binary mode
    if not file then return nil end
    content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local fileContent = read_file("foo.html");
print (fileContent);
function HighScoreState:keyreleased(key)
	if key == "escape" then
		General:setState(MenuState)
	end
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