MessageBox = {
	BOXEXPANDTIME = .1,
	BOXMINW = .05,
	BOXMINH = .1,
	alive = false,
	members = {},
	lineGroups = {},
	autoAdvance = true,
	autoAdvanceTime = 2,
	text = {},
	currentText = nil,
	currentTextPosition = 1,
	displayedCharacters = 0,
	lineGroups = {},
	pointer = nil,
	width = 0,
	height = 0,
	x = 0,
	y = 0,
	typeFace = "fonts/forgotten_futurist_bd.ttf",
	font = nil,
	text = ""
}

function MessageBox:init()
	s = {}
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.members = {}
	s.width = General.screenW - General.screenW/80
	s.height = General.screenH/3
	s.x = General.screenW/(80*2)
	s.y = General.screenW/160
	s.font = love.graphics.newFont(self.typeFace, 44)
	s.visible = false
	s.lineGroups = {}
	s.currentTextPosition = 1
	
	return s
end

function MessageBox:show(Label)
	self.text = Label
	self.visible = true
	self.alive = true
	self.currentText:setVisible(true)
	self.currentTextPosition = 1
	
	self.lineGroups = {}
	
	local lines = {}
	local line = ""
	--make lines that fit in the text box
	for word in string.gmatch(self.text, "[^%s]+") do
		if self.font:getWidth(line .. word .. " ") > self.width * .95 then
			--Can't fit another word on this line, so register and reset line buffer
			table.insert(lines,line)
			line = word .. " "
		else
			--Add word to the current line
			line = line .. word .. " ";
		end
	end
	--Register the last line
	table.insert(lines, line)
	
	--Group text into chunks of three lines
	for index = 1, table.getn(lines), 3 do
		--Skip through lines by every third
		local lineChunk = lines[index]
		--Insert the first line into the chunk, and try to add following two (if exist)
		if lines[index+1] ~= nil then
			lineChunk = lineChunk .."\n" .. lines[index+1]
		end
		if lines[index+2] ~= nil then
			lineChunk = lineChunk .."\n" .. lines[index+2]
		end
		--Insert chunk into the list of lines
		table.insert(self.lineGroups, lineChunk)
	end
end

function MessageBox:genComponents()
	self.box = Sprite:new()
	self.box:createGraphic(self.width, self.height, {30,30,30}, 130)
	self.box.scrollFactorX = 0
	self.box.scrollFactorY = 0
	self.box.x = self.x + .5*self.width
	self.box.y = self.y + .5*self.height
	self.box.originX = self.width / 2
	self.box.originY = self.height / 2
	self.box.scaleX = MessageBox.BOXMINW
	self.box.scaleY = MessageBox.BOXMINH
    table.insert(self.members, self.box)

	self.pointer = Sprite:new(self.x + self.width - .1 * self.width, self.y + self.height - .15 * self.height, LevelManager:getImage("message_next"))
	table.insert(self.members,self.pointer)
	self.pointer.scrollFactorY = 0
	self.pointer.scrollFactorX = 0
	self.pointer:flash({255,160,0}, 1, true)
	self.pointer:setVisible(false)
	
	self.currentText = Text:new(self.x + self.width/20, self.y + self.height/10, "",self.typeFace, 44)
	self.currentText:setAlign(Text.LEFT)
	table.insert(self.members, self.currentText)
	self:nextText()
end

function MessageBox:keypressed()
	if self:allCharactersDisplayed() then
		self:nextText();
	else
		self:displayAll();
	end
end

function MessageBox:nextText()
	if self:onLastLine() then
		self.alive = false
		self.currentText:setVisible(false)
		self.pointer:setVisible(false)
		-- return false as an indication to start the next trigger
		return false
	end
	if self.pointer ~= nil then
		self.pointer:setVisible(false)
	end
	self.currentTextPosition = self.currentTextPosition + 1
	self.displayedCharacters = 0
	return true
end

function MessageBox:onLastLine()
	if (self.lineGroups[self.currentTextPosition+1] == nil) then
		return true
	else
		return false
	end
end

function MessageBox:displayAll()
	if (self.lineGroups[self.currentTextPosition] ~= null) then
		self.displayedCharacters = string.len(self.lineGroups[self.currentTextPosition])
		self.currentText:setLabel(string.sub(self.lineGroups[self.currentTextPosition],1,self.displayedCharacters))
	end
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
	if self.alive then
		if self.box.scaleY < 1 then
			self.box.scaleY = self.box.scaleY + General.elapsed / MessageBox.BOXEXPANDTIME
			if self.box.scaleY > 1 then
				self.box.scaleY = 1
			end
		elseif self.box.scaleX < 1 then
			self.box.scaleX = self.box.scaleX + General.elapsed / MessageBox.BOXEXPANDTIME / 2
			if self.box.scaleX > 1 then
				self.box.scaleX = 1
			end
		else
			self:displayNextCharacter()
		end
		
		for k,v in pairs(self.members) do
			if v.exists and v.active then
				v:update()
			end
		end
	else
		if self.box.scaleY > MessageBox.BOXMINH then
			self.box.scaleY = self.box.scaleY - General.elapsed / MessageBox.BOXEXPANDTIME
			if self.box.scaleY < MessageBox.BOXMINH then
				self.box.scaleY = MessageBox.BOXMINH
			end
		elseif self.box.scaleX > MessageBox.BOXMINW then
			self.box.scaleX = self.box.scaleX - General.elapsed / MessageBox.BOXEXPANDTIME / 2
			if self.box.scaleX < MessageBox.BOXMINW then
				self.box.scaleX = MessageBox.BOXMINW
			end
		else
			self:setVisible(false)
		end
	end
end

function MessageBox:displayNextCharacter()
	if not self:allCharactersDisplayed() then
		self.displayedCharacters = self.displayedCharacters + 1
		self.currentText:setLabel(string.sub(self.lineGroups[self.currentTextPosition],1,self.displayedCharacters))
	else
		self.pointer:setVisible(true)
		if not self:onLastLine() then
			self.pointer:loadImage(LevelManager:getImage("message_next"))
		else
			self.pointer:loadImage(LevelManager:getImage("message_close"))
		end
	end
end

function MessageBox:allCharactersDisplayed()
	if self.lineGroups[self.currentTextPosition] == null or self.displayedCharacters < string.len(self.lineGroups[self.currentTextPosition]) then
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