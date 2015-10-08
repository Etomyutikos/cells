--- Module column encapsulates renderers and returns their rendered contents laid
-- out vertically. Width can be specified, which will constain content width.
-- @module column

--- getWidestLine returns the widest line (highest len()) for a table of a
-- table of strings.
-- @table t A table of a table of strings.
-- @treturn number
local function getWidestLine(t)
	local w = 0
	for _, v in ipairs(t) do
		for _, u in ipairs(v) do
			w = math.max(u:len(), w)
		end
	end

	return w
end

--- renderContents calls the render method on all content passed into the column
-- constructor. Will calculate and constrain the width of inner content based
-- on provided width.
-- @table contents A table of a table of strings.
-- @number maxWidth
-- @treturn A table of a table of formatted strings.
local function renderContents(contents, maxWidth)
	local renders = {}
	for i, c in ipairs(contents) do
		if maxWidth then
			c.width(maxWidth)
		end

		local render = c.render()
		assert(type(render) == "table", "invalid return from render, expected table of strings")
		for _, v in ipairs(render) do
			assert(type(v) == "string", "invalid return from render, expected table of strings")
		end

		renders[i] = render
		if maxWidth then
			for j, r in ipairs(renders[i]) do
				if r:len() < maxWidth then
					local fmt = string.format("%%-%ds", maxWidth)
					renders[i][j] = string.format(fmt, r)
				elseif r:len() > maxWidth then
					renders[i][j] = r:sub(1, maxWidth)
				end
			end
		end
	end

	return renders
end

--- column is a constructor for a column object.
-- @table contents A table of objects satisfying an interface consisting of
-- width() and render() methods.
-- @treturn column
local function column(contents)
	assert(type(contents) == "table", "invalid input, expected table")
	for i, v in ipairs(contents) do
		assert(v.render and type(v.render) == "function",
			string.format("invalid input, content %d has no render method", i))
		assert(v.width and type(v.width) == "function",
			string.format("invalid input, content %d has no width method", i))
	end

	--- @type column
	local C = {}

	local width

	--- render processes internal contents and returns a table of formatted
	-- strings.
	-- @treturn table
	function C.render()
		if #contents == 0 then
			return {}
		end

		local lines = {}
		do
			local renders = renderContents(contents, width)
			local w = getWidestLine(renders)
			for _, r in ipairs(renders) do
				local fmt = string.format("%%-%ds", w)

				for _, l in ipairs(r) do
					lines[#lines + 1] = string.format(fmt, l)
				end
			end
		end

		return lines
	end

	--- width sets the width of the column, which will constrain all internal
	-- content.
	-- @number w
	-- @treturn column
	function C.width(w)
		assert(type(w) == "number", "invalid input, expected number")
		width = w

		return C
	end

	return C
end

return column
