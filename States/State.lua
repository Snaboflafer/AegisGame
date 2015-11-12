--State Object

State = {
	loaded = false,
	members = {},
	overlay = {},
	time = 0
}

State.__index = State

function State:load()
	General.camera = General:newCamera(0,0)
	self.members = {}
	self.overlay = {}
	self.showDebug = true
	self.loaded = true
end
function State:unload()
	self:stop()
	self.loaded = false
end

function State:add(NewObject)
	table.insert(self.members, NewObject)
end
function State:addOverlay(NewObject)
	table.insert(self.overlay, NewObject)
end

function State:start()
	self.time = 0
end

function State:stop()
	for k, v in pairs(self.members) do
		v:destroy()
		self.members[k] = nil
	end
	for k, v in pairs(self.overlay) do
		v:destroy()
		self.overlay[k] = nil
	end
end

function State:keypressed(key)
end

function State:keyreleased(key)
end

function State:update()
	self.time = self.time + General.elapsed
	General:getCamera():update()
	for k,v in pairs(self.members) do
		if v.active ~= false and v.exists ~= false then
			v:update()
		end
	end
	for k,v in pairs(self.overlay) do
		if v.active ~= false and v.exists ~= false then
			v:update()
		end
	end
end

function State:draw()
	for k,v in pairs(self.members) do
		if v.visible ~= false and v.exists ~= false then
			v:draw()
		end
	end
	
	General:getCamera():drawEffects()

	for k,v in pairs(self.overlay) do
		if v.visible ~= false and v.exists ~= false then
			v:draw()
		end
	end
end

function lerp(a, b, t)
        return (1-t)*a + t*b
end

function State:getType()
	return "State"
end

return State
