local loop = require "loop"

local prompt = {
	hand = nil,
}

function new()
	prompt.hand = display.newImage("hand.png", -400, -400)
	prompt.hand.anchorX = 57.0 / 131.0
	prompt.hand.anchorY = 55.0 / 180.0
	return prompt
end

function prompt:destroy()
	transition.cancel( prompt.hand )
	if prompt.hand and prompt.hand.parent then
		prompt.hand:removeSelf()
	end
end

function prompt:line(x1, y1, x2, y2)
	prompt:destroy()
	new()
	local startMilliseconds = 80.0 / 30.0 * 1000.0
	local endMilliseconds = 110.0 / 30.0 * 1000.0
	local repeatMilliseconds = 150.0 / 30.0 * 1000.0
	prompt.hand.x = x1
	prompt.hand.y = y1
	loop(prompt.hand,  
		{time = 0, x = x1, y = y1},
		{time = startMilliseconds},
		{time = endMilliseconds - startMilliseconds, x = x2, y = y2},
		{time = repeatMilliseconds - endMilliseconds})
	return prompt.hand
end

return new()
