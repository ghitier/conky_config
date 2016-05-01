require 'cairo'

function draw_cpu(cr, cores)

	local x, y = 70, 230
	local w, h = 400, 20
	local cpu = conky_parse("${cpu cpu0}")
	local text = "CPU "..string.format("%02d", cpu).."%"

	if cores == 0 then
		draw_bar(cr, x, y, w, h, cpu, color1)
	else
		for i = 1, cores, 1 do
			cpu = conky_parse("${cpu cpu"..string.format("%d", i).."}")
			draw_bar(cr, x, y + (h / cores) * (i - 1),
						w, (h / cores) - 1, cpu, color1)
		end
	end
	draw_text(cr, x + w + 38, y + h, text,
				"Unispace", 22.0, color2)
	mult, x, y, w, h, cpu, text = nil
end

function draw_ram(cr)

	local x, y = 70, 190
	local w, h = 400, 20
	local ram = conky_parse("$memperc")
	local text = "RAM "..string.format("%02d", ram).."%"
	
	draw_bar(cr, x, y, w, h, ram, color1)
	draw_text(cr, x + w + 38, y + h, text,
				"Unispace", 22.0, color2)
	mult, x, y, w, h, ram, text = nil
end

function draw_disk(cr)

	local x, y = 70, 150
	local w, h = 400, 20
	local disk = conky_parse("${fs_used_perc /}")
	local text = "DISK "..string.format("%02d", disk).."%"

	draw_bar(cr, x, y, w, h, disk, color1)
	draw_text(cr, x + w + 25, y + h, text,
				"Unispace", 22.0, color2)
	mult, x, y, w, h, disk, text = nil
end

function draw_bar(cr, x, y, w, h, perc, color)
	cairo_set_source_rgba(cr,hex_to_rgb(color, 1))
	cairo_rectangle(cr, x + w, y, -(perc * (w / 100)), h)
	cairo_fill(cr)
	cairo_set_source_rgba(cr, 1, 1, 1, 1)
end

function draw_text(cr, x, y, text, font, size, color)
	cairo_select_font_face (cr, font, CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, size)
	cairo_set_source_rgba(cr, hex_to_rgb(color, 1))
	cairo_move_to(cr, x, y)
	cairo_show_text(cr, text)
	cairo_stroke(cr)
	cairo_set_source_rgba(cr, 1, 1, 1, 1)
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
    
    color1 = 0xFFFFFF
    color2 = 0x0C2E8A
    cpu_cores = 4 -- Number of CPU cores (0 for sum of all CPU cores)

    if updates > 5
    	then
    		draw_disk(cr)
    		draw_ram(cr)
    		draw_cpu(cr, cpu_cores)
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end