--- Paused screen state.
PauseState = {
	title = "GAME PAUSED",
	options = {
		"[1]\tResume",
		"[2]\tHigh Scores",
		"[3]\tBrightness",
		"[4]\tVolume",
		"[5]\tQuit"
	}
}
PauseState.__index = PauseState
setmetatable(PauseState, MenuState)

--function PauseState:load()