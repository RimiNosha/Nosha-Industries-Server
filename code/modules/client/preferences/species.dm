/// Species preference
/datum/preference/choiced/species
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "species"
	priority = PREFERENCE_PRIORITY_SPECIES
	randomize_by_default = FALSE

/datum/preference/choiced/species/deserialize(input, datum/preferences/preferences)
	return GLOB.species_list[sanitize_inlist(input, get_choices_serialized(), SPECIES_HUMAN)]

/datum/preference/choiced/species/serialize(input)
	var/datum/species/species = input
	return initial(species.id)

/datum/preference/choiced/species/create_default_value()
	return /datum/species/human

/datum/preference/choiced/species/create_random_value(datum/preferences/preferences)
	return pick(get_choices())

/datum/preference/choiced/species/init_possible_values()
	var/list/values = list()

	for (var/species_id in get_selectable_species())
		values += GLOB.species_list[species_id]

	return values

/datum/preference/choiced/species/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.set_species(value, icon_update = FALSE, pref_load = TRUE)

/datum/preference/choiced/species/compile_constant_data()
	var/list/data = list()

	for (var/species_id in get_selectable_species())
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()

		var/datum/species/parent_species_type
		if (species.parent_type != /datum/species)
			var/datum/species/hold_me = species.parent_type
			parent_species_type = GLOB.species_list[initial(hold_me.id)]

		var/list/species_data = list(
			"name" = species.name,
			"desc" = species.get_species_description(),
			"lore" = species.get_species_lore(),
			"icon" = sanitize_css_class_name(species.name),
			"use_skintones" = species.use_skintones,
			"sexes" = species.sexes,
			"enabled_features" = species.get_features(),
			"perks" = species.get_species_perks(),
			"diet" =  species.get_species_diet(),
		)
		if(parent_species_type)
			species_data["parent_species"] = initial(parent_species_type.id)

		data[species_id] = species_data
		qdel(species)

	return data
