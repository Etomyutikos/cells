local function getWidestLine(t)
	local w = 0
	for _, v in ipairs(t) do
		if v:len() > w then
			w = v:len()
		end
	end

	return w
end

local function renderContents(contents, maxWidth)
	local width = (maxWidth and math.floor(maxWidth / #contents))
	local rem = (width and maxWidth % width)

	local renders = {}
	for i, c in ipairs(contents) do
		if width then
			local w = width
			if rem > 0 then
				w = w + 1
				rem = rem - 1
			end

			c.width(w)
		end

		renders[i] = c.render()
		if width then
			for j, r in ipairs(renders[i]) do
				if r:len() < width then
					local fmt = string.format("%%-%ds", width)
					renders[i][j] = string.format(fmt, r)
				elseif r:len() > width then
					renders[i][j] = r:sub(1, width)
				end
			end
		end
	end

	return renders
end

local function row(contents)
	assert(type(contents) == "table", "invalid input, expected table")
	for i, v in ipairs(contents) do
		assert(v.render and type(v.render) == "function",
			string.format("invalid input, content %d has no render method", i))
		assert(v.width and type(v.width) == "function",
			string.format("invalid input, content %d has no width method", i))
	end

	local R = {}

	local width

	function R.render()
		if #contents == 0 then
			return {}
		end

		local lines = {}
		do
			local renders = renderContents(contents, width)
			local i = 1

			while true do
				local misses = 0

				for _, r in ipairs(renders) do
					local w = getWidestLine(r)

					if r[i] then
						local fmt = string.format("%%-%ds", w)
						lines[i] = string.format("%s%s", lines[i] or "", string.format(fmt, r[i]))
					else
						lines[i] = string.format("%s%s", lines[i] or "", string.rep(" ", w))
						misses = misses + 1
					end
				end

				i = i + 1

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
