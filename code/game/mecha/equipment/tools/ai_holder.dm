/obj/item/mecha_parts/mecha_equipment/tool/ai_holder
	name = "AI holder"
	desc = "AI holder - allowed AI control exo-suits."
	icon_state = "ai_holder"
	origin_tech = list(TECH_POWER = 3, TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 20, MATERIAL_GLASS = 3)
	energy_drain = 2
	equip_cooldown = 20
	salvageable = 0
	var/obj/machinery/camera/Cam = null
	var/mob/living/silicon/ai/occupant = null

/obj/item/mecha_parts/mecha_equipment/tool/ai_holder/proc/go_out()
	chassis.occupant = null
	chassis.update_icon()
	occupant.remove_mecha_verbs()
	occupant.set_mecha(null)
	if(occupant.eyeobj)
		occupant.eyeobj.setLoc(chassis)
	else
		occupant.create_eyeobj(get_turf(src))
	occupant = null
	occupant << "Exiting AI holder..."

/obj/item/mecha_parts/mecha_equipment/tool/ai_holder/interact(var/mob/living/silicon/ai/user)
	if(!chassis)
		return
	if(occupant)
		//OC exist
		if(occupant == user)
			go_out()
		else
			user << "Controller is already occupied!"
	else
		if(isAI(user))
			user << "Entering AI holder..."
			user.set_mecha(chassis)
			occupant = user
			chassis.occupant = occupant
			chassis.update_icon()
			user.add_mecha_verbs()

/obj/item/mecha_parts/mecha_equipment/tool/ai_holder/attach()
	..()
	Cam = new
	Cam.c_tag = chassis.name
	if(occupant)
		occupant << "Attaching to AI holder..."

/obj/item/mecha_parts/mecha_equipment/tool/ai_holder/detach()
	if(occupant)
		occupant << "Detaching from AI holder..."
		go_out()
	qdel(Cam)


/obj/mecha/attack_ai(var/mob/living/user)
	var/obj/item/mecha_parts/mecha_equipment/tool/ai_holder/AH = locate() in src
	if(AH)
		if (ishuman(user))
			user << "You poke the AI holder."
		else
			user << "Interacting with AI holder..."
		AH.interact(user)

/mob/living/silicon/ai/proc/set_mecha(var/obj/mecha/M)
	if(M)
		destroy_eyeobj(M)
		if(controlled_mech == M)
			src << "Your AI holder already controls the mech..."
			return

	if(controlled_mech)
		src << "AI holder is releasing control of the mech..."
		controlled_mech.go_out()

	if(M)
		controlled_mech = M
		src << "AI holder is assuming control of the mech..."
		M.moved_inside(src)
