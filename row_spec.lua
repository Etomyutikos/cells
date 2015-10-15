local row = require "row"

describe("row", function()
	describe("given nil", function()
		it("should error", function()
			assert.has_error(function() row(nil) end, "invalid input, expected table")
		end)
	end)

	describe("given a non-table", function()
		it("should error", function()
			assert.has_error(function() row("") end, "invalid input, expected table")
		end)
	end)

	describe("should validate content interface", function()
		describe("given inputs without render method", function()
			it("should error", function()
				assert.has_error(function() row({{}}) end, "invalid input, content 1 has no render method")
			end)
		end)

		describe("given inputs without width method", function()
			it("should error", function()
				assert.has_error(
					function() row({{render = function() end}}) end,
					"invalid input, content 1 has no width method")
			end)
		end)
	end)

	describe("render", function()
		describe("given renderer", function()
			local t = {
				render = function() end,
				width = function() end,
			}

			local r = row({t})

			describe("that doesn't return table", function()
				t.render = function()
					return ""
				end

				it("should error", function()
					assert.has_error(function() r.render() end, "invalid return from render, expected table of strings")
				end)
			end)

			describe("that doesn't return table of strings", function()
				t.render = function()
					return {1, 2, 3}
				end

				it("should error", function()
					assert.has_error(function() r.render() end, "invalid return from render, expected table of strings")
				end)
			end)
		end)

		describe("without length", function()
			describe("given an empty table", function()
				local r = row({})

				it("should return empty table", function()
					local expected = {}
					local actual = r.render()

					assert.are.same(expected, actual)
				end)
			end)

			describe("given single renderer", function()
				local t = {
					render = function()
						return {"abcdefg"}
					end,
					width = function() end
				}
				local r = row({t})

				it("should return single line", function()
					local expected = {"abcdefg"}
					local actual = r.render()

					assert.are.same(expected, actual)
				end)
			end)

			describe("given multiple renderers", function()
				local t1 = {
					render = function()
						return {"abcdefg"}
					end,
					width = function() end
				}
				local t2 = {
					render = function()
						return {"hijklmn"}
					end,
					width = function() end
				}
				local t3 = {
					render = function()
						return {"opqrstu"}
					end,
					width = function() end
				}
				local r = row({t1, t2, t3})

				it("should return single line without spaces", function()
					local expected = {"abcdefghijklmnopqrstu"}
					local actual = r.render()

					assert.are.same(expected, actual)
				end)
			end)

			describe("given renderers returning multiple height output", function()
				local tLong = {
					render = function()
						return {
							"abcdefg",
							"hijklmn",
							"opqrstu"
						}
					end,
					width = function() end
				}

				local tShort = {
					render = function()
						return {"vwxyz"}
					end,
					width = function() end
				}

				describe("given the long output first", function()
					local r = row({tLong, tShort})

					it("should return multiple lines with empty space", function()
						local expected = {
							"abcdefgvwxyz",
							"hijklmn     ",
							"opqrstu     "
						}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("given the long output second", function()
					local r = row({tShort, tLong})

					it("should return multiple lines with empty space", function()
						local expected = {
							"vwxyzabcdefg",
							"     hijklmn",
							"     opqrstu"
						}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("given the long output and an uneven output", function()
					local tUneven = {
						render = function()
							return {
								"123",
								"56789"
							}
						end,
						width = function() end
					}

					local r = row({tLong, tUneven})

					it("should return multiple lines with empty space", function()
						local expected = {
							"abcdefg123  ",
							"hijklmn56789",
							"opqrstu     "
						}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)
		end)

		describe("with width", function()
			describe("given single renderer", function()
				local t = {
					render = function()
						return {"abcdefg"}
					end,
					width = function() end
				}

				local r = row({t})

				describe("and width of 10", function()
					local width = 10
					r.width(width)

					it("should call renderer's width method with full width", function()
						local actual = false
						t.width = function(w)
							if w == width then
								actual = true
							end
						end

						r.render()

						assert.is_true(actual)
					end)

					it("should pad renderer's output", function()
						local expected = {"abcdefg   "}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("and width of 5", function()
					local width = 5
					r.width(width)

					it("should truncate renderer's output", function()
						local expected = {"abcde"}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)

			describe("given multiple renderers", function()
				local t1 = {
					render = function()
						return {
							"abcdefg",
							"1234567"
						}
					end,
					width = function() end
				}
				local t2 = {
					render = function()
						return {"hijklmn"}
					end,
					width = function() end
				}
				local t3 = {
					render = function()
						return {"opqrstu"}
					end,
					width = function() end
				}

				local r = row({t1, t2, t3})

				describe("and width of 9", function()
					local width = 9
					r.width(width)

					it("should call renderers' width methods with partial width", function()
						local expected = {3, 3, 3}
						local actual = {0, 0, 0}
						for i, v in ipairs({t1, t2, t3}) do
							v.width = function(w)
								actual[i] = w
							end
						end

						r.render()

						assert.are.same(expected, actual)
					end)

					it("should truncate renderers' outputs", function()
						local expected = {
							"abchijopq",
							"123      "
						}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("and width of 11", function()
					local width = 11
					r.width(width)

					it("should call renderers' width methods with partial width", function()
						local expected = {4, 4, 3}
						local actual = {0, 0, 0}

						for i, v in ipairs({t1, t2, t3}) do
							v.width = function(w)
								actual[i] = w
							end
						end

						r.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("and width of 24", function()
					local width = 24
					r.width(width)

					it("should pad renderers' outputs", function()
						local expected = {
							"abcdefg hijklmn opqrstu ",
							"1234567                 "
						}
						local actual = r.render()

						assert.are.same(expected, actual)
					end)
				end)
			end)
		end)
	end)

	describe("width", function()
		local t = {render = function() end}

		describe("given nil", function()
			it("should error", function()
				assert.has_error(function() row(t).width(nil) end, "invalid input, expected number")
			end)
		end)

		describe("given a non-number", function()
			it("should error", function()
				assert.has_error(function() row(t).width("") end, "invalid input, expected number")
			end)
		end)

		it("should return the row table", function()
			local r = row(t)
			local actual = r.width(1)

			assert.are.equal(r, actual)
		end)
	end)

	describe("when the width is not evenly divisible by number of renderers", function()
		local t1 = {
			render = function()
				return {
				"this is some long",
				"text this is some",
				"long text this is",
				"some long text   ",
				"this is some long",
				"text this is some",
				"long text this is",
				"some long text   ",
				"this is some long",
				"text this is some",
				"long text this is",
				"some long text   ",
				"this is some long",
				"text             ",
				}
			end,
			width = function() end,
		}

		local t2 = {
			render = function()
				return {
					"this is some    ",
					"long text this  ",
					"is some long    ",
					"text this is    ",
					"some long text  ",
					"this is some    ",
					"long text this  ",
					"is some long    ",
					"text this is    ",
					"some long text  ",
					"this is some    ",
					"long text this  ",
					"is some long    ",
					"text this is    ",
					"some long text  ",
					"this is some    ",
					"long text       ",
				}
			end,
			width = function() end
		}

		local r = row({t1, t1, t2}).width(50)

		it("then the output should be padded by distributed modulo", function()
			local expected = {
				"this is some longthis is some longthis is some    ",
				"text this is sometext this is somelong text this  ",
				"long text this islong text this isis some long    ",
				"some long text   some long text   text this is    ",
				"this is some longthis is some longsome long text  ",
				"text this is sometext this is somethis is some    ",
				"long text this islong text this islong text this  ",
				"some long text   some long text   is some long    ",
				"this is some longthis is some longtext this is    ",
				"text this is sometext this is somesome long text  ",
				"long text this islong text this isthis is some    ",
				"some long text   some long text   long text this  ",
				"this is some longthis is some longis some long    ",
				"text             text             text this is    ",
				"                                  some long text  ",
				"                                  this is some    ",
				"                                  long text       ",
			}
			local actual = r.render()

			assert.are.same(expected, actual)
		end)
	end)
end)
