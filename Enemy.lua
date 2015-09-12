--Class for sprites. Should extend Object
enemy = {}

local function new(self, X, Y, ImageFile)
	self = self or {}
	self = setmetatable({}, { __index = sprite})
	
	self.x = X
	self.y = Y
	if (ImageFile ~= nil) then
		self.imageFile = ImageFile
		self.image = love.graphics.newImage(self.imageFile)
	end
	
	self.velocity = {x=0, y=0}
	self.acceleration = {x=0, y=0}
	self.offset = {x=0, y=0}
	self.origin = {x=0, y=0}
	self.scale = {x=1, y=1}
	self.scrollFactor = {x=1, y=1}
	
	function self.destroy()
		self.x = nil
		self.y = nil
		self.offset = nil
		self.origin = nil
		self.scale = nil
		self.width = nil
		self.height = nil
		
		self.curAnim = nil
	end
	
	function self.loadImage(Image, Animated, Flip, Width, Height)
		if Image == nil then
			self.image = love.graphics.newImage("img_blank.bmp")
		else
			self.image = Image
		end
		if Animated == nil then
			animated = false
			image = fullImage
		else
			animated = true
		end
		if Flip == nil then
			flip = 0
		else
			flip = 0
		end
		width = Width or 0
		height = Height or 0
	end
	
	function self.update(self)
		if (not self.exists or not self.active) then
			return
		end
		
		self.velocity.x = self.velocity.x + self.acceleration.x
		self.velocity.y = self.velocity.y + self.acceleration.y
		self.x = self.x + self.velocity.x
		self.y = self.y + self.velocity.y
		--	if animated then
		--		self.updateAnimations()
		--	end
	end
	
	function self.draw()
		if (not self.exists or not self.visible) then
			return
		end
		love.graphics.draw(
			self.image,
			self.x - General.camera.x * self.scrollFactor.x,
			self.y - General.camera.y * self.scrollFactor.y,
			self.rotation,
			self.scale.x self.scale.y,
			self.offset.x, self.offset.y
		)
	end
	
	function self.getDebug()
		debugStr = ""
		debugStr = debugStr .. "\t Image = " .. self.imageFile .. "\n"
		debugStr = debugStr .. "\t x = " .. math.floor(self.x) .. "\n"
		debugStr = debugStr .. "\t y = " .. math.floor(self.y) .. "\n"
		debugStr = debugStr .. "\t velocity = " .. math.floor(self.velocity.x) .. ", " .. math.floor(self.velocity.y) .. "\n"
		debugStr = debugStr .. "\t acceleration = " .. self.acceleration.x .. ", " .. self.acceleration.y .. "\n"
		debugStr = debugStr .. "\t width = " .. self.width .. "\n"
		debugStr = debugStr .. "\t height = " .. self.height .. "\n"
		return debugStr
	end

	return self
	
end

return {
	new = new
}