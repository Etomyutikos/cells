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

local function boxer(ctor)
	assert(type(ctor) == "function", "invalid input, expected function")

	return function(content)
		local renderer = ctor(content)
		assert(renderer.render and type(renderer.render) == "function",
			"invalid return from wrapped constructor, expected renderer")
		assert(renderer.width and type(renderer.width) == "function",
			"invalid return from wrapped constructor, expected renderer")

		local B = {}

		local border
		local margin
		local padding

		function B.border(b)
			assert(type(b) == "string", "invalid input, expected string")
			border = b

			return B
		end

		function B.margin(m)
			assert(type(m) == "string", "invalid input, expected string")
			margin = m

			return B
		end

		function B.padding(p)
			assert(type(p) == "string", "invalid input, expected string")
			padding = p

			return B
		end

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
