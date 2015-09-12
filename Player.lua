--Class for sprites. Should extend Object
snbPlayer = {
}

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
	return self

return {
	new = new
}
