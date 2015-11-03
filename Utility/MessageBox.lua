MessageBox = {
	members = {},
	autoAdvance = true,
	autoAdvanceTime = 2,
	text = {}
}

function MessageBox:new(Label, TypeFace)
	s = {}
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.members = {}
	s.text = "This message box is toggled using a cutscene script. It has a lot of text in it."
	s.text = wrap(s.text,22)
	
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

function MessageBox:addText()
	local GROUNDDEPTH = 100
	local text = Text:new(General.screenW/80 + General.screenW/80, General.screenH*2/3 - GROUNDDEPTH - General.screenH/30 + General.screenW/80, self.text,"fonts/04b09.ttf", 44)
	text:setAlign(Text.LEFT)
	table.insert(self.members, text)
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
	for k,v in pairs(self.members) do
		if v.exists and v.active then
			v:update()
		end
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

function wrap(str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local here = 1-#indent1
  return indent1..str:gsub("(%s+)()(%S+)()",
                          function(sp, st, word, fi)
                            if fi-here > limit then
                              here = st - #indent
                              return "\n"..indent..word
                            end
                          end)
end