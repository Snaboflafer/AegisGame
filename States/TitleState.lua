TitleState = {
	loaded = false
}
TitleState.__index = TitleState
setmetatable(TitleState, State)

function TitleState:load()
	State.load(self)
	
	local imgShape = Sprite:new(100,100, "images/menu/titleshape.png")
	TitleState:add(imgShape)
	
	local imageTitle1 = Sprite:new(100,45, "images/GameTitleShadow.png")
	TitleState:add(imageTitle1)
	imageTitle1:flash({255,160,0}, 1, true)
	local imageTitle2 = Sprite:new(100,40, "images/GameTitle.png")
	TitleState:add(imageTitle2)
	local typeFace = LevelManager:getFont()

	local txtTitle = "•2015 Team SOL"
	local txtInstructions = "Press any key..."
	
	local creditText = Text:new(General.screenW * .5, General.screenH - 64,
							txtTitle, typeFace, 32)
	creditText:setAlign(Text.CENTER)
	TitleState:add(creditText)
	
	local instructionText = Text:new(General.screenW * .5, General.screenH * .6,
							txtInstructions, typeFace, 32)
	instructionText:setAlign(Text.CENTER)
	instructionText:flash({127,127,127}, .8, true)
	TitleState:add(instructionText)

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

