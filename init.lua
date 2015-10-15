--- Module cells is a text formatting utility.
-- cells uses the concepts of rows, columns, and text to produce structured
-- text output.
-- @module cells

local boxer = require "boxer"
local column = require "column"
local row = require "row"
local text = require "text"

--- Table cells exposes the module interface.
-- @table cells
local cells = {
	--- See @{column}, @{boxer}
	column = boxer(column),

	--- See @{row}, @{boxer}
	row = boxer(row),

	--- See @{text}.
	text = text
}

return cells
