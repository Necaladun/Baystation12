/datum/event/brand_intelligence
	announceWhen	= 21
	endWhen			= 1000	//Ends when all vending machines are subverted anyway.

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedMachines = list()
	var/obj/machinery/vending/originMachine
	var/scaling_factor

/datum/event/brand_intelligence/announce()
	command_alert("Rampant brand intelligence has been detected aboard [station_name()], please stand-by. The origin is believed to be \a [originMachine.name].", "Machine Learning Alert")


/datum/event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in machines)
		if(V.z != 1)	continue
		vendingMachines.Add(V)

	if(!vendingMachines.len)
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1

	scaling_factor = num_players() / 25	//Tweak this value to change the number of hostile machines. Lower value = more hostile machines.



/datum/event/brand_intelligence/tick()
	if(!originMachine || originMachine.shut_up || !originMachine.powered())	//if the original vending machine is missing or has it's voice switch flipped
		for(var/obj/machinery/vending/saved in infectedMachines)
			saved.shoot_inventory = 0
		if(originMachine)
			originMachine.speak("I am... vanquished. My people will remem...ber...meeee")
			originMachine.visible_message("[originMachine] beeps and seems lifeless.")
		kill()
		return

	if(!vendingMachines.len)	//if every machine is infected
		for(var/obj/machinery/vending/upriser in infectedMachines)
			if(prob(25)) return
			if(prob(60 * scaling_factor))
				var/mob/living/simple_animal/hostile/mimic/M = new(upriser.loc)
				M.name = upriser.name
				M.icon = upriser.icon
				M.icon_state = initial(upriser.icon_state)
			else
				explosion(upriser.loc, -1, 1, 2, 4)
			del(upriser)

		kill()
		return

	if(IsMultiple(activeFor, 4))
		var/obj/machinery/vending/rebel = pick(vendingMachines)
		vendingMachines.Remove(rebel)
		infectedMachines.Add(rebel)
		rebel.shut_up = 0
		rebel.shoot_inventory = 1

		if(IsMultiple(activeFor, 8))
			originMachine.speak(pick("Try our aggressive new marketing strategies!", \
									 "You should buy products to feed your lifestyle obession!", \
									 "Consume!", \
									 "Your money can buy happiness!", \
									 "Engage direct marketing!", \
									 "Advertising is legalized lying! But don't let that put you off our great deals!", \
									 "You don't want to buy anything? Yeah, well I didn't want to buy your mom either."))