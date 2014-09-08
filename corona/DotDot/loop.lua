-- Decorate onComplete with next transition on this target
-- Adapted from:
-- http://stackoverflow.com/questions/7542357/is-there-a-better-way-of-linking-transitions-in-corona-lua
local function sequence(target, ...)
	local steps = {...}
	for s, step in ipairs(steps) do
		local originalOnComplete = step.onComplete
		step.onComplete = function(target)
			if originalOnComplete then
				originalOnComplete(target)
			end
			local nextIndex = (s % #steps) + 1
			transition.to(target, steps[nextIndex])
		end
	end
end

-- when complete, repeat
local function new(target, ...)
	local all_steps = {...}
	sequence(target, unpack(all_steps))
	local first = all_steps[ 1 ]
	transition.to(target, first)
end

return new
