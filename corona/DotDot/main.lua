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


-- A general function for dragging objects
local function answer( event )
	local t = event.target
	local phase = event.phase

	if "began" == phase then
		display.getCurrentStage():setFocus( t )
		t.isFocus = true

		-- event.x
		-- event.y
        if model.linesVisible then
            model.linesVisible = false
            view:clearLines()
        end
	elseif t.isFocus then
		if "moved" == phase then
            -- event.x
            -- event.y
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
		end
	end

	-- Stop further propagation of touch event!
	return true
end


trial()
display.getCurrentStage():addEventListener("touch", answer)
