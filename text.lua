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

local function render(raw, maxLength)
	assert(type(raw) == "string", "invalid input, expected string")
	if raw == "" then
		return {}
	end

	local s = trim(raw)
	if not maxLength or s:len() <= maxLength then
		return {s}
	end

	return wrap(s, maxLength)
end

return {
	render = render,
}

-- TODO(Erik): local t = text("some string").align("right").render()
-- TODO(Erik): Losing significant whitespace between words in a given line.
