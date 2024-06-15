//DEFINITIONS FOR ASSET DATUMS START HERE.
#define TEMPLATE_FILE_NAME "all_templates.json"

/datum/asset/simple/nanoui
	early = TRUE
	keep_local_name = TRUE
	var/list/common = list()
	var/list/uncommon = list()

	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"news_articles/images/"
	)
	var/template_dir = "nano/templates/"
	var/template_temp_dir = "data/"

/datum/asset/simple/nanoui/register()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					/datum/asset_cache_item
					common[filename] = file(path + filename)

	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					uncommon[filename] = file(path + filename)

	merge_and_register_templates()

	// var/list/mapnames = list()
	// for(var/z in SSmapping.map_levels)
	// 	mapnames += map_image_file_name(z)

	// var/list/filenames = flist(MAP_IMAGE_PATH)
	// for(var/filename in filenames)
	// 	if(copytext(filename, length(filename)) != "/") // Ignore directories.
	// 		var/file_path = MAP_IMAGE_PATH + filename
	// 		if((filename in mapnames) && fexists(file_path))
	// 			common[filename] = fcopy_rsc(file_path)
	// 			register_asset(filename, common[filename])

	var/new_assets = list(TEMPLATE_FILE_NAME = file(template_temp_dir + TEMPLATE_FILE_NAME)) + uncommon + common
	assets = new_assets

	return ..()

/datum/asset/simple/nanoui/send(client, uncommon)
	. = ..()
	. = . && SSassets.transport.send_assets(client, uncommon)

/datum/asset/simple/nanoui/proc/merge_and_register_templates()
	var/list/templates = flist(template_dir)
	for(var/filename in templates)
		if(copytext(filename, length(filename)) != "/")
			templates[filename] = replacetext(replacetext(file2text(template_dir + filename), "\n", ""), "\t", "")
		else
			templates -= filename
	var/full_file_name = template_temp_dir + TEMPLATE_FILE_NAME
	if(fexists(full_file_name))
		fdel(file(full_file_name))
	var/template_file = file(full_file_name)
	WRITE_FILE(template_file, json_encode(templates))

// Note: this is intended for dev work, and is unsafe. Do not use outside of that.
/datum/asset/simple/nanoui/proc/recompute_and_resend_templates()
	merge_and_register_templates()
	for(var/client/C in GLOB.clients)
		if(C) // there are sleeps here, potentially
			SSassets.transport.send_assets(C, TEMPLATE_FILE_NAME, FALSE, FALSE)
			to_chat(C, span_warning("Nanoui templates have been updated. Please close and reopen any browser windows."))

/client/proc/resend_nanoui_templates()
	set category = "Debug"
	set name = "Resend Nanoui Templates"
	if(!check_rights(R_DEBUG))
		return
	var/datum/asset/simple/nanoui/nano_asset = get_asset_datum(/datum/asset/simple/nanoui)
	if(nano_asset)
		nano_asset.recompute_and_resend_templates()
