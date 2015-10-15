local cells = require "init"
local column = cells.column
local row = cells.row
local text = cells.text

describe("example", function()
	local page = column({
		column({
		  text("hello from column 1").align("center"),
	  }),
		column({
		  text("hello from column 2"),
	  }).margin(" ").border("-"),
	  column({
	    text("column 3").align("right"),
	    row({
	      text("inner row").align("center"),
	      text(string.rep("this is some really long text that should definitely wrap ", 10)).align("center"),
	      text("some slightly shorter text that should probably still wrap").align("right"),
	      text("squeeze moar txt"),
	      text("teeeext!"),
	      row({
          column({
          	text("text 1"),
          	text("text 4"),
          }).border("1"),
          text("text 2"),
          text("text 3"),
        }),
      }).border("~"),
    }),
    row({
      text("fancy borders").align("right"),
    }).margin("|").border("=").padding(" "),
	}).border("*").padding(" ").width(103)

	print("")
	for _, v in ipairs(page.render()) do
		print(v)
	end
end)
