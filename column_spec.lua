local column = require "column"

describe("column", function()
	describe("given nil", function()
		it("should error", function()
			assert.has_error(function() column(nil) end, "invalid input, expected table")
		end)
	end)

	describe("given a non-table", function()
		it("should error", function()
			assert.has_error(function() column("") end, "invalid input, expected table")
		end)
	end)

	describe("should validate content interface", function()
		describe("given inputs without render method", function()
			it("should error", function()
				assert.has_error(function() column({{}}) end, "invalid input, content 1 has no render method")
			end)
		end)

		describe("given inputs without width method", function()
			it("should error", function()
				assert.has_error(
					function() column({{render = function() end}}) end, "invalid input, content 1 has no width method")
			end)
		end)
	end)

	describe("render", function()
		describe("given renderer", function()
			local t = {
				render = function() end,
				width = function() end,
			}

			local c = column({t})

			describe("that doesn't return table", function()
				t.render = function()
					return ""
				end

				it("should error", function()
				   assert.has_error(function() c.render() end, "invalid return from render, expected table of strings")
				end)
			end)

			describe("that doesn't return table of strings", function()
				t.render = function()
					return {1, 2, 3}
				end

				it("should error", function()
				   assert.has_error(function() c.render() end, "invalid return from render, expected table of strings")
				end)
			end)
		end)

		describe("without length", function()
			describe("given an empty table", function()
				local c = column({})

				it("should return empty table", function()
					local expected = {}
					local actual = c.render()

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
				local c = column({t})

				it("should return single line", function()
					local expected = {"abcdefg"}
					local actual = c.render()

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
				local c = column({t1, t2, t3})

				it("should return multiple lines", function()
					local expected = {
						"abcdefg",
						"hijklmn",
						"opqrstu"
					}
					local actual = c.render()

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
					local c = column({tLong, tShort})

					it("should return multiple lines", function()
						local expected = {
							"abcdefg",
							"hijklmn",
							"opqrstu",
							"vwxyz  ",
						}
						local actual = c.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("given the long output second", function()
					local c = column({tShort, tLong})

					it("should return multiple lines", function()
						local expected = {
							"vwxyz  ",
							"abcdefg",
							"hijklmn",
							"opqrstu",
						}
						local actual = c.render()

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

					local c = column({tLong, tUneven})

					it("should return multiple lines", function()
						local expected = {
							"abcdefg",
							"hijklmn",
							"opqrstu",
							"123    ",
							"56789  ",
						}
						local actual = c.render()

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

				local c = column({t})

				describe("and width of 10", function()
					local width = 10
					c.width(width)

					it("should call renderer's width method with full width", function()
						local actual = false
						t.width = function(w)
							if w == width then
								actual = true
							end
						end

						c.render()

						assert.is_true(actual)
					end)

					it("should pad renderer's output", function()
						local expected = {"abcdefg   "}
						local actual = c.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("and width of 5", function()
					local width = 5
					c.width(width)

					it("should truncate renderer's output", function()
						local expected = {"abcde"}
						local actual = c.render()

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

				local c = column({t1, t2, t3})

				describe("and width of 3", function()
					local width = 3
					c.width(width)

					it("should call renderers' width methods with partial width", function()
						local expected = {3, 3, 3}
						local actual = {0, 0, 0}
						for i, v in ipairs({t1, t2, t3}) do
							v.width = function(w)
								actual[i] = w
							end
						end

						c.render()

						assert.are.same(expected, actual)
					end)

					it("should truncate renderers' outputs", function()
						local expected = {
							"abc",
							"123",
							"hij",
							"opq",
						}
						local actual = c.render()

						assert.are.same(expected, actual)
					end)
				end)

				describe("and width of 11", function()
					local width = 11
					c.width(width)

					it("should call renderers' width methods with partial width", function()
					local expected = {11, 11, 11}
					local actual = {0, 0, 0}

					for i, v in ipairs({t1, t2, t3}) do
						v.width = function(w)
							actual[i] = w
						end
					end

					c.render()

					assert.are.same(expected, actual)
					end)
				end)

				describe("and width of 24", function()
					local width = 24
					c.width(width)

					it("should pad renderers' outputs", function()
						local expected = {
							"abcdefg                 ",
							"1234567                 ",
							"hijklmn                 ",
							"opqrstu                 ",
						}
						local actual = c.render()

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
				assert.has_error(function() column(t).width(nil) end, "invalid input, expected number")
			end)
		end)

		describe("given a non-number", function()
			it("should error", function()
				assert.has_error(function() column(t).width("") end, "invalid input, expected number")
			end)
		end)

		it("should return the column table", function()
			local c = column(t)
			local actual = c.width(1)

			assert.are.equal(c, actual)
		end)
	end)
end)
