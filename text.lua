-- http://lua-users.org/wiki/StringTrim (trim6)
local function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

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

local function render(raw, maxLength)
	if not raw or raw == "" then
		return {}
	end

	maxLength = maxLength or 80

	local s = trim(raw)
	if s:len() <= maxLength then
		return {s}
	end

	local out = {}

	do
		local sub = ""
		for w in gsplit(s, " ") do
			if w:len() >= maxLength then
				local i = 1
				while i < w:len() do
					local wsub = w:sub(i, i + maxLength - 1)
					if wsub:len() == maxLength then
						if trim(sub) ~= "" then
							out[#out + 1] = sub
							sub = ""
						end

						out[#out + 1] = wsub
						i = i + maxLength
					else
						sub = trim(string.format("%s %s", sub, wsub))
					end
				end
			else
				local added = trim(string.format("%s %s", sub, w))
				if added:len() > maxLength then
					out[#out + 1] = sub
					sub = w
				else
					sub = added
				end
			end
		end

		if trim(sub) ~= "" then
			out[#out + 1] = sub
		end
	end

	return out
end

return {
	render = render,
}

-- TODO(Erik): local t = text("some string").align("right").render()
