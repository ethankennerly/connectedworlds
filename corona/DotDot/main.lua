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

trial()
