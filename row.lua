local function getWidestLine(t)
	local w = 0
	for _, v in ipairs(t) do
		if v:len() > w then
			w = v:len()
		end
	end

	return w
end

local function row(content)
	assert(type(content) == "table", "invalid input, expected table")
	for i, v in ipairs(content) do
		assert(v.render and type(v.render) == "function",
			string.format("invalid input, content %d has no render method", i))
		assert(v.width and type(v.width) == "function",
			string.format("invalid input, content %d has no width method", i))
	end

	local R = {}

	local width

	function R.render()
		if #content == 0 then
			return {}
		end

		local lines = {}
		do
			local renders = {}
			for i, v in ipairs(content) do
				renders[i] = v.render()
			end

			local r = 1

			while true do
				local misses = 0
				for _, v in ipairs(renders) do
					local lineWidth = getWidestLine(v)

					if v[r] then
						local format = string.format("%%-%ds", lineWidth)
						lines[r] = string.format("%s%s", lines[r] or "", string.format(format, v[r]))
					else
						lines[r] = string.format("%s%s", lines[r] or "", string.rep(" ", lineWidth))
						misses = misses + 1
					end
				end

				r = r + 1

				if misses == #renders then
					break
				end
			end

			if not lines[#lines]:find("%S") then
				table.remove(lines, #lines)
			end
		end

		return lines
	end

	function R.width(w)
		assert(type(w) == "number", "invalid input, expected number")
		width = w

		return R
	end

	return R
end

return row
