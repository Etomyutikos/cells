--- Module cells is a text formatting utility.
-- cells uses the concepts of rows, columns, and text to produce structured
-- text output.
-- @module cells

local text = require "text"

--- Table cells exposes the module interface.
-- @table cells
local cells = {
	--- See @{text}.
	text = text
}

return cells
