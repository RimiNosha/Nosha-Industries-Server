/// Given a color in the format of "#RRGGBB", will return if the color
/// is dark.
/proc/is_color_dark(color, threshold = 25)
	var/hsl = rgb2num(color, COLORSPACE_HSL)
	return hsl[3] < threshold

/// Given a 3 character color (no hash), converts it into #RRGGBB (with hash)
/proc/expand_three_digit_color(color)
	if (length_char(color) != 3)
		CRASH("Invalid 3 digit color: [color]")

	var/final_color = "#"

	for (var/digit = 1 to 3)
		final_color += copytext(color, digit, digit + 1)
		final_color += copytext(color, digit, digit + 1)

	return final_color

///Returns a random color picked from a list, has 2 modes (0 and 1), mode 1 doesn't pick white, black or gray
/proc/random_colour(mode = 0)
	switch(mode)
		if(0)
			return pick("white","black","gray","red","green","blue","brown","yellow","orange","darkred",
						"crimson","lime","darkgreen","cyan","navy","teal","purple","indigo")
		if(1)
			return pick("red","green","blue","brown","yellow","orange","darkred","crimson",
						"lime","darkgreen","cyan","navy","teal","purple","indigo")
		else
			return "white"

///Inverts the colour of an HTML color_to_darken
/proc/invert_HTML_colour(HTMLstring)
	if(!istext(HTMLstring))
		CRASH("Given non-text argument!")
	else if(length(HTMLstring) != 7)
		CRASH("Given non-HTML argument!")
	else if(length_char(HTMLstring) != 7)
		CRASH("Given non-hex symbols in argument!")
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	return rgb(255 - hex2num(textr), 255 - hex2num(textg), 255 - hex2num(textb))

///Flash a color on the client
/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/flashed_client
	if(ismob(mob_or_client))
		var/mob/client_mob = mob_or_client
		if(client_mob.client)
			flashed_client = client_mob.client
		else
			return
	else if(istype(mob_or_client, /client))
		flashed_client = mob_or_client

	if(!istype(flashed_client))
		return

	var/animate_color = flashed_client.color
	flashed_client.color = flash_color
	animate(flashed_client, color = animate_color, time = flash_time)

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

/// An inexact color darken proc. Do not use if you need precise adjustments.
/proc/darken_color(color_to_darken, darken_steps = 1)
	var/list/color_numbers = rgb2num(color_to_darken)

	var/final_darken = 0.8

	for(var/i = 1, i > darken_steps, i++) // Start at one cause it will always be at least 0.8 reduction.
		final_darken *= 0.8 // Reduce color values by 20% (compound) each loop.

	color_numbers[1] *= final_darken
	color_numbers[2] *= final_darken
	color_numbers[3] *= final_darken

	// Lazy support for alpha.
	return (length(color_numbers) > 3) ? rgb(color_numbers[1], color_numbers[2], color_numbers[3], color_numbers[4]) : rgb(color_numbers[1], color_numbers[2], color_numbers[3])

/// Similar to center_icon, but actually paints the source onto the target icon.
/proc/center_blend_icon(icon/target, icon/source, x_dimension, y_dimension)
	if(!x_dimension || !y_dimension)
		return

	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return

	//Offset the image so that its bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension / world.icon_size) - 1) * (world.icon_size * 0.5)
	var/y_offset = -((y_dimension / world.icon_size) - 1) * (world.icon_size * 0.5)

	//Correct values under icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	target.Blend(source, ICON_OVERLAY, x_offset, y_offset)
