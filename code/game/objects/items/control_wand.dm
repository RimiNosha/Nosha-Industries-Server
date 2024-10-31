#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "gangtool-white"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	/// The manufacturer controls which faction's doors can be opened.
	var/access_manufacturer = ID_MANUFACTURER_ARTEA
	/// What regions does this have access over? Every remote can open unrestricted doors. Can be a list or a single region.
	var/region_access
	var/list/access_list

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = SSid_access.get_region_access_list(region_access)

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/desc = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	balloon_alert(user, "mode: [desc[mode]]")

// Airlock remote works by sending NTNet packets to whatever it's pointed at.
/obj/item/door_remote/afterattack(atom/target, mob/user)
	. = ..()

	var/obj/machinery/door/door

	if (istype(target, /obj/machinery/door))
		door = target

		if (!door.opens_with_door_remote)
			return
	else
		for (var/obj/machinery/door/door_on_turf in get_turf(target))
			if (door_on_turf.opens_with_door_remote)
				door = door_on_turf
				break

		if (isnull(door))
			return

	// Don't allow this to work where it shouldn't!
	var/area/area = get_area(target)
	if(!area.allow_door_remotes)
		balloon_alert(user, "no connection!")
		return

	if (!door.check_access(access_list) || !door.requiresID())
		target.balloon_alert(user, "can't access!")
		return

	var/obj/machinery/door/airlock/airlock = door

	if (!door.hasPower() || (istype(airlock) && !airlock.canAIControl()))
		target.balloon_alert(user, mode == WAND_OPEN ? "it won't budge!" : "nothing happens!")
		return

	switch (mode)
		if (WAND_OPEN)
			if (door.density)
				door.open()
			else
				door.close()
		if (WAND_BOLT)
			if (!istype(airlock))
				target.balloon_alert(user, "only airlocks!")
				return

			if (airlock.locked)
				airlock.unbolt()
			else
				airlock.bolt()
		if (WAND_EMERGENCY)
			if (!istype(airlock))
				target.balloon_alert(user, "only airlocks!")
				return

			airlock.emergency = !airlock.emergency
			airlock.update_appearance(UPDATE_ICON)

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = ACCESS_REGION_GROUP_STATION

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = ACCESS_REGION_COMMAND_NAME

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = ACCESS_REGION_ENGINEERING_NAME

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = ACCESS_REGION_PATHFINDERS_NAME

/obj/item/door_remote/pathfinders
	name = "pathfinders door remote"
	icon_state = "gangtool-purple"
	region_access = ACCESS_REGION_PATHFINDERS_NAME

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = ACCESS_REGION_SECURITY_NAME

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	icon_state = "gangtool-green"
	region_access = ACCESS_REGION_CARGO_NAME

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = ACCESS_REGION_MEDICAL_NAME

/obj/item/door_remote/civilian
	name = "civilian door remote"
	icon_state = "gangtool-white"

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
