--- HighScoreState screen state.
HighScoreState = {
	name = "High Scores",
	time = 0,
	highScores
}
HighScoreState.__index = HighScoreState
setmetatable(HighScoreState, State)

function HighScoreState:load()
	State.load(self)
	self.width = General.headerFont:getWidth(self.name)
	self.height = General.headerFont:getHeight(self.name)
	self.subWidth = 300
	self.subHeight = 20
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

function HighScoreState:keypressed(key)
	General:setState(MenuState)
end

function HighScoreState:start()
end

function HighScoreState:stop()
end