extends WeaponParent


func _ready():
	var ammo_list = []
	ammo_list.append(current_ammo)
	ammo_list.append(reserve_ammo)
	Globals.ammo_list = ammo_list
	
