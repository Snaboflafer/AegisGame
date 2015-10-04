--Group class. Supports sprites (and children) or groups.
--Call update/draw functions on a group to update its members.

Group = {
	members = {},
	exists = true,
	active = true,
	visible = true,
	solid = true
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
function Group:delete(SelObject)
	if self.size == 0 then
		return
	end
	for i=1, Group.getSize(self), 1 do
		if self.members[i] == SelObject then
			table.remove(self.members, i)
			return
		end
	end
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
	if not self.active or not self.exists then
		return
	end

	for k,v in pairs(self.members) do
		v:update()
	end
end

function Group:draw()
	if not self.visible or not self.exists then
		return
	end

	for k,v in pairs(self.members) do
		v:draw()
	end
end

function Group:setActive(Active)
	self.active = Active
end
function Group:setExists(Exists)
	self.exists = Exists
end
function Group:setSolid(Solid)
	self.solid = Solid
end
function Group:setVisible(Visible)
	self.visible = Visible
end

function Group:getType()
	return "Group"
end

function Group:getDebug()
	printStr = "Group:\n"
	for k,v in pairs(self.members) do
		printStr = printStr .. "  " .. k .. ":\t" .. v:getDebug() .. "\n"
	end
	return printStr
end

return Group
