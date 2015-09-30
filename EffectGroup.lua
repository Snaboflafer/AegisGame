
EffectGroup = {
	members = {}
}

function Group:new()
	s = {}
	setmetatable(s, self)
	self.__index = self
	members = {}
	
	return s
end

function EffectGroup:getEffect(effectKey)
	return self.members[effectKey]
end

function EffectGroup:add(effectKey, effect)
	self.members[effectKey] = effect
end

return EffectGroup
