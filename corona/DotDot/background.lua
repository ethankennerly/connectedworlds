local sequence = require "sequence"

local background = {}

-- Anchor copied from Flash position and dimensions.
function background:new()
	background.scene = display.newImage("scene.png", -800, -800)
	background.scene.anchorX = 0.444
	background.scene.anchorY = 0.5005
	background.currentLabel = ""
	return background
end

function background:destroy()
	transition.cancel( background.scene )
	if background.scene and background.scene.parent then
		background.scene:removeSelf()
	end
	background.scene.alpha = 0.0
end

-- Fade in
function background:begin(onComplete)
	background.currentLabel = "begin"
	local startMilliseconds = 3.0 / 30.0 * 1000.0
	local fadeMilliseconds = 60.0 / 30.0 * 1000.0
	local travelMilliseconds = 30.0 / 30.0 * 1000.0
	background.scene.x = 0.0
	background.scene.y = 0.0
	background.scene.alpha = 0.0
	sequence:to(background.scene, false,
		{time = 0, x = 0.0, y = 0.0, alpha = 0.0},
		{time = startMilliseconds},
		{time = fadeMilliseconds, alpha = 1.0},
		{time = travelMilliseconds, x = 0.0, y = 0.0},
		{time = 0.0, onComplete = onComplete})
	return background.scene
end

function background:trial()
	background.currentLabel = "trial"
	local fadeMilliseconds = 8.0 / 30.0 * 1000.0
	background.scene.alpha = 1.0
	transition.to(background.scene, 
		{time = fadeMilliseconds, alpha = 0.0})
end

return background:new()
