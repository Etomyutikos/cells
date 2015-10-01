local text = require "text"

local function shouldBeTable(t)
	return "should return a table", function()
		assert.are.equal("table", type(t))
	end
end

local function shouldBeLength(l, t)
	local plural = l ~= 1 and "s" or ""
	return string.format("should return %d line%s", l, plural), function()
		assert.are.equal(l, #t)
	end
end

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
-- 				print(string.format("\ninput (%d): %q", input:len(), input))
-- 				print(string.format("actual (%d): ", length))
-- 				for i, v in ipairs(actual) do
-- 					print(string.format("  %02d: %q", i, v))
-- 				end
-- 			end)
-- 		end)
-- 	end)
-- end

--[[
input (57): "Xt  6F GFo\"T.N @ ?shN C aV/  ,@Yy0pXk $ 6 gVLd>ak\"  - \\@Y"
actual (49):
  1: "Xt 6F GFo\"T.N @ ?shN C aV/ ,@Yy0pXk $ 6 gVLd>ak\""
  2: "- \\@Y"
]]

describe("given an empty string", function()
	local input = ""

	describe("render", function()
		local actual = text.render(input)

		it(shouldBeLength(0, actual))
	end)
end)

describe("given nil", function()
	describe("render", function()
		it("should error", function()
		   assert.has_error(function() text.render() end, "invalid input, expected string")
		end)
	end)
end)

describe("given a non-string", function()
	describe("render", function()
		it("should error", function()
		   assert.has_error(function() text.render({}) end, "invalid input, expected string")
		end)
	end)
end)

describe("given text", function()
	describe("with unspaced content of length 50", function()
		local input = "01234567890123456789012345678901234567890123456789"

		describe("and max length of 50", function()
			local length = 50

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(1, actual))

				it("should return element that matches the input", function()
					assert.are.equal(input, actual[1])
				end)
			end)
		end)

		describe("and max length of 25", function()
			local length = 25

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(2, actual))

				it("should return elements that match the input", function()
					local first = "0123456789012345678901234"
					assert.are.equal(first, actual[1])

					local second = "5678901234567890123456789"
					assert.are.equal(second, actual[2])
				end)
			end)
		end)

		describe("without a max length", function()
			describe("render", function()
				local actual = text.render(input)

				it(shouldBeTable(actual))
				it(shouldBeLength(1, actual))

				it("should return element that matches the input", function()
					assert.are.equal(input, actual[1])
				end)
			end)
		end)
	end)

	describe("with spaced content of length 50", function()
		local input = "01234 56789 98765 43210 01234 56789 98765 43210 01"

		describe("and max length of 50", function()
			local length = 50

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(1, actual))

				it("should return element that matches the input", function()
					assert.are.equal(input, actual[1])
				end)
			end)
		end)

		describe("and max length of 25", function()
			local length = 25

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(3, actual))

				it("should return elements that match the input", function()
					local first = "01234 56789 98765 43210"
					assert.are.equal(first, actual[1])

					local second = "01234 56789 98765 43210"
					assert.are.equal(second, actual[2])

					local third = "01"
					assert.are.equal(third, actual[3])
				end)
			end)
		end)

		describe("without a max length", function()
			describe("render", function()
				local actual = text.render(input)

				it(shouldBeTable(actual))
				it(shouldBeLength(1, actual))

				it("should return element that matches the input", function()
					assert.are.equal(input, actual[1])
				end)
			end)
		end)
	end)

	describe("with unspaced content then spaced content of length 50", function()
		local input = "0123456789012345678901234 56789 01234 56789 012345"

		describe("and max length of 25", function()
			local length = 25

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(2, actual))

				it("should return elements that match the input", function()
					local first = "0123456789012345678901234"
					assert.are.equal(first, actual[1])

					local second = "56789 01234 56789 012345"
					assert.are.equal(second, actual[2])
				end)
			end)
		end)

		describe("and max length of 20", function()
			local length = 20

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(3, actual))

				it("should elements that match the input", function()
				   local first = "01234567890123456789"
				   assert.are.equal(first, actual[1])

				   local second = "01234 56789 01234"
				   assert.are.equal(second, actual[2])

				   local third = "56789 012345"
				   assert.are.equal(third, actual[3])
				end)
			end)
		end)
	end)

	describe("with spaced content then unspaced content of length 50", function()
		local input = "56789 01234 56789 012345 0123456789012345678901234"

		describe("and max length of 25", function()
			local length = 25

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(2, actual))

				it("should return elements that match the input", function()
					local first = "56789 01234 56789 012345"
					assert.are.equal(first, actual[1])

					local second = "0123456789012345678901234"
					assert.are.equal(second, actual[2])
				end)
			end)
		end)
	end)

	describe("with spaced content between unspaced content of length 50", function()
		local input = "56789 01234 0123456789012345678901234 56789 012345"

		describe("and max length of 25", function()
			local length = 25

			describe("render", function()
				local actual = text.render(input, length)

				it(shouldBeTable(actual))
				it(shouldBeLength(3, actual))

				it("should return elements that match the input", function()
					local first = "56789 01234"
					assert.are.equal(first, actual[1])

					local second = "0123456789012345678901234"
					assert.are.equal(second, actual[2])

					local third = "56789 012345"
					assert.are.equal(third, actual[3])
				end)
			end)
		end)
	end)
end)
