--State Object

State = {
	members = {}
}

State.__index = State

function State:load()
end

function State:add(NewObject)
	table.insert(self.members, NewObject)
end

function State:start()
end

function State:stop()
end

function State:keyreleased(key)
end

function State:update(dt)
	General.elapsed = dt * General.timeScale
	time = time + General.elapsed
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	for k,v in pairs(self.members) do
		v:update()
	end
end

function State:draw()
	for k,v in pairs(self.members) do
		v:draw()
	end
end

function switchTo(state)
	current:stop()
	current = state
	current:start()
end

function lerp(a, b, t)
        return (1-t)*a + t*b
end

function center(large,small)
	return large/2 - small/2
end
return State
