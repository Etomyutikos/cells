--- Module text returns a factory function for creating a text wrapper.
-- The text wrapper provides a simple interface for wrapping and padding text
-- within a given width.
-- @module text

--- getFormatFn returns a format string factory function.
-- The function returned may take in an output line so it may construct the
-- final format string.
-- @treturn function
local function getFormatFn(align, width)
	if align == "left" then
		return function()
			return string.format("%%-%ds", width)
		end
	elseif align == "right" then
		return function()
			return string.format("%%%ds", width)
		end
	elseif align == "center" then
		return function(line)
			local space = width - line:len()
			local left = math.floor(space / 2) + (space % 2)
			local right = math.floor(space / 2)

			return string.format("%s%%s%s", string.rep(" ", left), string.rep(" ", right))
		end
	end
end

--- gsplit returns an iterator that iterates over the words in a string.
-- See: http://lua-users.org/wiki/SplitJoin (string.gsplit)
-- @string s The string to be split.
-- @string sep Word delimiter.
-- @treturn function
local function gsplit(s, sep, plain)
	local start = 1
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = s:sub(start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return s:sub(start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return s end
		return pass(s:find(sep, start, plain))
	end
end

--- trim removes whitespace from the beginning and end of a string.
-- @string s The string to be trimmed.
-- See: http://lua-users.org/wiki/StringTrim (trim6)
-- @treturn string
local function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

local function wrap(s, maxWidth)
	s = trim(s)

	if s == "" then
		return {}
	end

	if not maxWidth or s:len() <= maxWidth then
		return {s}
	end

	local out = {}
	local sub = ""

	local function flush(w)
		if trim(sub) ~= "" then
			out[#out + 1] = sub
			sub = w or ""
		end
	end

	for w in gsplit(s, " ") do
		local wlen = w:len()

		-- we need to split the word
		if wlen >= maxWidth then
			-- may need to split multiple times
			for i = 1, wlen - 1, maxWidth do
				local wsub = w:sub(i, i + maxWidth - 1)
				if wsub:len() == maxWidth then
					-- if we had a line in progress, flush it
					flush()

					out[#out + 1] = wsub
				else
					sub = wsub
					break
				end
			end
		else
			-- word may or may not fit the current line
			local added = trim(string.format("%s %s", sub, w))
			if added:len() <= maxWidth then
				-- fits
				sub = added
			else
				-- doesn't fit
				flush(w)
			end
		end
	end

	flush()
	return out
end

--- text is a constructor for a text object.
-- @string raw The string the text object wraps.
-- @treturn text
local function text(raw)
	assert(type(raw) == "string", "invalid input, expected string")

	--- @type text
	local T = {}

  local align
	local width

	--- align sets padding within rendered output.
	-- @string a Must be "left", "right", or "center".
	-- @treturn text
	function T.align(a)
		assert(type(a) == "string", "invalid input, expected left, right, or center")
		local aligns = {
			left = true,
			right = true,
			center = true,
		}
		assert(aligns[a], "invalid input, expected left, right, or center")

		align = a

		return T
	end

	--- render processes the raw string and returns in formatted according to
	-- width and align settings. Formatted text is returned as elements in a
	-- table to ease user consumption.
	-- @treturn table
	function T.render()
		local lines = wrap(raw, width)

		if not align or not width then
			return lines
		end

		local formatFn = getFormatFn(align, width)
		for i, v in ipairs(lines) do
			lines[i] = string.format(formatFn(v), v)
		end

		return lines
	end

	--- width sets maximum width for rendered output.
	-- @number w
	-- @treturn text
	function T.width(w)
		assert(type(w) == "number", "invalid input, expected number")
		width = w

		return T
	end

	return T
end

return text
