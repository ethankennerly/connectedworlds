-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

local model = require "model"
local view = require "view"

function trial()
    model:populate()
    view:populate(model)
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

-- A general function for dragging objects
local function answer( event )
	if down(event) then
        local dot = view:nextDotAt(event.x, event.y)
        if nil == dot then
        else   
            if model.linesVisible then
                model.linesVisible = false
                view:clearLines()
            end
        end
	end

	-- Stop further propagation of touch event!
	return true
end


trial()
display.getCurrentStage():addEventListener("touch", answer)
