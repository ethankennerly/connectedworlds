local sequence = require "sequence"

local prompt = {
	hand = nil,
}

-- Anchor copied from Flash position and dimensions.
function prompt:new()
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
	prompt.hand.alpha = 0.0
end

function prompt:copy(connections)
	local copied = {}
	for c=1,#connections do
		copied[#copied + 1] = {}
		for i=1,#connections[c] do
			copied[#copied][i] = connections[c][i]
		end
	end
	return copied
end

-- DEPRECATED 
function prompt:shuffle(connections)
	local shuffled = prompt:copy(connections)
	for s=#shuffled,1,-1 do
		local r = math.random(s)
		if s ~= r then
			shuffled[s], shuffled[r] = shuffled[r], shuffled[s]
		end
		if math.random() < 0.5 then
			shuffled[s][1], shuffled[s][2] = shuffled[s][2], shuffled[s][1]
		end
	end
	return shuffled
end

function prompt:lines(connections, dots, parent)
	prompt.connections = prompt:copy(connections)
	-- prompt.connections = prompt:shuffle(connections)
	prompt.dots = dots
	prompt.parent = parent
	prompt.connectionIndex = 1
	prompt:nextLine()
end

function prompt:nextLine()
	if #prompt.connections < prompt.connectionIndex then
		prompt.connectionIndex = 1
		-- prompt.connections = prompt:shuffle(prompt.connections)
	end
	local dotIndexes = prompt.connections[prompt.connectionIndex]
	local dot1 = prompt.dots[dotIndexes[1]]
	local dot2 = prompt.dots[dotIndexes[2]]
	local hand = prompt:line(dot1.x, dot1.y, dot2.x, dot2.y)
	prompt.parent:insert(hand)
	prompt.connectionIndex = prompt.connectionIndex + 1
end

-- Prompt delays, fades in, travels, fades out, delays, and repeats.
function prompt:line(x1, y1, x2, y2)
	prompt:destroy()
	prompt:new()
	local startMilliseconds = 80.0 / 30.0 * 1000.0
	local endMilliseconds = 110.0 / 30.0 * 1000.0
	local repeatMilliseconds = 150.0 / 30.0 * 1000.0
	local fadeMilliseconds = 8.0 / 30.0 * 1000.0
	local travelMilliseconds = endMilliseconds - startMilliseconds - fadeMilliseconds
	local postMilliseconds = repeatMilliseconds - endMilliseconds - 2 * fadeMilliseconds
	prompt.hand.x = x1
	prompt.hand.y = y1
	prompt.hand.alpha = 0.0
	sequence:to(prompt.hand, false, 
		{time = 0, x = x1, y = y1, alpha = 0.0},
		{time = startMilliseconds},
		{time = fadeMilliseconds, alpha = 1.0},
		{time = travelMilliseconds, x = x2, y = y2},
		{time = fadeMilliseconds, alpha = 0.0},
		{time = postMilliseconds, onComplete = prompt.nextLine})
	return prompt.hand
end

return prompt:new()
