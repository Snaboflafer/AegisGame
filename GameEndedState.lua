GameEndedState = {
	loaded = false,
	title = "GAME OVER"
}
GameEndedState.__index = GameEndedState
setmetatable(GameEndedState, State)

function GameEndedState:load()
	State.load(self)
		
	local txtHeader = "GAME OVER"
	
	local headerText = Text:new(General.screenW * .5, General.screenH * .2,
						txtHeader, "fonts/Commodore.ttf", 64)
	headerText:setAlign(Text.CENTER)
	headerText:setColor(240, 240, 240, 255)
	headerText:setShadow(150, 150, 0, 255)
	GameEndedState:add(headerText)
	
	local scoreHeaderText = Text:new(General.screenW * .5, General.screenH * .5,
						"Score:", "fonts/Commodore.ttf", 48)
	scoreHeaderText:setAlign(Text.CENTER)
	GameEndedState:add(headerText)
	
	local scoreText = Text:new(General.screenW * .5, General.screenH * .5,
						General:getScore(), "fonts/Commodore.ttf", 48)
	scoreText:setAlign(Text.CENTER)
	GameEndedState:add(scoreText)
end

function GameEndedState:start()
	State.start(self)
	self.closeTimer = 5
end

function GameEndedState:stop()
	State.stop(self)
end

function GameEndedState:update()
	State.update(self)
	
	self.closeTimer = self.closeTimer - General.elapsed
    if self.closeTimer <= 0 then
    	--patchwork fix for GameState improper closing bug
    	--love.event.push('quit')
		General:setState(HighScoreState)
    end
end

function GameEndedState:draw()
	State.draw(self)
end
function GameEndedState:keypressed(key)
	--patchwork fix for GameState improper closing bug
	--love.event.push('quit')
    --General:setState(HighScoreState)
end



