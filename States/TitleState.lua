TitleState = {
	loaded = false
}
TitleState.__index = TitleState
setmetatable(TitleState, State)

function TitleState:load()
	State.load(self)
	local imageTitle1 = Sprite:new(100,85, "images/GameTitleShadow.png")
	TitleState:add(imageTitle1)
	imageTitle1:flash({255,160,0}, 1, true)
	local imageTitle2 = Sprite:new(100,80, "images/GameTitle.png")
	TitleState:add(imageTitle2)


	local txtTitle = "Team SOL"
	local txtInstructions = "Press any key..."
	local txtAuthors = {"Steven Austin", "Nathaniel Rhodes", "Andrew Shiau", "Jung Yang"}
	
	local titleText = Text:new(General.screenW * .5, General.screenH*.7,
							txtTitle, "fonts/Commodore.ttf", 64)
	titleText:setAlign(Text.CENTER)
	TitleState:add(titleText)
	
	--[[local instructionText = Text:new(General.screenW * .5, General.screenH * .6,
							txtInstructions, "fonts/Commodore.ttf", 48)
	instructionText:setAlign(Text.CENTER)
	instructionText:flash({0,0,0}, .5, true)
	TitleState:add(instructionText)]]--


    SoundManager:playBgm("sounds/mission_ui.mp3")
end

function TitleState:start()
    State.start(self)
end
function TitleState:stop()
	State.stop(self)
    SoundManager:stopBgm()
end


function TitleState:keyreleased(key)
    General:setState(MenuState)
end

