local sequence = {}

-- Decorate onComplete with next transition on this target
-- Adapted from:
-- http://stackoverflow.com/questions/7542357/is-there-a-better-way-of-linking-transitions-in-corona-lua
function sequence:wrap(target, looping, ...)
	local steps = {...}
	for s, step in ipairs(steps) do
		local originalOnComplete = step.onComplete
		local function wrapOnComplete(target)
			if originalOnComplete then
				originalOnComplete(target)
			end
			local nextIndex = (s % #steps) + 1
			if 2 <= nextIndex or looping then
				transition.to(target, steps[nextIndex])
			end
		end
		step.onComplete = wrapOnComplete
	end
end

-- when complete, looping
function sequence:to(target, looping, ...)
	local all_steps = {...}
	sequence:wrap(target, looping, unpack(all_steps))
	local first = all_steps[ 1 ]
	transition.to(target, first)
end

return sequence
