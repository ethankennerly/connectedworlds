-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

local graphs = require "graphs"
local view = require "view"

function trial()
    view:populate()
end

trial()
