--State Class

State = {
	members = {}
}

function State:new()
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	members = {}
	
	return s
end

function State:add(NewObject)
	table.insert(self.members, NewObject)
end

function State:update()
	for k,v in pairs(self.members) do
		v:update()
	end
end

function State:draw()
	for k,v in pairs(self.members) do
		v:draw()
	end
end

return State
