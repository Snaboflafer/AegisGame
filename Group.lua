--Group class. Supports sprites (and children) or groups.
--Call update/draw functions on a group to update its members.

Group = {
	members = {}
}

function Group:new()
	s = {}
	setmetatable(s, self)
	self.__index = self
	--self.__tostring = s:toString()
	
	s.members = {}
	
	return s
end

function Group:getSize()
	local size = 0
	for k, v in pairs(self.members) do
		size = size + 1
	end
	return size
end

function Group:add(NewObject)
	table.insert(self.members, NewObject)
end

function Group:destroy()
	for k, v in pairs(self.members) do
		v:destroy()
		self.members[k] = nil
	end
	self.members = nil
	self = nil
end

function Group:update()
	for k,v in pairs(self.members) do
		v:update()
	end
end

function Group:draw()
	for k,v in pairs(self.members) do
		v:draw()
	end
end

function Group:getType()
	return "Group"
end

function Group:getDebug()
	printStr = "Group:\n"
	for k,v in pairs(self.members) do
		printStr = printStr .. "\t" .. k .. "\t" .. tostring(v) .. " (" .. v:getType() .. ")\n"
	end
	return printStr
end

return Group
