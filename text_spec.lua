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

describe("given nil", function()
	local input = nil

	it(shouldBeLength(0, text.render(input)))
end)

describe("given an empty string", function()
	local input = ""

	it(shouldBeLength(0, text.render(input)))
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
