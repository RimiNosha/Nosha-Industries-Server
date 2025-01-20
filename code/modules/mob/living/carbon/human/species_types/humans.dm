/datum/species/human
	name = "\improper Human"
	id = SPECIES_HUMAN
	species_traits = list(
		EYECOLOR,
		HAIR,
		FACEHAIR,
		LIPS,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	use_skintones = TRUE
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | CLOTH | BUGS | GORE
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	roundstart = TRUE

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Business Hair"
	human.hair_color = "#bb9966" // brown
	human.update_body_parts()

/datum/species/human/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.skin_tone = random_skin_tone()

/datum/species/human/get_species_description()
	return "Placeholder."

/datum/species/human/get_species_lore()
	return list(
	)

/datum/species/human/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "people-group",
		SPECIES_PERK_NAME = "Commonplace",
		SPECIES_PERK_DESC = "Humans are the baseline, and are the most accommodated for species. Neat!",
	))

	if(CONFIG_GET(flag/enforce_human_authority))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bullhorn",
			SPECIES_PERK_NAME = "Chain of Command",
			SPECIES_PERK_DESC = "Nanotrasen only recognizes humans for command roles, such as Captain.",
		))

	return to_add

