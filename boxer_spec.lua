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

		describe("should return boxed", function()
			local actual = b.border("")

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

		describe("should return boxed", function()
			local actual = b.margin("")

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

		describe("should return boxed", function()
			local actual = b.padding("")

			assert.are.same(b, actual)
		end)
	end)

	describe("render", function()
		describe("without margin/border/padding", function()
			mock.render = function()
				return {"abcdef"}
			end

			it("should return renderer output unchanged", function()
				local expected = {"abcdef"}
				local actual = boxed({""}).render()

				assert.are.same(expected, actual)
			end)
		end)

		describe("with even renderer output", function()
			mock.render = function()
				return {"abcdef"}
			end

			describe("with single", function()
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

		describe("with odd renderer output", function()
			mock.render = function()
				return {"abcde"}
			end

			describe("with single", function()
				describe("margin", function()
					local b = boxed({""}).margin("*")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"*******",
							"*abcde*",
							"*******",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("border", function()
					local b = boxed({""}).border("*")

					it("should return renderer wrapped in border", function()
						local expected = {
							"*******",
							"*abcde*",
							"*******",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("padding", function()
					local b = boxed({""}).padding("*")

					it("should return renderer wrapped in padding", function()
						local expected = {
							"*******",
							"*abcde*",
							"*******",
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
							"***********",
							"*---------*",
							"*-=======-*",
							"*-=abcde=-*",
							"*-=======-*",
							"*---------*",
							"***********",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)
		end)

		describe("with even renderer output", function()
			mock.render = function()
				return {"abcdef"}
			end

			describe("with even", function()
				describe("margin", function()
					local b = boxed({""}).margin("12")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"1212121212",
							"12abcdef12",
							"1212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("border", function()
					local b = boxed({""}).border("12")

					it("should return renderer wrapped in border", function()
						local expected = {
							"1212121212",
							"12abcdef12",
							"1212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("padding", function()
					local b = boxed({""}).padding("12")

					it("should return renderer wrapped in padding", function()
						local expected = {
							"1212121212",
							"12abcdef12",
							"1212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("margin and border and padding", function()
					local b = boxed({""})
						.margin("12")
						.border("34")
						.padding("56")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"121212121212121212",
							"123434343434343412",
							"123456565656563412",
							"123456abcdef563412",
							"123456565656563412",
							"123434343434343412",
							"121212121212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)

			describe("with odd", function()
				describe("margin", function()
					local b = boxed({""}).margin("123")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"123123123123",
							"123abcdef123",
							"123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("border", function()
					local b = boxed({""}).border("123")

					it("should return renderer wrapped in border", function()
						local expected = {
							"123123123123",
							"123abcdef123",
							"123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("padding", function()
					local b = boxed({""}).padding("123")

					it("should return renderer wrapped in padding", function()
						local expected = {
							"123123123123",
							"123abcdef123",
							"123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("margin and border and padding", function()
					local b = boxed({""})
						.margin("123")
						.border("456")
						.padding("789")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"123123123123123123123123",
							"123456456456456456456123",
							"123456789789789789456123",
							"123456789abcdef789456123",
							"123456789789789789456123",
							"123456456456456456456123",
							"123123123123123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)
		end)

		describe("with odd renderer output", function()
			mock.render = function()
				return {"abcde"}
			end

			describe("with even", function()
				describe("margin", function()
					local b = boxed({""}).margin("12")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"1212121212",
							"12abcde 12",
							"1212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("border", function()
					local b = boxed({""}).border("12")

					it("should return renderer wrapped in border", function()
						local expected = {
							"1212121212",
							"12abcde 12",
							"1212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("padding", function()
					local b = boxed({""}).padding("12")

					it("should return renderer wrapped in padding", function()
						local expected = {
							"1212121212",
							"12abcde 12",
							"1212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("margin and border and padding", function()
					local b = boxed({""})
						.margin("12")
						.border("34")
						.padding("56")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"121212121212121212",
							"123434343434343412",
							"123456565656563412",
							"123456abcde 563412",
							"123456565656563412",
							"123434343434343412",
							"121212121212121212",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)

			describe("with odd", function()
				describe("margin", function()
					local b = boxed({""}).margin("123")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"123123123123",
							"123abcde 123",
							"123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("border", function()
					local b = boxed({""}).border("123")

					it("should return renderer wrapped in border", function()
						local expected = {
							"123123123123",
							"123abcde 123",
							"123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("padding", function()
					local b = boxed({""}).padding("123")

					it("should return renderer wrapped in padding", function()
						local expected = {
							"123123123123",
							"123abcde 123",
							"123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("margin and border and padding", function()
					local b = boxed({""})
						.margin("123")
						.border("456")
						.padding("789")

					it("should return renderer wrapped in margin", function()
						local expected = {
							"123123123123123123123123",
							"123456456456456456456123",
							"123456789789789789456123",
							"123456789abcde 789456123",
							"123456789789789789456123",
							"123456456456456456456123",
							"123123123123123123123123",
						}
						local actual = b.render()

						assert.are.same(expected, actual)
					end)
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

		describe("with multiple", function()
			describe("margin", function()
				local b = boxed({""}).margin("12")

				it("should call renderer width subtracting margin width", function()
					local expected = 3
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
				end)
			end)

			describe("border", function()
				local b = boxed({""}).border("12")

				it("should call renderer width subtracting border width", function()
					local expected = 3
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
				end)
			end)

			describe("padding", function()
				local b = boxed({""}).padding("12")

				it("should call renderer width subtracting padding width", function()
					local expected = 3
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
				end)
			end)

			describe("margin and border and padding", function()
				local b = boxed({""})
					.margin("12")
					.border("12")
					.padding("12")

				it("should call renderer width subtracting margin width", function()
					local expected = 4
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(10)

					assert.are.equal(expected, actual)
				end)
			end)
		end)

		describe("with single", function()
			describe("margin", function()
				local b = boxed({""}).margin(" ")

				it("should call renderer width subtracting margin width", function()
					local expected = 4
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
				end)
			end)

			describe("border", function()
				local b = boxed({""}).border(" ")

				it("should call renderer with width substracting border width", function()
					local expected = 4
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
				end)
			end)

			describe("padding", function()
				local b = boxed({""}).padding(" ")

				it("should call renderer with width substracting padding width", function()
					local expected = 4
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
				end)
			end)

			describe("margin and border and padding", function()
				local b = boxed({""})
					.margin(" ")
					.border(" ")
					.padding(" ")

				it("should call renderer with width substracting margin and border and padding widths", function()
					local expected = 2
					local actual
					mock.width = function(w)
						actual = w
					end

					b.width(5)

					assert.are.equal(expected, actual)
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
