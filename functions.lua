require 'cairo'

function draw_cpu(cr, data)

	local cpu = conky_parse("${cpu cpu0}")
	local text = "CPU "..string.format("%02d", tonumber(cpu)).."%"

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

function draw_gpu(cr, data)

   local gpu = tonumber(conky_parse("${exec nvidia-settings -tq GPUUtilization | grep -o 'graphics=[0-9]*' | sed -e 's/graphics=//'}")) or 0;
   local text = "GPU "..string.format("%02d", gpu).."%"

   draw_bar(cr, data['x'], data['y'], data['w'], data['h'], gpu, data['bar_color'])
   draw_text(cr, data['x'] + data['w'] + data['text_pad'], data['y'] + data['h'], text,
	     data['font'], data['font_size'], data['font_color'])
   gpu, text = nil
end

function draw_ram(cr, data)

	local ram = conky_parse("$memperc")
	local text = "RAM "..string.format("%02d", tonumber(ram)).."%"
	
	draw_bar(cr, data['x'], data['y'], data['w'], data['h'], ram, data['bar_color'])
	draw_text(cr, data['x'] + data['w'] + data['text_pad'], data['y'] + data['h'], text,
				data['font'], data['font_size'], data['font_color'])
	ram, text = nil
end

function draw_disk(cr, data)

	local disk = conky_parse("${fs_used_perc /}")
	local text = "DISK "..string.format("%02d", tonumber(disk)).."%"

	draw_bar(cr, data['x'], data['y'], data['w'], data['h'], disk, data['bar_color'])
	draw_text(cr, data['x'] + data['w'] + data['text_pad'], data['y'] + data['h'], text,
				data['font'], data['font_size'], data['font_color'])
	disk, text = nil
end

function draw_clock(cr, data)

	local time = {conky_parse("${time %H}")..":", conky_parse("${time %M}"),
				conky_parse("${time %S}"), conky_parse("${time %a}")}
	for i = 1, 4, 1 do
		draw_text(cr, data[i]['x'], data[i]['y'], time[i], data[i]['font'],
					data[i]['font_size'], data[i]['font_color'])
	end
	time = nil
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

	gpu_data = {
		bar_color = color1,
		font_color = color2,
		x = 1370, y = 470,
		w = 400, h = 20,
		text_pad = 38,
		font = "Unispace",
		font_size = 22.0,
	}
	
	cpu_data = {
		cores = 4,
		bar_color = color1,
		font_color = color2,
		x = 1370, y = 430,
		w = 400, h = 20,
		text_pad = 38,
		font = "Unispace",
		font_size = 22.0,
	}

	ram_data = {
		bar_color = color1,
		font_color = color2,
		x = 1370, y = 390,
		w = 400, h = 20,
		text_pad = 38,
		font = "Unispace",
		font_size = 22.0,
	}

	disk_data = {
		bar_color = color1,
		font_color = color2,
		x = 1370, y = 350,
		w = 400, h = 20,
		text_pad = 25,
		font = "Unispace",
		font_size = 22.0,
	}

	clock_data = {
		{
			x = 1670, y = 330,
			font = "Unispace",
			font_size = 58.0,
			font_color = color1,
		},
		{
			x = 1770, y = 330,
			font = "Unispace",
			font_size = 58.0,
			font_color = color1,
		},
		{
			x = 1850, y = 305,
			font = "Unispace",
			font_size = 24.0,
			font_color = color2,
		},
		{
			x = 1850, y = 330,
			font = "Neuropolitical",
			font_size = 22.0,
			font_color = color2,
		},
	}
end

function conky_free()
	color1 = nil
	color2 = nil
	cpu_data = nil
	ram_data = nil
	disk_data = nil
	gpu_data = nil
	collectgarbage("collect")
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
    	draw_clock(cr, clock_data)
    	draw_disk(cr, disk_data)
    	draw_ram(cr, ram_data)
    	draw_cpu(cr, cpu_data)
	draw_gpu(cr, gpu_data)
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end
