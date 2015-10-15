# cells

A Lua module to format text in a grid. `cells` exposes constructors for `row`s, `column`s, and `text`s. By composing these three concepts, it's possible to express a wide variety of layouts.

A `text` object accepts as input a string. That string can be returned wrapped to a certain width. In addition, the rendered string can be returned aligned either "left", "right", or "center". If an alignment is specified, the strings returned will be padded to conform to width expectations.

A `row` arranges all inner content horizontally, whereas a `column` arranges all inner content vertically. Both `row`s and `column`s will grow horizontally until all inner content is rendered, but their widths can be specified. `row`s and `column`s accept as input a table of `text`s, `row`s, and `column`s.

In addition, `row`s and `column`s can have single characters set as (from the outside-in) margin, border, and padding.

# Example
Script:

```lua
local cells = require "init"
local column = cells.column
local row = cells.row
local text = cells.text

local lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. " ..
	"Eligendi non quis exercitationem culpa nesciunt nihil aut nostrum " ..
	"explicabo reprehenderit optio amet ab temporibus asperiores quasi " ..
	"cupiditate. Voluptatum ducimus voluptates voluptas?"

local page = column({
	column({
		text("cells").align("center"),
		text("text formatting Lua module").align("center"),
	}),
	row({
		column({
			text("column header 1").align("center"),
			column({
				text(lorem)
			}).padding(" "),
		}).border("."),
		column({
			text("column header 2").align("center"),
			column({
				text(lorem).align("right"),
				text(lorem).align("right"),
			}).padding(" "),
		}).border("."),
	}),
	row({
		text(lorem),
		text(lorem),
		text(lorem),
		text(lorem),
	}).margin(" ").border(".").padding("="),
}).border("*").width(80)

print("")
for _, v in ipairs(page.render()) do
	print(v)
end
```

Outputs:

```
********************************************************************************
*                                     cells                                    *
*                          text formatting Lua module                          *
*..............................................................................*
*.           column header 1           ..           column header 2           .*
*.                                     ..                                     .*
*. Lorem ipsum dolor sit amet,         ..         Lorem ipsum dolor sit amet, .*
*. consectetur adipisicing elit.       ..       consectetur adipisicing elit. .*
*. Eligendi non quis exercitationem    ..    Eligendi non quis exercitationem .*
*. culpa nesciunt nihil aut nostrum    ..    culpa nesciunt nihil aut nostrum .*
*. explicabo reprehenderit optio amet  ..  explicabo reprehenderit optio amet .*
*. ab temporibus asperiores quasi      ..      ab temporibus asperiores quasi .*
*. cupiditate. Voluptatum ducimus      ..      cupiditate. Voluptatum ducimus .*
*. voluptates voluptas?                ..                voluptates voluptas? .*
*.                                     ..         Lorem ipsum dolor sit amet, .*
*........................................       consectetur adipisicing elit. .*
*                                       .    Eligendi non quis exercitationem .*
*                                       .    culpa nesciunt nihil aut nostrum .*
*                                       .  explicabo reprehenderit optio amet .*
*                                       .      ab temporibus asperiores quasi .*
*                                       .      cupiditate. Voluptatum ducimus .*
*                                       .                voluptates voluptas? .*
*                                       .                                     .*
*                                       .......................................*
*                                                                              *
* ............................................................................ *
* .==========================================================================. *
* .=Lorem ipsum dolor Lorem ipsum dolor Lorem ipsum dolor Lorem ipsum dolor =. *
* .=sit amet,         sit amet,         sit amet,         sit amet,         =. *
* .=consectetur       consectetur       consectetur       consectetur       =. *
* .=adipisicing elit. adipisicing elit. adipisicing elit. adipisicing elit. =. *
* .=Eligendi non quis Eligendi non quis Eligendi non quis Eligendi non quis =. *
* .=exercitationem    exercitationem    exercitationem    exercitationem    =. *
* .=culpa nesciunt    culpa nesciunt    culpa nesciunt    culpa nesciunt    =. *
* .=nihil aut nostrum nihil aut nostrum nihil aut nostrum nihil aut nostrum =. *
* .=explicabo         explicabo         explicabo         explicabo         =. *
* .=reprehenderit     reprehenderit     reprehenderit     reprehenderit     =. *
* .=optio amet ab     optio amet ab     optio amet ab     optio amet ab     =. *
* .=temporibus        temporibus        temporibus        temporibus        =. *
* .=asperiores quasi  asperiores quasi  asperiores quasi  asperiores quasi  =. *
* .=cupiditate.       cupiditate.       cupiditate.       cupiditate.       =. *
* .=Voluptatum ducimusVoluptatum ducimusVoluptatum ducimusVoluptatum ducimus=. *
* .=voluptates        voluptates        voluptates        voluptates        =. *
* .=voluptas?         voluptas?         voluptas?         voluptas?         =. *
* .==========================================================================. *
* ............................................................................ *
*                                                                              *
********************************************************************************
```

# TODO
* Improve error messages, so they return more useful user information, like stack traces or user script line numbers.
* When setting `boxer` margin, border, and padding, width should be updated.
