TitleState = {
	loaded = false
}
TitleState.__index = TitleState
setmetatable(TitleState, State)

function TitleState:load()
	State.load(self)
	
	local txtTitle1 = "Team SOL"
	local txtTitle2 = "Game"
	local txtInstructions = "Press any key..."
	local txtAuthors = {"Steven Austin", "Nathaniel Rhodes", "Andrew Shiau", "Jung Yang"}
	
	local titleText1 = Text:new(General.screenW * .5, General.screenH * .1,
							txtTitle1, "fonts/Commodore.ttf", 96)
	titleText1:setAlign(Text.CENTER)
	titleText1:setColor(250, 250, 250, 255)
	titleText1:setShadow(0, 150, 150, 255)
	TitleState:add(titleText1)
	
	local titleText2 = Text:new(General.screenW * .5, General.screenH * .1 + 96,
							txtTitle2, "fonts/Commodore.ttf", 96)
	titleText2:setColor(250, 250, 250, 255)
	titleText2:setShadow(0, 150, 150, 255)
	titleText2:setAlign(Text.CENTER)
	TitleState:add(titleText2)
	
	local instructionText = Text:new(General.screenW * .5, General.screenH * .5,
							txtInstructions, "fonts/Commodore.ttf", 48)
	instructionText:setAlign(Text.CENTER)
	TitleState:add(instructionText)

	local authorText
	for i=1, table.getn(txtAuthors), 1 do
		authorText = Text:new(General.screenW * .5, General.screenH - 128 + (32 * (i-1)),
				txtAuthors[i], "fonts/Commodore.ttf", 32)
		authorText:setAlign(Text.CENTER)
		TitleState:add(authorText)
	end
    SoundManager:playBgm("sounds/mission_ui.mp3")
end

function TitleState:start()
    State.start(self)
end
function TitleState:stop()
	State.stop(self)
    SoundManager:stopBgm()
end

function TitleState:update()
	State.update(self)
end

function TitleState:draw()
	State.draw(self)
end

function TitleState:keyreleased(key)
    General:setState(MenuState)
end

