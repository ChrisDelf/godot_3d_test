extends WeaponParent

@onready var can_fire = true
@onready var active_weapon = true


func _proccess(delta):
	if active_weapon:
		if Input.is_action_just_pressed("reload"):
			if can_fire:
				print("reload")
	
		if Input.is_action_just_pressed("primary action"):
			if can_fire:
				if current_ammo > 0:
					print("fire")
				else:
					print("reload")

func reload():
	can_fire = false
	
	var reload_amount = reserve_ammo - current_ammo
	#checking to see if we have enough ammo
	if reserve_ammo > reload_amount:
		reserve_ammo -= reload_amount
		current_ammo = magazine
	else:
		if reserve_ammo == 0:
			print("no ammo left")
			can_fire= true
			return
			
		else:
			current_ammo = reserve_ammo
			current_ammo = 0
	
	
	
func fire():
	can_fire = false
	current_ammo -= 1
	print("ammo in gun: ", current_ammo)
		
	
	
	
	
