SUBSYSTEM_DEF(accessories)
	/// An assoc list of part keys to an assoc list of part names to their instance.
	var/list/sprite_accessories = list()
	/// An assoc list of part keys to a list of part names.
	var/list/sprite_accessory_keys = list()
	/// An assoc list of male intended sprite accessories to a list of part names.
	var/list/male_sprite_accessory_keys = list()
	/// An assoc list of female intended sprite accessories to a list of part names.
	var/list/female_sprite_accessory_keys = list()

/datum/controller/subsystem/accessories/PreInit()
	init_accessories()
	init_gradients()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/accessories/proc/init_accessories()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks)
	//bodypart accessories (blizzard intensifies)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines_animated)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/caps)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/pod_hair)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/screen, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/antenna, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/synth_head)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/synth_chassis)

/datum/controller/subsystem/accessories/proc/init_sprite_accessory_subtypes(datum/sprite_accessory/prototype, roundstart = FALSE, add_blank)//Roundstart argument builds a specific list for roundstart parts where some parts may be locked
	var/list/accessory_list = list()
	var/list/both = list()
	var/list/male = list()
	var/list/female = list()

	for(var/path in subtypesof(prototype))
		if(roundstart)
			var/datum/sprite_accessory/accessory = path
			if(initial(accessory.locked))
				continue
		var/datum/sprite_accessory/accessory = new path()

		if(!accessory.name || accessory.icon_state)
			continue

		if(accessory.icon_state)
			accessory_list[accessory.name] = accessory
		else
			accessory_list += accessory.name

		both += accessory.name
		switch(accessory.gender)
			if(MALE)
				male += accessory.name
			if(FEMALE)
				female += accessory.name
			else
				male += accessory.name
				female += accessory.name

	var/list/temp_list = sort_list(accessory_list)
	accessory_list.Cut()

	if(add_blank)
		accessory_list += list(SPRITE_ACCESSORY_NONE = new /datum/sprite_accessory/blank)
	else
		// Catch sprite accessory datums that have snowflake none entries.
		var/none_entry = accessory_list[SPRITE_ACCESSORY_NONE]
		if(none_entry)
			temp_list -= SPRITE_ACCESSORY_NONE
			accessory_list += list(SPRITE_ACCESSORY_NONE = none_entry)

	sprite_accessories[initial(prototype.key)] = temp_list
	sprite_accessory_keys[initial(prototype.key)] = both
	male_sprite_accessory_keys[initial(prototype.key)] = male
	female_sprite_accessory_keys[initial(prototype.key)] = female

/// Hair Gradients - Initialise all /datum/sprite_accessory/hair_gradient into an list indexed by gradient-style name
/datum/controller/subsystem/accessories/proc/init_gradients()
	var/list/hair_gradients = list()
	var/list/facial_hair_gradients = list()
	sprite_accessories[ACCESSORY_HAIR_GRADIENT] = hair_gradients
	sprite_accessories[ACCESSORY_FACIAL_HAIR_GRADIENT] = facial_hair_gradients
	for(var/path in subtypesof(/datum/sprite_accessory/gradient))
		var/datum/sprite_accessory/gradient/gradient = new path()
		if(gradient.gradient_category  & GRADIENT_APPLIES_TO_HAIR)
			hair_gradients[gradient.name] = gradient
		if(gradient.gradient_category & GRADIENT_APPLIES_TO_FACIAL_HAIR)
			facial_hair_gradients[gradient.name] = gradient

/datum/controller/subsystem/accessories/proc/get_random_accessory_name(datum/sprite_accessory/base_datum, gender)
	var/key = initial(base_datum.key)
	if(!key)
		CRASH("Bad key for get_random! [base_datum]")

	switch(gender)
		if(MALE)
			return pick(male_sprite_accessory_keys[key])
		if(FEMALE)
			return pick(female_sprite_accessory_keys[key])
		else
			return pick(sprite_accessory_keys[key])

/datum/controller/subsystem/accessories/proc/get_accessory(datum/sprite_accessory/base_datum, accessory)
	RETURN_TYPE(/datum/sprite_accessory)
	var/key = initial(base_datum.key)
	if(!key)
		CRASH("Bad key for get_accessory! [base_datum]")

	var/list/accessories = sprite_accessories[key]
	return accessories[accessory]

/datum/controller/subsystem/accessories/proc/get_accessory_list(datum/sprite_accessory/base_datum, gender)
	RETURN_TYPE(/list)
	var/key = initial(base_datum.key)
	if(!key)
		CRASH("Bad key for get_accessory_list! [base_datum]")

	switch(gender)
		if(MALE)
			return male_sprite_accessory_keys[key]
		if(FEMALE)
			return female_sprite_accessory_keys[key]
		else
			return sprite_accessory_keys[key]


/datum/controller/subsystem/accessories/proc/random_features(gender)
	//For now we will always return none for tail_human and ears. | "For now" he says.
	return(list(
		"mcolor" = "#[pick("7F","FF")][pick("7F","FF")][pick("7F","FF")]",
		MUTANT_TAIL = "None",
		"tail_lizard" = "Smooth",
		"wings" = "None",
		"snout" = get_random_accessory_name(/datum/sprite_accessory/snouts, gender),
		"horns" = get_random_accessory_name(/datum/sprite_accessory/horns, gender),
		"ears" = "None",
		"frills" = get_random_accessory_name(/datum/sprite_accessory/frills, gender),
		"spines" = get_random_accessory_name(/datum/sprite_accessory/spines, gender),
		"body_markings" = get_random_accessory_name(/datum/sprite_accessory/body_markings, gender),
		"legs" = "Normal Legs",
		"caps" = get_random_accessory_name(/datum/sprite_accessory/caps, gender),
		"moth_wings" = get_random_accessory_name(/datum/sprite_accessory/moth_wings, gender),
		"moth_antennae" = get_random_accessory_name(/datum/sprite_accessory/moth_antennae, gender),
		"moth_markings" = get_random_accessory_name(/datum/sprite_accessory/moth_markings, gender),
		"pod_hair" = get_random_accessory_name(/datum/sprite_accessory/pod_hair, gender),
		MUTANT_SYNTH_SCREEN = get_random_accessory_name(/datum/sprite_accessory/screen, gender),
		MUTANT_SYNTH_ANTENNA = get_random_accessory_name(/datum/sprite_accessory/antenna, gender),
		MUTANT_SYNTH_HEAD = get_random_accessory_name(/datum/sprite_accessory/synth_head, gender),
		MUTANT_SYNTH_CHASSIS = get_random_accessory_name(/datum/sprite_accessory/synth_chassis, gender),
	))

/datum/controller/subsystem/accessories/proc/get_length(key, gender)
	switch(gender)
		if(MALE)
			return length(male_sprite_accessory_keys[key])
		if(FEMALE)
			return length(female_sprite_accessory_keys[key])
		else
			return length(sprite_accessories[key])

/datum/controller/subsystem/accessories/proc/find_entry(key, value)
	var/list/accessory_list = sprite_accessory_keys[key]

	if(!accessory_list)
		return 0

	return accessory_list.Find(value)
