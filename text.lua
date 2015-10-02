-- http://lua-users.org/wiki/SplitJoin (string.gsplit)
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

-- http://lua-users.org/wiki/StringTrim (trim6)
local function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

local function wrap(s, maxLength)
	s = trim(s)

	if s == "" then
		return {}
	end

	if not maxLength or s:len() <= maxLength then
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
		if wlen >= maxLength then
			-- may need to split multiple times
			for i = 1, wlen - 1, maxLength do
				local wsub = w:sub(i, i + maxLength - 1)
				if wsub:len() == maxLength then
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
			if added:len() <= maxLength then
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

local function getFormatFn(align, length)
	if align == "left" then
		return function()
			return string.format("%%-%ds", length)
		end
	elseif align == "right" then
		return function()
			return string.format("%%%ds", length)
		end
	elseif align == "center" then
		return function(line)
			local space = length - line:len()
			local left = math.floor(space / 2) + (space % 2)
			local right = math.floor(space / 2)

			return string.format("%s%%s%s", string.rep(" ", left), string.rep(" ", right))
		end
	end
end

local function text(raw)
	assert(type(raw) == "string", "invalid input, expected string")
	local T = {}

  local align
	local maxLength

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

	function T.length(l)
		assert(type(l) == "number", "invalid input, expected number")
		maxLength = l

		return T
	end

	function T.render()
		local lines = wrap(raw, maxLength)

		if not align or not maxLength then
			return lines
		end

		local formatFn = getFormatFn(align, maxLength)
		for i, v in ipairs(lines) do
			lines[i] = string.format(formatFn(v), v)
		end

		return lines
	end

	return T
end

return text
