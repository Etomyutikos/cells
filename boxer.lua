--- Module boxer wraps constructors that return renderers to provide CSS-like
-- box model margin, border, and padding. boxer satisfies the renderer interface
-- so it can be passed into other rows and columns.
-- @module boxer

--- getWidestLine returns the widest line (highest len()) for a table of
-- strings.
-- @table t A table of strings.
-- @treturn number
local function getWidestLine(t)
	local w = 0
	for _, v in ipairs(t) do
		w = math.max(v:len(), w)
	end

	return w
end

--- wrap surrounds a table of strings in a given character. This includes a full
-- bar of c as the first line and last elements of the returned table, as well
-- as identical on each side of each line.
-- @table t A table of strings.
-- @string c The character to wrap the table with.
-- @treturn table
local function wrap(t, c)
	local out = {}

	for i, v in ipairs(t) do
		local s = (function()
			if c:len() == 1 then
				return ""
			end

			return string.rep(" ", v:len() % 2)
		end)()

		out[i] = string.format("%s%s%s%s", c, v, s, c)
	end

	local w = getWidestLine(out)
	table.insert(out, 1, string.rep(c, w / c:len()))
	out[#out+1] = string.rep(c, w / c:len())

	return out
end

--- boxer wraps a ctor for a renderer, adding functionality for rendering box
-- model style margins, borders, and padding. boxer satisfies the renderer
-- interface so it can be used a renderer in rows and columns.
-- @function ctor The wrapped renderer constructor.
-- @treturn boxer
local function boxer(ctor)
	assert(type(ctor) == "function", "invalid input, expected function")

	return function(content)
		local renderer = ctor(content)
		assert(renderer.render and type(renderer.render) == "function",
			"invalid return from wrapped constructor, expected renderer")
		assert(renderer.width and type(renderer.width) == "function",
			"invalid return from wrapped constructor, expected renderer")

		--- @type boxer
		local B = {}

		local border
		local margin
		local padding

		--- border sets the border string to be applied during render.
		-- @string b
		-- @treturn boxer
		function B.border(b)
			assert(type(b) == "string", "invalid input, expected string")
			border = b

			return B
		end

		--- margin sets the margin string to be applied during render.
		-- @string m
		-- @treturn boxer
		function B.margin(m)
			assert(type(m) == "string", "invalid input, expected string")
			margin = m

			return B
		end

		--- padding sets the padding string to be applied during render.
		-- @string p
		-- @treturn boxer
		function B.padding(p)
			assert(type(p) == "string", "invalid input, expected string")
			padding = p

			return B
		end

		--- render wraps the output of the embedded renderer in strings as given by
		-- the border, margin, and padding fields.
		-- @treturn table
		function B.render()
			local r = renderer.render()

			-- add these inside out
			if padding then
				r = wrap(r, padding)
			end

			if border then
				r = wrap(r, border)
			end

			if margin then
				r = wrap(r, margin)
			end

			return r
		end

		--- width calculates the width of the inner content based on the length of
		-- the border, margin, and padding previously given. This width gets set as
		-- the width of the wrapped renderer.
		-- @number w
		-- @treturn boxer
		function B.width(w)
			local mw = margin and margin:len() or 0
			local bw = border and border:len() or 0
			local pw = padding and padding:len() or 0
			w = w - (mw + bw + pw)
			renderer.width(w)

			return B
		end

		return B
	end
end

return boxer
