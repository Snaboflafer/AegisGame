--Class for Objects.
snbObject = {
	__index = snbObject,
	x = 0,
	y = 0,
	velocity = {x=0, y=0},
	width = "DEFAULT WIDTH",
	height = "DEFAULT HEIGHT",
	updates = "DEFAULT UPDATES",
	visible = "DEFAULT VISIBLE",
	exists = true,
	active = true,
	visible = true,
	alive = true
}

local function new(self, X, Y, Width, Height)
	self = self or {}

	self = setmetatable({}, { __index = snbObject})
	--setmetatable( self, snbObject_mt)

	self.x = X
	self.y = Y
	self.width = Width
	self.height = Height
	
	
	function self.destroy()
	end
	
	function self.update()
	end
	
	function self.draw()
	end
	
	return self
end

return {
	new = new
}
