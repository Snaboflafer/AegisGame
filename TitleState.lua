TitleState = {
	title = "Team SOL game", 
	team = "Assignment part 3", 
	authors = {"Steven Austin", "Nathaniel Rhodes", "Andrew Shiau", "Jung Yang"}
}
setmetatable(TitleState, State)

--Fade disabled, will use a universal fade function in General
function TitleState:fadein()
    --if self.time < 16 then
    --        local c = lerp(0, 255, self.time/16)
    --        return {c, c, c, 255}
    --else
    --        return {255, 255, 255, 255}
    --end
	return {255,255,255,255}
end
function TitleState:load()
    self.sound = love.audio.newSource("sounds/mission_ui.mp3")
end

function TitleState:update()
    if self.time > 20 then
		General:setState(MenuState)
    end
end

function TitleState:draw()
	love.graphics.setFont(General.headerFont)
	love.graphics.setColor(self:fadein())
	love.graphics.print(
		self.title,
		Utility:mid(General.headerFont:getWidth(self.title), General.screenW),
		Utility:mid(General.headerFont:getHeight(self.title), General.screenH*.6)
	)
	love.graphics.print(
		self.team,
		Utility:mid(General.headerFont:getWidth(self.team)*.5, General.screenW), 
		Utility:mid(General.headerFont:getHeight(self.team)*.5, General.screenH*.8),
		0,
		.5,
		.5
	)
	love.graphics.setFont(General.subFont)
	for k,author in pairs(self.authors) do
		love.graphics.print(
			author,
			Utility:mid(General.subFont:getWidth(author), General.screenW), 
			Utility:mid(General.subFont:getHeight(author), General.screenH + General.screenH*(k*.1)),
			0
		)
	end
end
function TitleState:keyreleased(key)
    if key == "escape" then
		love.event.quit()
	end
    General:setState(MenuState)
end
function TitleState:start()
    self.time = 0
    self.sound:play()
end
function TitleState:stop()
    self.sound:stop()
end

