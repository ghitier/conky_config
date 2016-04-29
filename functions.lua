require 'cairo'

function draw_cpu(cr)

	local mult = 4
	local x, y = 70, 230
	local w, h = (100 * mult), 4
	local cpu0 = conky_parse("${cpu cpu0}")
	local cpu1 = conky_parse("${cpu cpu1}")
	local cpu2 = conky_parse("${cpu cpu2}")
	local cpu3 = conky_parse("${cpu cpu3}")
	local cpu4 = conky_parse("${cpu cpu4}")
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_rectangle (cr, x + w, y, -(cpu1 * mult), h)
	cairo_rectangle (cr, x + w, y + (h + 1), -(cpu2 * mult), h)
	cairo_rectangle (cr, x + w, y + (h + 1) * 2, -(cpu3 * mult), h)
	cairo_rectangle (cr, x + w, y + (h + 1) * 3, -(cpu4 * mult), h)
	cairo_fill (cr)
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_select_font_face (cr, "Unispace", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, 22.0)
	cairo_set_source_rgba (cr, hex_to_rgb(0x0C2E8A, 1))
	cairo_move_to (cr, x + w + 35, y + (h + 1) * 4)
	cairo_show_text (cr, "CPU ")
	cairo_show_text(cr, string.format("%02d", cpu0))
	cairo_show_text(cr, "%")
	cairo_stroke (cr)
end

function draw_ram(cr)

	local mult = 4
	local x, y = 70, 190
	local w, h = (100 * mult), 20
	local ram = conky_parse("$memperc")
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_rectangle (cr, x + w, y, -(ram * mult), h)
	cairo_fill (cr)
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_select_font_face (cr, "Unispace", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, 22.0)
	cairo_set_source_rgba (cr, hex_to_rgb(0x0C2E8A, 1))
	cairo_move_to (cr, x + w + 35, y + h)
	cairo_show_text (cr, "RAM ")
	cairo_show_text(cr, string.format("%02d", ram))
	cairo_show_text(cr, "%")
	cairo_stroke (cr)
end

function draw_disk(cr)

	local mult = 4
	local x, y = 70, 150
	local w, h = (100 * mult), 20
	local disk = conky_parse("${fs_used_perc /}")
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_rectangle (cr, x + w, y, -(disk * mult), h)
	cairo_fill (cr)
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_select_font_face (cr, "Unispace", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, 22.0)
	cairo_set_source_rgba (cr, hex_to_rgb(0x0C2E8A, 1))
	cairo_move_to (cr, x + w + 25, y + h)
	cairo_show_text (cr, "DISK ")
	cairo_show_text(cr, string.format("%02d", disk))
	cairo_show_text(cr, "%")
	cairo_stroke (cr)
end

function hex_to_rgb(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function conky_main()
	if conky_window == nil
		then
			return
	end

    local cs = cairo_xlib_surface_create(conky_window.display,
    									conky_window.drawable,
    									conky_window.visual,
    									conky_window.width,
    									conky_window.height)
    local cr = cairo_create(cs)
    local updates = tonumber(conky_parse('${updates}'))
    
    if updates > 5
    	then
    		draw_disk(cr)
    		draw_ram(cr)
    		draw_cpu(cr)
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end