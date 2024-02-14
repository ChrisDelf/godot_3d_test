extends WeaponParent

var active_weapon: bool = false
var ammo_in_mag: int = 15
var can_fire: bool = true

func _process(delta):
	if active_weapon:
		if Input.is_action_just_pressed("reload"):
			if can_fire:
				reload()
	if Input.is_action_just_pressed("fire"):
		if can_fire:
			if ammo_in_mag > 0:
				print("fire")
				ammo_in_mag -= 1
			else:
				reload()
				
			
