--Group class. Supports sprites (and children) or groups.
--Call update/draw functions on a group to update its members.

Group = {
	members = {},
	length = 0,
	exists = true,
	active = true,
	visible = true,
	solid = true,
	showDebug = false
}

function Group:new()
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	s.members = {}
	
	return s
end

--[[ Get the size of the group
	Returns		The number of members
]]
function Group:getSize()
	return self.length
end

--[[ Adds an object into the group
	NewObject	Object to add
]]
function Group:add(NewObject)
	table.insert(self.members, NewObject)
	self.length = self.length + 1
end

--[[ Remove an object from the group
	SelObject	Object to remove
	Recurse		Also search for the object in child groups
	
	Returns		true if object found/deleted, false if not
]]
function Group:delete(SelObject, Recurse)
	if self.size == 0 then
		return false
	end
	for i=1, self.length do
		if self.members[i] == SelObject then
			--Found object, remove
			table.remove(self.members, i)
			self.length = self.length - 1
			return true
		elseif Recurse and self.members[i]:getType() == "Group" then
			--Recurse into nested groups
			if Group:delete(SelObject) then
				return true
			end
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
	for k,v in pairs(self.members) do
		if v.exists and v.active then
			v:update()
		end
	end
end

--[[ Draw all members of the group
]]
function Group:draw()
	for k,v in pairs(self.members) do
		if v.exists and v.visible then
			v:draw()
		end
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

--[[Set a variable for each of a group's members
	VarName		String name of variable
	Value		Value to set
	Recurse		Apply variables to subgroups' members, not directly on groups
--]]
function Group:setEach(VarName, Value, Recurse)
	if Recurse == nil then
		Recurse = true
	end
	
	local curMember
	
	for i=1, self.length do
		curMember = self.members[i]
		
		if curMember:getType() == "Group" then
			--Member is a group
			
			if Recurse then
				--Recurse into this group's members
				curMember:setEach(VarName, Value, Recurse)
			else
				--Set the value directly on the group
				curMember[VarName] = Value
			end
		else
			--Set value for member
			curMember[VarName] = Value
		end
	end
end

--[[Returns the first element where exists==false
	Recurse		Set true to search subgroups as well. Otherwise, groups
				will be ignored
--]]
function Group:getFirstAvailable(Recurse)
	local result
	for i=1, self.length do
		result = self.members[i]
		if result:getType() == "Group" and Recurse then
			result = result:getFirstAvailable(Recurse)
			if result ~= nil then
				return result
			end
		elseif not result.exists then
			return result
		end
	end
	
	return nil
end

function Group:getType()
	return "Group"
end

function Group:getDebug()
	printStr = self:getType() .. "\t (" .. self.length .. " members)\n"
	for k,v in pairs(self.members) do
		printStr = printStr .. "  " .. k .. ":\t" .. v:getDebug() .. "\n"
	end
	return printStr
end

return Group
