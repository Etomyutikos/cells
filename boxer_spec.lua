local boxer = require "boxer"

describe("boxer", function()
	describe("given nil", function()
		it("should error", function()
			assert.has_error(function() boxer(nil) end, "invalid input, expected function")
		end)
	end)

	describe("given non-function", function()
		it("should error", function()
			assert.has_error(function() boxer("") end, "invalid input, expected function")
		end)
	end)

	describe("when constructing", function()
		describe("given function that does not return table", function()
			local badFn = function()
				return ""
			end

			local b = boxer(badFn)

			it("should error", function()
				assert.has_error(function() b("") end, "invalid return from wrapped constructor, expected renderer")
			end)
		end)

		describe("given function that returns table that does not satisfy interface", function()
			local badFn = function()
				return {}
			end

			local b = boxer(badFn)

			it("should error", function()
				assert.has_error(function() b("") end, "invalid return from wrapped constructor, expected renderer")
			end)
		end)

		it("should call wrapped constructor", function()
			local called = false
			boxer(function()
				called = true
				return {
					render = function() end,
					width = function() end,
				}
			end)({""})

			assert.is_true(called)
		end)
	end)

	local mock = {
		render = function() end,
		width = function() end
	}
	local boxed = boxer(function() return mock end)

	describe("border", function()
		local b = boxed({""})

		describe("given nil", function()
			it("should error", function()
				assert.has_error(function() b.border(nil) end, "invalid input, expected string")
			end)
		end)

		describe("given a non-string", function()
			it("should error", function()
				assert.has_error(function() b.border(nil) end, "invalid input, expected string")
			end)
		end)

		describe("given string with len greater than 1", function()
			it("should error", function()
				assert.has_error(function() b.border("  ") end, "invalid input, expected single character")
			end)
		end)

		describe("should return boxed", function()
			local actual = b.border(" ")

			assert.are.same(b, actual)
		end)
	end)

	describe("margin", function()
		local b = boxed({""})

		describe("given nil", function()
			it("should error", function()
				assert.has_error(function() b.margin(nil) end, "invalid input, expected string")
			end)
		end)

		describe("given a non-string", function()
			it("should error", function()
				assert.has_error(function() b.margin(nil) end, "invalid input, expected string")
			end)
		end)

		describe("given string with len greater than 1", function()
			it("should error", function()
				assert.has_error(function() b.margin("  ") end, "invalid input, expected single character")
			end)
		end)

		describe("should return boxed", function()
			local actual = b.margin(" ")

			assert.are.same(b, actual)
		end)
	end)

	describe("padding", function()
		local b = boxed({""})

		describe("given nil", function()
			it("should error", function()
				assert.has_error(function() b.padding(nil) end, "invalid input, expected string")
			end)
		end)

		describe("given a non-string", function()
			it("should error", function()
				assert.has_error(function() b.padding(nil) end, "invalid input, expected string")
			end)
		end)

		describe("given string with len greater than 1", function()
			it("should error", function()
				assert.has_error(function() b.padding("  ") end, "invalid input, expected single character")
			end)
		end)

		describe("should return boxed", function()
			local actual = b.padding(" ")

			assert.are.same(b, actual)
		end)
	end)

	describe("render", function()
		mock.render = function()
			return {"abcdef"}
		end

		describe("without margin/border/padding", function()
			it("should return renderer output unchanged", function()
				local expected = {"abcdef"}
				local actual = boxed({""}).render()

				assert.are.same(expected, actual)
			end)
		end)

		describe("with", function()
			describe("margin", function()
				local b = boxed({""}).margin("*")

				it("should return renderer wrapped in margin", function()
					local expected = {
						"********",
						"*abcdef*",
						"********",
					}
					local actual = b.render()

					assert.are.same(expected, actual)
				end)
			end)

			describe("border", function()
				local b = boxed({""}).border("*")

				it("should return renderer wrapped in border", function()
					local expected = {
						"********",
						"*abcdef*",
						"********",
					}
					local actual = b.render()

					assert.are.same(expected, actual)
				end)
			end)

			describe("padding", function()
				local b = boxed({""}).padding("*")

				it("should return renderer wrapped in padding", function()
					local expected = {
						"********",
						"*abcdef*",
						"********",
					}
					local actual = b.render()

					assert.are.same(expected, actual)
				end)
			end)

			describe("margin and border and padding", function()
				local b = boxed({""})
					.margin("*")
					.border("-")
					.padding("=")

				it("should return renderer wrapped in margin and border and padding", function()
					local expected = {
						"************",
						"*----------*",
						"*-========-*",
						"*-=abcdef=-*",
						"*-========-*",
						"*----------*",
						"************",
					}
					local actual = b.render()

					assert.are.same(expected, actual)
				end)
			end)
		end)
	end)

	describe("width", function()
		describe("without margin/border/padding", function()
			local b = boxed({""})

			it("should call renderer width", function()
				local expected = 1
				local actual
				mock.width = function(w)
					actual = w
				end

				b.width(1)

				assert.are.equal(expected, actual)
			end)
		end)

		describe("with", function()
			describe("margin", function()
				local b = boxed({""}).margin(" ")

				it("should call renderer width subtracting margin width", function()
					local expected = 8
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(10)

					assert.are.equal(expected, actual)
				end)

				it("should error when renderer width reduced to 0", function()
					assert.has_error(function() b.width(2) end, "inner renderer width reduced to 0 or less")
				end)
			end)

			describe("border", function()
				local b = boxed({""}).border(" ")

				it("should call renderer with width substracting border width", function()
					local expected = 8
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(10)

					assert.are.equal(expected, actual)
				end)

				it("should error when renderer width reduced to 0", function()
					assert.has_error(function() b.width(2) end, "inner renderer width reduced to 0 or less")
				end)
			end)

			describe("padding", function()
				local b = boxed({""}).padding(" ")

				it("should call renderer with width substracting padding width", function()
					local expected = 8
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(10)

					assert.are.equal(expected, actual)
				end)

				it("should error when renderer width reduced to 0", function()
					assert.has_error(function() b.width(2) end, "inner renderer width reduced to 0 or less")
				end)
			end)

			describe("margin and border and padding", function()
				local b = boxed({""})
					.margin(" ")
					.border(" ")
					.padding(" ")

				it("should call renderer with width substracting margin and border and padding widths", function()
					local expected = 4
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(10)

					assert.are.equal(expected, actual)
				end)

				it("should error when renderer width reduced to 0", function()
					assert.has_error(function() b.width(6) end, "inner renderer width reduced to 0 or less")
				end)
			end)
		end)

		it("should return the boxed table", function()
			local b = boxed({""})
			local actual = b.width(1)

			assert.are.equal(b, actual)
		end)
	end)
end)
