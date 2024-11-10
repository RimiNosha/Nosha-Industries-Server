/**
 * Non-processing subsystem that holds various procs and data structures to manage ID cards, trims and access.
 */
SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of access names. Keys are access levels. Values are their associated names.
	var/list/access_to_name = ALL_ACCESS_NAMES
	/// Helper list containing all PDA paths that can be painted by station machines.
	var/list/station_pda_templates = list()
	/// Helper list containing all regions that the station can normally see and modify.
	var/list/station_regions = list()
	/// Specially formatted list for sending access levels to tgui interfaces.
	var/list/all_region_access_tgui = list()

	/// List of accesses for the Heads of each sub-department alongside the regions they control and their job name.
	var/list/sub_department_managers_tgui = list(
		ACCESS_SPECIAL_CAPTAIN = list(
			"regions" = list(ACCESS_REGION_COMMAND_NAME),
			"head" = JOB_CAPTAIN,
			"templates" = list(),
			"pdas" = list(),
		),
		ACCESS_COMMAND_HIGHSEC = list(
			"regions" = list(ACCESS_REGION_SERVICE_NAME, ACCESS_REGION_CARGO_NAME),
			"head" = JOB_HEAD_OF_PERSONNEL,
			"templates" = list(),
			"pdas" = list(),
		),
		ACCESS_SECURITY_HEAD = list(
			"regions" = list(ACCESS_REGION_SECURITY_NAME),
			"head" = JOB_HEAD_OF_SECURITY,
			"templates" = list(),
			"pdas" = list(),
		),
		ACCESS_MEDICAL_HEAD = list(
			"regions" = list(ACCESS_REGION_MEDICAL_NAME),
			"head" = JOB_CHIEF_MEDICAL_OFFICER,
			"templates" = list(),
			"pdas" = list(),
		),
		ACCESS_ENGINEERING_HEAD = list(
			"regions" = list(ACCESS_REGION_ENGINEERING_NAME),
			"head" = JOB_CHIEF_ENGINEER,
			"templates" = list(),
			"pdas" = list(),
		),
		ACCESS_CARGO_HEAD = list(
			"regions" = list(ACCESS_REGION_CARGO_NAME),
			"head" = JOB_QUARTERMASTER,
			"templates" = list(),
			"pdas" = list(),
		),
		ACCESS_PATHFINDERS_HEAD = list(
			"regions" = list(ACCESS_REGION_PATHFINDERS_NAME),
			"head" = JOB_PATHFINDER_LEAD,
			"templates" = list(),
			"pdas" = list(),
		),
	)

	/// Region to access. Shrimple. Any access not on this list cannot be accessed without VV!
	var/list/region_name_to_accesses = list(
		ACCESS_REGION_STATION_HEADS_NAME = ACCESS_REGION_STATION_HEADS,
		ACCESS_REGION_COMMAND_NAME = ACCESS_REGION_COMMAND,
		ACCESS_REGION_ENGINEERING_NAME = ACCESS_REGION_ENGINEERING,
		ACCESS_REGION_MEDICAL_NAME = ACCESS_REGION_MEDICAL,
		ACCESS_REGION_PATHFINDERS_NAME = ACCESS_REGION_PATHFINDERS,
		ACCESS_REGION_SECURITY_NAME = ACCESS_REGION_SECURITY,
		ACCESS_REGION_SERVICE_NAME = ACCESS_REGION_SERVICE,
		ACCESS_REGION_CARGO_NAME = ACCESS_REGION_CARGO,
		ACCESS_REGION_CENTCOM_NAME = ACCESS_REGION_CENTCOM,
		ACCESS_REGION_SYNDICATE_NAME = ACCESS_REGION_SYNDICATE,
		ACCESS_REGION_AWAY_NAME = ACCESS_REGION_AWAY,
		ACCESS_REGION_SPECIAL_NAME = ACCESS_REGION_SPECIAL,
	)

	var/list/region_name_to_color = list(
		ACCESS_REGION_COMMAND_NAME = COLOR_COMMAND_BLUE,
		ACCESS_REGION_ENGINEERING_NAME = COLOR_ENGINEERING_ORANGE,
		ACCESS_REGION_MEDICAL_NAME = COLOR_MEDICAL_BLUE,
		ACCESS_REGION_PATHFINDERS_NAME = COLOR_PATHFINDERS_PURPLE,
		ACCESS_REGION_SECURITY_NAME = COLOR_SECURITY_RED,
		ACCESS_REGION_SERVICE_NAME = COLOR_SERVICE_LIME,
		ACCESS_REGION_CARGO_NAME = COLOR_CARGO_BROWN,
		ACCESS_REGION_CENTCOM_NAME = COLOR_CENTCOM_BLUE,
		ACCESS_REGION_SYNDICATE_NAME = COLOR_SYNDIE_RED,
		ACCESS_REGION_AWAY_NAME = COLOR_LIGHT_GRAYISH_RED,
		ACCESS_REGION_SPECIAL_NAME = COLOR_SOAPSTONE_GOLD,
	)

	/// A list of ID manufacturers to regions that they natively can access. These DO NOT prevent IDs from gaining accesses not inside these via non-ID-console means!
	var/list/manufacturer_to_region_names = list(
		ID_MANUFACTURER_UNKNOWN = list(), // These can't be edited. Oh no!
		ID_MANUFACTURER_ARTEA = list(
			ACCESS_REGION_STATION_HEADS_NAME,
			ACCESS_REGION_COMMAND_NAME,
			ACCESS_REGION_ENGINEERING_NAME,
			ACCESS_REGION_MEDICAL_NAME,
			ACCESS_REGION_PATHFINDERS_NAME,
			ACCESS_REGION_SECURITY_NAME,
			ACCESS_REGION_SERVICE_NAME,
			ACCESS_REGION_CARGO_NAME,
			ACCESS_REGION_CENTCOM_NAME,
		),
		ID_MANUFACTURER_SYNDICATE = list( // Syndie and darkof IDs can be given normal station (but not centcom) accesses freely.
			ACCESS_REGION_STATION_HEADS_NAME,
			ACCESS_REGION_COMMAND_NAME,
			ACCESS_REGION_ENGINEERING_NAME,
			ACCESS_REGION_MEDICAL_NAME,
			ACCESS_REGION_PATHFINDERS_NAME,
			ACCESS_REGION_SECURITY_NAME,
			ACCESS_REGION_SERVICE_NAME,
			ACCESS_REGION_CARGO_NAME,
			ACCESS_REGION_SYNDICATE_NAME,
		),
		ID_MANUFACTURER_DARKOF = list(
			ACCESS_REGION_STATION_HEADS_NAME,
			ACCESS_REGION_COMMAND_NAME,
			ACCESS_REGION_ENGINEERING_NAME,
			ACCESS_REGION_MEDICAL_NAME,
			ACCESS_REGION_PATHFINDERS_NAME,
			ACCESS_REGION_SECURITY_NAME,
			ACCESS_REGION_SERVICE_NAME,
			ACCESS_REGION_CARGO_NAME,
			ACCESS_REGION_SYNDICATE_NAME,
		),
	)

	/// A list of accesses that are silver ID only.
	/// **NOTE**: Before the subsystem initializes, this is a mixed list of regions and accesses, which are then converted.
	var/silver_accesses = list(
		ACCESS_REGION_STATION_HEADS_NAME,
		ACCESS_REGION_COMMAND_NAME,
	)

	/// The roundstart generated code for the spare ID safe. This is given to the Captain on shift start. If there's no Captain, it's given to the HoP. If there's no HoP
	var/spare_id_safe_code = ""

/datum/controller/subsystem/id_access/Initialize()
	// Look man, I don't want to hardcode every single access if I don't have to.
	var/silver_access_regions = silver_accesses
	silver_accesses = list()
	for(var/region in silver_access_regions)
		// If it's a valid region, slap the accesses inside.
		// If it's not, then uh- I hope it's an access!
		silver_accesses |= region_name_to_accesses[region] || region

	station_regions = manufacturer_to_region_names[ID_MANUFACTURER_ARTEA]
	station_regions = station_regions.Copy()
	station_regions.Remove(ACCESS_REGION_CENTCOM_NAME)

	spare_id_safe_code = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"

	var/list/all_pda_paths = typesof(/obj/item/modular_computer/pda)
	var/list/pda_regions = PDA_PAINTING_REGIONS
	for(var/pda_path in all_pda_paths)
		if(!(pda_path in pda_regions))
			continue

		var/list/region_whitelist = pda_regions[pda_path]
		for(var/access_txt in sub_department_managers_tgui)
			var/list/manager_info = sub_department_managers_tgui[access_txt]
			var/list/manager_regions = manager_info["regions"]
			for(var/whitelisted_region in region_whitelist)
				if(!(whitelisted_region in manager_regions))
					continue
				var/list/manager_pdas = manager_info["pdas"]
				var/obj/item/modular_computer/pda/fake_pda = pda_path
				manager_pdas[pda_path] = initial(fake_pda.name)
				station_pda_templates[pda_path] = initial(fake_pda.name)


	for(var/region in manufacturer_to_region_names[ID_MANUFACTURER_ARTEA])
		var/list/region_access = region_name_to_accesses[region]

		var/parsed_accesses = list()

		for(var/access in region_access)
			var/access_desc = access_to_name[access]
			if(!access_desc)
				continue

			parsed_accesses += list(list(
				"desc" = replacetext(access_desc, "&nbsp", " "),
				"ref" = access,
			))

		all_region_access_tgui[region] = list(list(
			"name" = region,
			"accesses" = parsed_accesses,
		))

	return SS_INIT_SUCCESS

/datum/controller/subsystem/id_access/proc/get_region_access_list(list/regions)
	var/list/accesses = list()

	for(var/region in regions)
		if(islist(region)) // Allow for being lazy with the defines to save lots of effort. Cursed? Maybe. Do I care much at this point? Nope. - Rimi
			for(var/access in get_region_access_list(region))
				accesses |= access

		var/list/temp_accesses = region_name_to_accesses[region]
		if(temp_accesses)
			for(var/access in temp_accesses)
				accesses |= access

	return accesses

/**
 * Applies a trim to a chameleon card. This is purely visual, utilising the card's override vars.
 *
 * Arguments:
 * * id_card - The chameleon card to apply the trim visuals to.
 * * trim_path - A trim path to apply to the card. Grabs the trim's associated singleton and applies it.
 * * check_forged - Boolean value. If TRUE, will not overwrite the card's assignment if the card has been forged.
 */
/datum/controller/subsystem/id_access/proc/apply_trim_to_chameleon_card(obj/item/card/id/advanced/chameleon/id_card, assignment, /datum/id_department/department, /datum/id_department/subdepartment, check_forged = TRUE)
	id_card.department_color_override = initial(department.color)
	id_card.department_state_override = initial(department.icon_state)
	id_card.subdepartment_color_override = initial(subdepartment.color)

	if(!check_forged || !id_card.forged)
		id_card.assignment = assignment

	// We'll let the chameleon action update the card's label as necessary instead of doing it here.

/**
 * Removes a trim from a chameleon ID card.
 *
 * Arguments:
 * * id_card - The ID card to remove the trim from.
 */
/datum/controller/subsystem/id_access/proc/remove_trim_from_chameleon_card(obj/item/card/id/advanced/chameleon/id_card)
	id_card.trim_icon_override = null
	id_card.trim_letter_state_override = null
	id_card.trim_assignment_override = null
	id_card.department_color_override = null
	id_card.department_state_override = null
	id_card.subdepartment_color_override = null
