MessageBox = {
	members = {},
	autoAdvance = true,
	autoAdvanceTime = 2,
	text = {},
	currentText = nil,
	currentTextPosition = 0,
	displayedCharacters = 0,
	lineGroups = {},
	pointer = nil,
	font = nil
}

function MessageBox:new(Label, TypeFace)
	s = {}
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.members = {}
	s.font = love.graphics.newFont("fonts/HelveticaNeue.ttf", 44)
	s.text = Label
	local lines = {}
	s.lineGroups = {}
	local line = ""
	--make lines that fit in the text box
	for word in string.gmatch(s.text, "[^%s]+") do
		print(word)
		if (s.font:getWidth(line .. word .. " ") > 800) then
			table.insert(lines,line)
			line = word .. " "
		else
			line = line .. word .. " ";
		end
	end
	table.insert(lines,line)
	--group lines in groups of three
	for index = 1, table.getn(lines), 3 do
		local threeLines = lines[index] 
		if lines[index+1] ~= nil then
			threeLines = threeLines .."\n" .. lines[index+1]
		end
		if lines[index+2] ~= nil then
			threeLines = threeLines .."\n" .. lines[index+2]
		end
		table.insert(s.lineGroups, threeLines)
	end
	s.visible = false
	return s
end

function MessageBox:addBox()
	local GROUNDDEPTH = 100
	local box = Sprite:new()
	box:createGraphic(General.screenW - General.screenW/80,General.screenH/3, {0,0,0}, 150)
	box.scrollFactorX = 0
	box.scrollFactorY = 0
	box.x = General.screenW/(80*2)
	box.y = General.screenH*2/3 - GROUNDDEPTH - General.screenH/30
    table.insert(self.members, box)
end

function MessageBox:addPointer()
	self.pointer = Sprite:new(720,440, "images/UI/Pointing.png")
	table.insert(self.members,self.pointer)
	self.pointer.scrollFactorY = 0
	self.pointer.scrollFactorX = 0
	self.pointer:flash({255,160,0}, 1, true)
	self.pointer:setVisible(false)
end

function MessageBox:keypressed()
	if self:allCharactersDisplayed() then
		self:nextText();
	else
		self:displayAll();
	end
end

function MessageBox:addText()
	local GROUNDDEPTH = 100
	self.currentText = Text:new(General.screenW/80 + General.screenW/80, General.screenH*2/3 - GROUNDDEPTH - General.screenH/30 + General.screenW/80, "","fonts/HelveticaNeue.ttf", 44)
	self.currentText:setAlign(Text.LEFT)
	table.insert(self.members, self.currentText)
	self:nextText()
end

function MessageBox:nextText()
	if (self.lineGroups[self.currentTextPosition+1] == nil) then
		return false;
	end
	if self.pointer ~= nil then
		self.pointer:setVisible(false)
	end
	self.currentTextPosition = self.currentTextPosition + 1
	self.displayedCharacters = 0
	return true
end

function MessageBox:displayAll()
	self.displayedCharacters = string.len(self.lineGroups[self.currentTextPosition])
	self.currentText:setLabel(string.sub(self.lineGroups[self.currentTextPosition],1,self.displayedCharacters))
end

function MessageBox:destroy()
	for k, v in pairs(self.members) do
		v:destroy()
		self.members[k] = nil
	end
	self.members = nil
	self = nil
end

function MessageBox:update()
	if self.visible then
		self:displayNextCharacter()
	end
	for k,v in pairs(self.members) do
		if v.exists and v.active then
			v:update()
		end
	end
end

function MessageBox:displayNextCharacter()
	if self:allCharactersDisplayed() == false then
		self.displayedCharacters = self.displayedCharacters + 1
		self.currentText:setLabel(string.sub(self.lineGroups[self.currentTextPosition],1,self.displayedCharacters))
	else
		self.pointer:setVisible(true)
	end
end

function MessageBox:allCharactersDisplayed()
	if self.displayedCharacters < string.len(self.lineGroups[self.currentTextPosition]) then
		return false;
	else
		return true;
	end
end
--[[ Draw all members of the group
]]
function MessageBox:draw()
	for k,v in pairs(self.members) do
		if v.exists and v.visible then
			v:draw()
		end
	end
end

function MessageBox:getDebug()
	debugStr = ""
	debugStr = debugStr .. "MessageBox:\n"
	debugStr = debugStr .. "\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t Label = \"" .. self.label .. "\"\n"
	debugStr = debugStr .. "\t TypeFace = " .. self.typeFace .. "\n"
	debugStr = debugStr .. "\t Size = " .. self.size .. "\n"

	return debugStr
end

function MessageBox:getType()
	return "MessageBox"
end