display.setStatusBar( display.HiddenStatusBar )

local model = require "model"
local view = require "view"

function clear()
    if view then
        view:clear()
    end
end

function trial()
    clear()
    model:populate()
    view:populate(model)
	view:prompt(model.connections[1])
end

local function down( event )
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

local function trialEnd(correct)
    model:trialEnd(correct)
    view:cancel()
    trial()
end

local function mayListen( event )
	if "began" == event.phase then
		model.listen() 
	end
end

local function answer( event )
	mayListen(event)
	if model.listening then
		if down(event) then
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
						trialEnd(correct)
					end
				else
					trialEnd(correct)
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

trial()
display.getCurrentStage():addEventListener("touch", answer)
