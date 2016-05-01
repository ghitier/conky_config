require 'cairo'

function draw_cpu(cr, data)

	local cpu = conky_parse("${cpu cpu0}")
	local text = "CPU "..string.format("%02d", cpu).."%"

	if cores == 0 then
		draw_bar(cr, data['x'], data['y'], data['w'], data['h'], cpu, data['bar_color'])
	else
		for i = 1, data['cores'], 1 do
			cpu = conky_parse("${cpu cpu"..string.format("%d", i).."}")
			draw_bar(cr, data['x'], data['y'] + (data['h'] / data['cores']) * (i - 1),
						data['w'], (data['h'] / data['cores']) - 1, cpu, data['bar_color'])
		end
	end
	draw_text(cr, data['x'] + data['w'] + data['text_pad'], data['y'] + data['h'], text,
				data['font'], data['font_size'], data['font_color'])
	cpu, text = nil
end

function draw_ram(cr, data)

	local ram = conky_parse("$memperc")
	local text = "RAM "..string.format("%02d", ram).."%"
	
	draw_bar(cr, data['x'], data['y'], data['w'], data['h'], ram, data['bar_color'])
	draw_text(cr, data['x'] + data['w'] + data['text_pad'], data['y'] + data['h'], text,
				data['font'], data['font_size'], data['font_color'])
	ram, text = nil
end

function draw_disk(cr, data)

	local disk = conky_parse("${fs_used_perc /}")
	local text = "DISK "..string.format("%02d", disk).."%"

	draw_bar(cr, data['x'], data['y'], data['w'], data['h'], disk, data['bar_color'])
	draw_text(cr, data['x'] + data['w'] + data['text_pad'], data['y'] + data['h'], text,
				data['font'], data['font_size'], data['font_color'])
	disk, text = nil
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

function conky_init()

	color1 = 0xFFFFFF
    color2 = 0x0C2E8A	

	cpu_data = {
		cores = 4,
		bar_color = color1,
		font_color = color2,
		x = 70, y = 230,
		w = 400, h = 20,
		text_pad = 38,
		font = "Unispace",
		font_size = 22.0,
	}

	ram_data = {
		bar_color = color1,
		font_color = color2,
		x = 70, y = 190,
		w = 400, h = 20,
		text_pad = 38,
		font = "Unispace",
		font_size = 22.0,
	}

	disk_data = {
		bar_color = color1,
		font_color = color2,
		x = 70, y = 150,
		w = 400, h = 20,
		text_pad = 25,
		font = "Unispace",
		font_size = 22.0,
	}
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

    if updates > 5 then
    	draw_disk(cr, disk_data)
    	draw_ram(cr, ram_data)
    	draw_cpu(cr, cpu_data)
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end