/datum/codex_category/species
	name = "Species"
	desc = "The many species you may encounter on your journey."

/datum/codex_category/species/Populate()
	for (var/species_id in get_selectable_species())
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()
		var/_name = capitalize(codex_sanitize(species.plural_form))
		new /datum/codex_entry(
			_display_name = _name,
			_lore_text = species.get_species_lore(),
			_mechanics_text = list(species.get_species_description())
		)
		items += _name
	return ..()
