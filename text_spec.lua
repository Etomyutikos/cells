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

	describe("align", function()
		describe("given nil", function()
			it("should error", function()
				assert.has_error(function() text("").align(nil) end, "invalid input, expected left, right, or center")
			end)
		end)

		describe("given a non-string", function()
			it("should error", function()
				assert.has_error(function() text("").align({}) end, "invalid input, expected left, right, or center")
			end)
		end)

		describe("given invalid input", function()
			it("should error", function()
				assert.has_error(function() text("").align("") end, "invalid input, expected left, right, or center")
			end)
		end)

		it("should return the text table", function()
			local t = text("")
			local actual = t.align("left")

			assert.are.equal(t, actual)
		end)
	end)

	describe("render", function()
 		local function testRender(input, width, expected)
			describe(string.format("input %q of width %d", input, input:len()), function()
				local t = text(input)

				describe(string.format("and max width of %s", width or "none"), function()
					if width then
						t.width(width)
					end

					describe("without align", function()
						it("should return elements matching the input", function()
							local actual = t.render()
							assert.are.same(expected.none, actual)
						end)
					end)

					describe("aligned", function()
						describe("left", function()
							t.align("left")

							it("should return padded elements matching the input", function()
								local actual = t.render()
								assert.are.same(expected.left, actual)
							end)
						end)

						describe("right", function()
							t.align("right")

							it("should return padded elements matching the input", function()
								local actual = t.render()
								assert.are.same(expected.right, actual)
							end)
						end)

						describe("center", function()
							t.align("center")

							it("should return padded elements matching the input", function()
								local actual = t.render()
								assert.are.same(expected.center, actual)
							end)
						end)
					end)
				end)
			end)
		end

		describe("given an empty string", function()
			testRender("", nil, {
				none = {},
				left = {},
				right = {},
				center = {},
			})
		end)

		describe("given unspaced", function()
			local input = "01234567890123456789012345678901234567890123456789"

			testRender(input, 50, {
				none = {
					"01234567890123456789012345678901234567890123456789"
				},
				left = {
					"01234567890123456789012345678901234567890123456789"
				},
				right = {
					"01234567890123456789012345678901234567890123456789"
				},
				center = {
					"01234567890123456789012345678901234567890123456789"
				}
			})

			testRender(input, 25, {
				none = {
					"0123456789012345678901234",
					"5678901234567890123456789"
				},
				left = {
					"0123456789012345678901234",
					"5678901234567890123456789"
				},
				right = {
					"0123456789012345678901234",
					"5678901234567890123456789"
				},
				center = {
					"0123456789012345678901234",
					"5678901234567890123456789"
				}
			})

			testRender(input, nil, {
				none = {
					"01234567890123456789012345678901234567890123456789"
				},
				left = {
					"01234567890123456789012345678901234567890123456789"
				},
				right = {
					"01234567890123456789012345678901234567890123456789"
				},
				center = {
					"01234567890123456789012345678901234567890123456789"
				}
			})
		end)

		describe("given spaced", function()
			local input = "01234 56789 98765 43210 01234 56789 98765 43210 01"

			testRender(input, 50, {
				none = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				},
				left = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				},
				right = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				},
				center = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				}
			})

			testRender(input, 25, {
				none = {
					"01234 56789 98765 43210",
					"01234 56789 98765 43210",
					"01"
				},
				left = {
					"01234 56789 98765 43210  ",
					"01234 56789 98765 43210  ",
					"01                       "
				},
				right = {
					"  01234 56789 98765 43210",
					"  01234 56789 98765 43210",
					"                       01"
				},
				center = {
					" 01234 56789 98765 43210 ",
					" 01234 56789 98765 43210 ",
					"            01           "
				}
			})

			testRender(input, nil, {
				none = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				},
				left = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				},
				right = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				},
				center = {
					"01234 56789 98765 43210 01234 56789 98765 43210 01"
				}
			})
		end)

		describe("given unspaced then spaced", function()
			local input = "0123456789012345678901234 56789 01234 56789 012345"

			testRender(input, 25, {
				none = {
					"0123456789012345678901234",
					"56789 01234 56789 012345"
				},
				left = {
					"0123456789012345678901234",
					"56789 01234 56789 012345 "
				},
				right = {
					"0123456789012345678901234",
					" 56789 01234 56789 012345"
				},
				center = {
					"0123456789012345678901234",
					" 56789 01234 56789 012345"
				}
			})

			testRender(input, 20, {
				none = {
					"01234567890123456789",
					"01234 56789 01234",
					"56789 012345"
				},
				left = {
					"01234567890123456789",
					"01234 56789 01234   ",
					"56789 012345        "
				},
				right = {
					"01234567890123456789",
					"   01234 56789 01234",
					"        56789 012345"
				},
				center = {
					"01234567890123456789",
					"  01234 56789 01234 ",
					"    56789 012345    "
				}
			})
		end)

		describe("with spaced then unspaced", function()
			local input = "56789 01234 56789 012345 0123456789012345678901234"

			testRender(input, 25, {
				none = {
					"56789 01234 56789 012345",
					"0123456789012345678901234"
				},
				left = {
					"56789 01234 56789 012345 ",
					"0123456789012345678901234"
				},
				right = {
					" 56789 01234 56789 012345",
					"0123456789012345678901234"
				},
				center = {
					" 56789 01234 56789 012345",
					"0123456789012345678901234"
				}
			})
		end)

		describe("with spaced between unspaced", function()
			local input = "56789 01234 0123456789012345678901234 56789 012345"

			testRender(input, 25, {
				none = {
					"56789 01234",
					"0123456789012345678901234",
					"56789 012345"
				},
				left = {
					"56789 01234              ",
					"0123456789012345678901234",
					"56789 012345             "
				},
				right = {
					"              56789 01234",
					"0123456789012345678901234",
					"             56789 012345"
				},
				center = {
					"       56789 01234       ",
					"0123456789012345678901234",
					"       56789 012345      "
				}
			})
		end)
	end)

	describe("width", function()
		describe("given nil", function()
			it("should error", function()
				assert.has_error(function() text("").width(nil) end, "invalid input, expected number")
			end)
		end)

		describe("given a non-number", function()
			it("should error", function()
				assert.has_error(function() text("").width("") end, "invalid input, expected number")
			end)
		end)

		it("should return the text table", function()
			local t = text("")
			local actual = t.width(1)

			assert.are.equal(t, actual)
		end)
	end)
end)
