-- Sets the controls for the player
Input = {
	UP = 1,		--Enums for each key
	DOWN = 2,
	LEFT = 3,
	RIGHT = 4,
	PRIMARY = 5,
	SECONDARY = 6,
	TERTIARY = 7,
	QUATERNARY = 8,
	MENU = 9,
	SELECT = 10,
	map_keyboard = {},	--Control mapping for keyboard
	map_gamepad = {},	--Control mapping for gamepad
	useGamepad = false,	--Enable/disable gamepad controls (automatically set when a button is pressed)
	gamepad = nil,	--Active gamepad (if any)
	current = {},	--Input that is pressed this frame
	last = {}		--Input that was pressed last frame
}

function Input:init()
	self.gamepad = love.joystick.getJoysticks()[1]
	self.map_keyboard = {
		[self.UP] = "w",
		[self.DOWN] = "s",
		[self.LEFT] = "a",
		[self.RIGHT] = "d",
		[self.PRIMARY] = " ",
		[self.SECONDARY] = "k",
		[self.TERTIARY] = "lshift",
		[self.QUATERNARY] = "",
		[self.MENU] = "escape",
		[self.SELECT] = "return"
	}
	self.gamepadBinds_Menu = {
		[self.UP] = "dpup",
		[self.DOWN] = "dpdown",
		[self.LEFT] = "dpleft",
		[self.RIGHT] = "dpright",
		[self.PRIMARY] = "a",
		[self.SECONDARY] = "b",
		[self.TERTIARY] = "x",
		[self.QUATERNARY] = "y",
		[self.MENU] = "start",
		[self.SELECT] = "a"
	}
	self.gamepadBinds_Game = {
		[self.UP] = "dpup",
		[self.DOWN] = "dpdown",
		[self.LEFT] = "dpleft",
		[self.RIGHT] = "dpright",
		[self.PRIMARY] = "x",
		[self.SECONDARY] = "a",
		[self.TERTIARY] = "y",
		[self.QUATERNARY] = "b",
		[self.MENU] = "start",
		[self.SELECT] = "a"
	}
	self.map_gamepad = self.gamepadBinds_Menu
	Input:reset()
end

--[[ Clear all active inputs
]]
function Input:reset()
	self.current = {
		[self.UP] = false,
		[self.DOWN] = false,
		[self.LEFT] = false,
		[self.RIGHT] = false,
		[self.PRIMARY] = false,
		[self.SECONDARY] = false,
		[self.TERTIARY] = false,
		[self.QUATERNARY] = false,
		[self.MENU] = false,
		[self.SELECT] = false
	}
	self.last = {
		[self.UP] = false,
		[self.DOWN] = false,
		[self.LEFT] = false,
		[self.RIGHT] = false,
		[self.PRIMARY] = false,
		[self.SECONDARY] = false,
		[self.TERTIARY] = false,
		[self.QUATERNARY] = false,
		[self.MENU] = false,
		[self.SELECT] = false
	}
end

--[[ Set gamepad to use Menu bindings
]]
function Input:gamepadBindMenu()
	self.map_gamepad = self.gamepadBinds_Menu
end
--[[ Set gamepad to use Game bindings
]]
function Input:gamepadBindGame()
	self.map_gamepad = self.gamepadBinds_Game
end

--[[ Get the key/control assigned to an input Button
]]
function Input:getBoundControl(Button)
	if self.useGamepad then
		if self.map_gamepad[Button] ~= nil then
			return self.map_gamepad[Button]
		end
	else
		if self.map_keyboard[Button] ~= nil then
			return self.map_keyboard[Button]
		end
	end
	return ""
end

--[[ Returns true if the button is currently pressed
	Button		Button to check (use enums Input.UP, Input.PRIMARY, etc.)
]]
function Input:isPressed(Button)
	return self.current[Button]
end
--[[ Returns true if the button was pressed this frame
	Button		Button to check (use enums Input.UP, Input.PRIMARY, etc.)
]]
function Input:justPressed(Button)
	return (self.current[Button] and not self.last[Button])
end
--[[ Returns true if the button was released this frame
	Button		Button to check (use enums Input.UP, Input.PRIMARY, etc.)
]]
function Input:justReleased(Button)
	return (not self.current[Button] and self.last[Button])
end

--[[ Update input
]]
function Input:update()
	if not self.useGamepad then
		--Keyboard controls
		for i=1, table.getn(self.current) do
			self.last[i] = self.current[i]
			self.current[i] = love.keyboard.isDown(self.map_keyboard[i])
		end
	else
		--Gamepad controls
		for i=1, 4 do
			self.last[i] = self.current[i]
		end
		local hat = self.gamepad:getHat(1)
		self.current[self.UP] = (string.find(hat, "u") ~= nil)
		self.current[self.DOWN] = (string.find(hat, "d") ~= nil)
		self.current[self.LEFT] = (string.find(hat, "l") ~= nil)
		self.current[self.RIGHT] = (string.find(hat, "r") ~= nil)
		
		for i=5, table.getn(self.current) do
			self.last[i] = self.current[i]
			self.current[i] = self.gamepad:isGamepadDown(self.map_gamepad[i])
		end
	end
end

--[[ Handle hardcoded keyboard input (debug, and highscore name entry)
]]
function Input:keypressed(Key)
	if Key == "`" then
		debugText.visible = not debugText.visible
	elseif Key == "p" then
		--Cycle through range of x0 -> x2 speed, .2 increments
		General.timeScale = (General.timeScale + .2) % 2
	elseif Key == "down" then
		debugText.y = debugText.y - 140
	elseif Key == "up" then
		debugText.y = debugText.y + 140
	elseif Key == "-" then
		General.timeScale = General.timeScale - .5
	elseif Key == "=" then
		General.timeScale = General.timeScale + .5
	elseif Key == "b" then
		General.showBounds = not General.showBounds
	elseif self.useGamepad then
		--Switch back to keyboard control if receiving a valid input
		for i=1, table.getn(self.current) do
			if love.keyboard.isDown(self.map_keyboard[i]) then
				self.useGamepad = false
			end
		end
	end
	if GameState.loaded then
		if Key == "i" then
			local player = GameState.player
			player.invuln = not player.invuln
			if player.invuln then
				player.color = {50,50,128}
			else
				player.color = {255,255,255}
			end
		elseif Key == "n" then
			GameState:nextStage()
		end
	elseif NewHighScoreState.loaded then
		if Key == "backspace" then
			NewHighScoreState.name = string.sub(NewHighScoreState.name, 1, string.len(NewHighScoreState.name) - 1)
		else
			if NewHighScoreState.hintCleared == false then
				NewHighScoreState.name = ""
				NewHighScoreState.hintCleared = true
			end

			if Utility:isValidKey(Key) == true then
				NewHighScoreState.name = NewHighScoreState.name .. Key
			end
		end
		NewHighScoreState.name = string.upper(NewHighScoreState.name)
		NewHighScoreState.nameText:setLabel(NewHighScoreState.name)
	end
end

function Input:keyreleased(Key)
	--Empty
end

--[[ Handle gamepad input event, to enable gamepad if currently using keyboard controls
]]
function Input:joystickpressed(Joystick, Button)
	if not self.useGamepad then
		self.useGamepad = true
	end
end
