local text = require "text"

describe("text", function()
	describe("given nil", function()
		it("should error", function()
			assert.has_error(function() text(nil) end, "invalid input, expected string")
		end)
	end)

	describe("given a non-string", function()
		it("should error", function()
			assert.has_error(function() text({}) end, "invalid input, expected string")
		end)
	end)

	describe("length", function()
		describe("given nil", function()
			it("should error", function()
			   assert.has_error(function() text("").length(nil) end, "invalid input, expected number")
			end)
		end)

		describe("given a non-number", function()
			it("should error", function()
			   assert.has_error(function() text("").length("") end, "invalid input, expected number")
			end)
		end)

		it("should return the text table", function()
			local t = text("")
			local actual = t.length(1)

			assert.are.equal(t, actual)
		end)
	end)

	describe("render", function()
 		local function testRender(input, length, expected)
			describe(string.format("input %q of length %d", input, input:len()), function()
				local t = text(input)

				describe(string.format("and max length of %s", length or "none"), function()
					if length then
						t.length(length)
					end

					it("should return elements matching the input", function()
						local actual = t.render()
						assert.are.same(expected, actual)
					end)
				end)
			end)
		end

		describe("given an empty string", function()
			testRender("", nil, {})
		end)

		describe("given unspaced", function()
			local input = "01234567890123456789012345678901234567890123456789"

			testRender(input, 50, {
				"01234567890123456789012345678901234567890123456789"
			})

			testRender(input, 25, {
				"0123456789012345678901234",
				"5678901234567890123456789"
			})

			testRender(input, nil, {
				"01234567890123456789012345678901234567890123456789"
			})
		end)

		describe("given spaced", function()
			local input = "01234 56789 98765 43210 01234 56789 98765 43210 01"

			testRender(input, 50, {
				"01234 56789 98765 43210 01234 56789 98765 43210 01"
			})

			testRender(input, 25, {
				"01234 56789 98765 43210",
				"01234 56789 98765 43210",
				"01"
			})

			testRender(input, nil, {
				"01234 56789 98765 43210 01234 56789 98765 43210 01"
			})
		end)

		describe("given unspaced then spaced", function()
			local input = "0123456789012345678901234 56789 01234 56789 012345"

			testRender(input, 25, {
				"0123456789012345678901234",
				"56789 01234 56789 012345"
			})

			testRender(input, 20, {
				"01234567890123456789",
				"01234 56789 01234",
				"56789 012345"
			})
		end)

		describe("with spaced then unspaced", function()
			local input = "56789 01234 56789 012345 0123456789012345678901234"

			testRender(input, 25, {
				"56789 01234 56789 012345",
				"0123456789012345678901234"
			})
		end)

		describe("with spaced between unspaced", function()
			local input = "56789 01234 0123456789012345678901234 56789 012345"

			testRender(input, 25, {
				"56789 01234",
				"0123456789012345678901234",
				"56789 012345"
			})
		end)
	end)
end)

-- for _ = 1, 100 do
-- 	local chars = (function()
-- 		local out = {}
-- 		for i = 33, 126 do
-- 			out[#out + 1] = string.char(i)
-- 		end

-- 		for _ = 1, 30 do
-- 			out[#out + 1] = string.char(32) -- space
-- 		end

-- 		return out
-- 	end)()

-- 	describe("randomized testing", function()
-- 		local max = math.random(100)
-- 		local input = (function()
-- 			local out = ""
-- 			for _ = 1, max do
-- 				local char = chars[math.random(#chars)]
-- 				out = string.format("%s%s", out, char)
-- 			end
-- 			return out
-- 		end)()

-- 		describe("render", function()
-- 			local length = math.random(max)
-- 			local actual = text.render(input, length)

-- 			it("should have some content?", function()
-- 				local error = false
-- 			  for _, v in ipairs(actual) do
-- 			  	if v:len() > length then
-- 			  		error = true
-- 			  		print("ERROR: too long")
-- 			  	end

-- 			  	if v:sub(1, 1) == " " then
-- 			  		error = true
-- 			  		print("ERROR: begins with space")
-- 			  	end

-- 			  	if v:sub(-1) == " " then
-- 			  		error = true
-- 			  		print("ERROR: ends with space")
-- 			  	end
-- 			  end

-- 			  if error then
-- 					print(string.format("\ninput (%d): %q", input:len(), input))
-- 					print(string.format("actual (%d): ", length))
-- 					for i, v in ipairs(actual) do
-- 						print(string.format("  %02d: %q", i, v))
-- 					end

-- 					assert.is_true(false)
-- 				end
-- 			end)
-- 		end)
-- 	end)
-- end
