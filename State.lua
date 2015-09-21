--State Object

State = {
	members = {},
	loaded = false,
	time = 0
}

State.__index = State

function State:load()
	self.members = {}
	self.loaded = true
end
function State:unload()
	self:stop()
	self.loaded = false
end

function State:add(NewObject)
	table.insert(self.members, NewObject)
end

function State:start()
	self.time = 0
end

function State:stop()
	for k, v in pairs(self.members) do
		v:destroy()
	end
end


function State:keyreleased(key)
end

function State:update()
	self.time = self.time + General.elapsed
	for k,v in pairs(self.members) do
		v:update()
	end
end

function State:draw()
	for k,v in pairs(self.members) do
		v:draw()
	end
end

function lerp(a, b, t)
        return (1-t)*a + t*b
end

return State
