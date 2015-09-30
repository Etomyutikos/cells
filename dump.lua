-- Initialize
Papyros = Papyros or {
	Data = {
		Layouts = {},
	},
	Runtime = {},
}

-- Default Layout
Papyros.Data.Layouts["Papyros"] = {
	Name = "Papyros",

	Title = {
		Glyph = "-=Papyros=-",
		Color = "gold",
	},

	Filler = {
		Character = ".",
		Color = "gainsboro"
	},

	Border = {
		Character = "~",
		Color = {212, 175, 55},
	},

	Content = {
		Color = {227, 227, 227},
	},

	Line = {
		Title = "-=Papyros:",
		Closer = "=-",
	},

	PageWidth = 80,
}

-- Objects/Page
function Papyros.Page (lines)
	local function check_line (l)
		if type(l) ~= "table" then
			return false
		else
			if #l == 0 then
				return false
			else
				if l.is_line or l.is_link then
					return true
				else
					for _, o in ipairs( l ) do
						if not check_line( o ) then
							return false
						end
					end

					return true
				end
			end
		end
	end

	for _, line in ipairs( lines ) do
		if not check_line( line ) then
			Papyros.WriteLine( "Papyros", "Invalid Line or Link passed to Page." )
			return
		end
	end

	lines.is_page = true
	return lines
end

-- Objects/Line
function Papyros.Line (content, options)
	if type(content) == "table" then
		content.is_line = true
	else
		content = {(content or ""), is_line = true}
	end

	if options then
		if options.align then
			content.align = options.align
		end

		if options.wrap then
			content.wrap = options.wrap
		end
	end

	return content
end

-- Objects/Link
function Papyros.Link (text, func, tip, options)
	local link = {text, func, tip, is_link = true}

	if options then
		if options.align then
			link.align = options.align
		end
	end

	return link
end

-- Functions/RegisterLayout
function Papyros.RegisterLayout (layout)
	local layouts = Papyros.Data.Layouts

	if not layouts[layout.Name] then
		layouts[layout.Name] = layout
		Papyros.WriteLine( "Papyros", string.format( "Adding new Layout: %s.", layout.Name ) )
	else
		layouts[layout.Name] = layout
		Papyros.WriteLine( "Papyros", string.format( "Updating Layout: %s.", layout.Name ) )
	end
end

-- Functions/WriteLine
function Papyros.WriteLine (layout, line)
	if not Papyros.Data.Layouts[layout] then
		Papyros.WriteLine( "Papyros", string.format( "Error writing Line. Layout %s does not exist.", layout ) )
	end

	local settings = Papyros.Data.Layouts[layout]
	Papyros.Runtime.CurrentLayout = settings

	local content_length = settings.PageWidth - (settings.Line.Title:len() + settings.Line.Closer:len())
	Papyros.Echo( "Title", settings.Line.Title )
	Papyros.Echo( "Content", string.format( [[%-]] .. (content_length - 1) .. "s", line ) )
	Papyros.Echo( "Title", settings.Line.Closer )
	echo("\n")

	Papyros.Runtime.CurrentLayout = nil
end

-- Functions/WriteHeader
function Papyros.WriteHeader ()
	local settings = Papyros.Runtime.CurrentLayout

	local title_width 		= settings.Title.Glyph:len()
	local half_title 		= title_width / 2

	local filler_width		= settings.Filler.Character:len()

	local inner_width		= settings.PageWidth - (settings.Border.Character:len() * 2)
	local half_width 		= inner_width / 2

	local left_padding 	= tonumber( string.format( "%d", half_width - (half_title + (title_width % 2)) ) )
	local right_padding	= inner_width - ((left_padding + title_width) * filler_width)

	Papyros.Echo( "Border", string.rep(settings.Border.Character, settings.PageWidth) .. "\n" )
	Papyros.Echo( "Border", settings.Border.Character )
	Papyros.Echo( "Filler", string.rep( settings.Filler.Character, left_padding / filler_width ) )
	Papyros.Echo( "Title", settings.Title.Glyph )
	Papyros.Echo( "Filler", string.rep( settings.Filler.Character, right_padding / filler_width ) )
	Papyros.Echo( "Border", settings.Border.Character )
	echo("\n")
end

-- Functions/WritePage
function Papyros.WritePage (layout, page)
	if not Papyros.Data.Layouts[layout] then
		Papyros.WriteLine( "Papyros", string.format( "Error writing Page. Layout %s does not exist.", layout ) )
		return
	end

	if not page then
		Papyros.WriteLine( "Papyros", "Error writing Page. Did not pass Papyros.Page object." )
		return
	else
		if not page.is_page then
			Papyros.WriteLine( "Papyros", "Error writing Page. Did not pass Papyros.Page object." )
			return
		end
	end

	Papyros.Runtime.CurrentLayout = Papyros.Data.Layouts[layout]
	local settings = Papyros.Runtime.CurrentLayout

	Papyros.WriteHeader()

	local line = table.remove( page, 1 )
	while line do
		Papyros_tmpPageWidth = (settings.PageWidth - ((settings.Border.Character:len() * 2) + 2))

		if line.wrap then
			if line[1]:len() > Papyros_tmpPageWidth then
				new_line = Papyros.Line( line[1]:sub(Papyros_tmpPageWidth + 1), {align = line.align, wrap = true} )
				table.insert( page, 1, new_line )
			end
		end
		Papyros.Echo( "Border", settings.Border.Character .. " " )

		Papyros.WritePageLine( line, Papyros_tmpPageWidth )

		Papyros.Echo( "Border", " " .. settings.Border.Character )
		echo("\n")

		line = table.remove( page, 1 )
	end

	Papyros.Echo( "Border", string.rep(settings.Border.Character, settings.PageWidth) .. "\n" )

	Papyros_tmpPageWidth = nil
end

-- Functions/WritePageLine
function Papyros.WritePageLine (line, line_width)
	local settings = Papyros.Runtime.CurrentLayout

	local function print_text (text, align, is_link)
		align 		= text.align 	or "left"
		text[1] 	= text[1] 		or ((text.is_link and "_") or "")

		if type(align) == "string" then
			if align == "left" then
				if not text.is_link then
					Papyros.Echo( "Content",
									string.format( ([[%-]] .. line_width) .. "s", text[1]:sub( 1, line_width ) )
									)
				else
					echoLink( text[1]:sub(1, line_width), text[2], text[3] )
					echo( string.rep( " ", line_width - text[1]:len() ) )
				end
			elseif align == "right" then
				if not text.is_link then
					Papyros.Echo( "Content",
									string.format( ([[%]] .. line_width) .. "s", text[1]:sub( 1, line_width ) )
									)
				else
					echo( string.rep( " ", line_width - text[1]:len() ) )
					echoLink( text[1]:sub(1, line_width), text[2], text[3] )
				end
			elseif align == "center" then
				local width = text[1]:len()
				local left = tonumber(string.format( "%d", (line_width / 2) - ((width / 2) + ((width / 2) % 2)) ))
				local right = line_width - (left + width)

				if not text.is_link then
					Papyros.Echo( "Content",
							string.format( "%s%s%s", string.rep( " ", left ),
								text[1]:sub( 1, line_width ),
								string.rep( " ", right )
											)
									)
				else
					echo( string.rep( " ", left ) )
					echoLink( text[1]:sub(1, line_width), text[2], text[3] )
					echo( string.rep( " ", right ) )
				end
			end

		elseif type(align) == "number" then
			if align > 0 then
				if align < 1 then
					align = tonumber( string.format( "%d", (align * line_width) ) )
				end

				if not text.is_link then
					Papyros.Echo( "Content",
							string.format( ("%s" .. [[%-]] .. (line_width - align)) .. "s",
								string.rep( " ", align ),
								text[1]:sub( 1, (line_width - align) )
											)
									)
				else
					echo( string.rep( " ", align ) )
					echoLink( text[1]:sub(1, line_width), text[2], text[3] )
					echo( string.rep( " ", line_width - (align + text[1]:len()) ) )
				end
			else
				if align > -1 then
					align = tonumber( string.format( "%d", (align * line_width) ) )
				end

				if not text.is_link then
					Papyros.Echo( "Content",
							string.format( ( [[%]] .. (line_width - math.abs(align))) .. "s%s",
								text[1]:sub( 1, (line_width - math.abs(align)) ),
								string.rep( " ", math.abs(align) )
											)
									)
				else
					echo( string.rep( " ", line_width - (math.abs(align) + text[1]:len()) ) )
					echoLink( text[1]:sub(1, line_width), text[2], text[3] )
					echo( string.rep( " ", math.abs(align) ) )
				end
			end
		end
	end

	if line.is_line then
		print_text( line )

	elseif line.is_link then
		print_text( line, true )

	else
		local word_width = tonumber( string.format( "%d", (line_width / #line) ) )
		for i, word in ipairs( line ) do
			if i == #line then
				word_width = word_width + (line_width - (word_width * #line))
			end

			Papyros.WritePageLine( word, word_width )
		end
	end
end

-- Functions/Echo
function Papyros.Echo (what, text)
	local settings = Papyros.Runtime.CurrentLayout
	local color = settings[what].Color

	if color then
		if type(color) == "string" then
			if color_table[color] then
				color = color_table[color]
			else
				Papyros.WriteLine( "Papyros", "Error echoing. Color (" .. color .. ") not found in color_table." )
			end
		end

		setFgColor( color[1], color[2], color[3] )
		echo( text )
		resetFormat()
	else
		echo( text )
	end
end
