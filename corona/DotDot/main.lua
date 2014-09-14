display.setStatusBar( display.HiddenStatusBar )

local model = require "model"
local view = require "view"

local main = {}

function main:clear()
    if view then
        view:clear()
    end
end

function main:trial()
    main:clear()
    model:populate()
    view:populate(model)
	view:hintDistractors(model.distractors)
	view:prompt(model.connections[1])
end

function main:trialLoop()
	main:trial()
end

function main:down( event )
	local t = event.target
	local phase = event.phase
    local isDown = false
	if "began" == phase then
		t.isFocus = true
        isDown = true
	elseif t.isFocus then
		if "moved" == phase then
            t.isFocus = true
            isDown = true
		elseif "ended" == phase or "cancelled" == phase then
			t.isFocus = false
        end
    end
    return isDown
end

function main:trialEnd(correct)
    model:trialEnd(correct)
    view:trialEnd()
end

function main:mayListen( event )
	if "began" == event.phase then
		model.listen() 
	end
end

local function answer( event )
	main:mayListen(event)
	if model.listening then
		if main:down(event) then
			local x = event.x
			local y = event.y
			local dot = view:nextDotAt(x, y)
			if nil == dot then
				view:drawProgress(model.to, x, y)
			else   
				if model.linesVisible then
					model.linesVisible = false
					view:clearLines()
				end
				local index = model:answer(dot.x, dot.y)
				local correct = 1 <= index
				view:drawConnection(model.from, model.to, correct)
				if correct then
					if model.complete() then
						main:trialEnd(correct)
					end
				else
					main:trialEnd(correct)
				end
			end
		else
			model:cancel()
			view:cancel()
		end
	end
	-- Stop further propagation of touch event!
	return true
end

function main:new()
	view.onScreenEnd = main.trialLoop
	display.getCurrentStage():addEventListener("touch", answer)
	main:trial()
	return main
end

-- http://thatssopanda.com/corona-sdk-tutorials/using-the-shake-event-with-corona-sdk/
-- Create a function to be called when the phone or mobile device is shaken
local function onShake(event)
    if event.isShake then
        main:trialEnd(true)
    end
end
-- Create a runtime listener for the shake event
Runtime:addEventListener("accelerometer", onShake)

return main:new()
