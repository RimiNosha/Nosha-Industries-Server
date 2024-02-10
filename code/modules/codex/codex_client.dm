/client
	var/codex_cooldown = 0
	var/const/max_codex_entries_shown = 30

/client/verb/search_codex(searching as text)

	set name = "Search Codex"
	set category = "OOC"
	set src = usr

	if(!mob || !SScodex)
		return

	if(codex_cooldown >= world.time)
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return

	if(!searching)
		searching = input("Enter a search string.", "Codex Search") as text|null
		if(!searching)
			return

	codex_cooldown = world.time + 1 SECONDS

	var/list/all_entries = SScodex.retrieve_entries_for_string(searching)
	all_entries = all_entries.Copy() // So we aren't messing with the codex search cache.

	// Remove any entries that only have antag text if mob isn't antag.
	if(mob && mob.mind && !length(mob.mind.antag_datums))
		for(var/datum/codex_entry/entry in all_entries)
			if(entry.antag_text && !entry.mechanics_text && !entry.lore_text)
				all_entries -= entry

	// Put entries with match in the name first
	for(var/datum/codex_entry/entry in all_entries)
		if(findtext(entry.name, searching))
			all_entries -= entry
			all_entries.Insert(1, entry)

	if(LAZYLEN(all_entries) == 1)
		SScodex.present_codex_entry(mob, all_entries[1])
	else
		if(LAZYLEN(all_entries) > 1)
			var/list/codex_data = list("<h3><b>[all_entries.len] matches</b> for '[searching]':</h3>")
			if(LAZYLEN(all_entries) > max_codex_entries_shown)
				codex_data += "Showing first <b>[max_codex_entries_shown]</b> entries. <b>[all_entries.len - 5] result\s</b> omitted.</br>"
			codex_data += "<table width = 100%>"
			for(var/i = 1 to min(all_entries.len, max_codex_entries_shown))
				var/datum/codex_entry/entry = all_entries[i]
				codex_data += "<tr><td>[entry.name]</td><td><a href='?src=\ref[SScodex];show_examined_info=\ref[entry]'>View</a></td></tr>"
			codex_data += "</table>"
			var/datum/browser/popup = new(mob, "codex-search", "Codex Search") //"codex-search"
			popup.set_content(codex_data.Join())
			popup.open()
		else
			to_chat(src, span_alert("The codex reports <b>no matches</b> for '[searching]'."))

/client/verb/list_codex_entries()

	set name = "List Codex Entries"
	set category = "OOC"
	set src = usr

	if(!mob || !SScodex.initialized)
		return

	if(codex_cooldown >= world.time)
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return

	codex_cooldown = world.time + 1 SECONDS

	var/datum/browser/popup = new(mob, "codex", "Codex Index") //"codex-index"
	var/datum/codex_entry/nexus = SScodex.get_entry_by_string("nexus")
	var/list/codex_data = list(nexus.get_codex_header(mob).Join(), "<h2>Codex Entries</h2>")
	codex_data += "<table width = 100%>"

	var/antag_check = mob && mob.mind && length(mob.mind.antag_datums)
	var/last_first_letter
	for(var/thing in SScodex.index_file)

		var/datum/codex_entry/entry = SScodex.index_file[thing]
		if(!antag_check && entry.antag_text && !entry.mechanics_text && !entry.lore_text && !entry.controls_text)
			continue

		var/first_letter = uppertext(copytext(thing, 1, 2))
		if(first_letter != last_first_letter)
			last_first_letter = first_letter
			codex_data += "<tr><td colspan = 2><hr></td></tr>"
			codex_data += "<tr><td colspan = 2>[last_first_letter]</td></tr>"
			codex_data += "<tr><td colspan = 2><hr></td></tr>"
		codex_data += "<tr><td>[thing]</td><td><a href='?src=\ref[SScodex];show_examined_info=\ref[SScodex.index_file[thing]]'>View</a></td></tr>"
	codex_data += "</table>"
	popup.set_content(codex_data.Join())
	popup.open()


/client/verb/codex()
	set name = "Codex"
	set category = "OOC"
	set src = usr

	if(!SScodex.initialized)
		to_chat(usr, span_warning("The codex isn't set up yet! Wait until the server has finished initializing!"))
		return

	if(codex_cooldown >= world.time)
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return

	codex_cooldown = world.time + 1 SECONDS

	var/datum/codex_entry/entry = SScodex.get_codex_entry("nexus")
	SScodex.present_codex_entry(mob, entry)
