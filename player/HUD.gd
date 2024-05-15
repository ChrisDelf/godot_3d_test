extends CanvasLayer

@onready var current_weapon_label = $VBoxContainer/CurrentWeaponContainer/CurrentWeapon
@onready var current_ammo = $VBoxContainer/AmmoContainer/CurrentAmmo
@onready var current_weapon_stack = $VBoxContainer/WeaponStackContainer/WeaponStack
@onready var current_player_stance =$VBoxContainer/StanceContainer/PlayerStance


#func _ready():
	#current_weapon_label.text = Globals.current_weapon
	#
	#var ammo = Globals.ammo_list
#
	#if len(ammo) != 0:
		#current_ammo.set_text(str(ammo[0])+ " / "+ str(ammo[1]))
	#
	#var weapon_stack = Globals.weapon_stack
	#
	#current_weapon_stack.set_text("")
	#for weapon in weapon_stack:
		#current_weapon_stack.text += "\n" + weapon
#
func _process(_delta):
	current_weapon_label.text = Globals.current_weapon
	
	var ammo = Globals.ammo_list

	if len(ammo) != 0:
		current_ammo.set_text(str(ammo[0])+ " / "+ str(ammo[1]))
	
	var weapon_stack = Globals.weapon_stack
	
	current_weapon_stack.set_text("")
	for weapon in weapon_stack:
		current_weapon_stack.text += "\n" + weapon
	
	current_player_stance.text = Globals.player_state






func _on_weapon_holder_weapon_change(weapon_name):
	current_weapon_label.text = weapon_name


func _on_weapon_holder_update_weapon_ammo_enter(ammo):
	if len(ammo) != 0 && current_ammo != null:
		current_ammo.set_text(str(ammo[0])+ " / "+ str(ammo[1]))


func _on_weapon_holder_update_stack(weapon_stack):
	if current_weapon_stack != null:
		current_weapon_stack.set_text("")
		for weapon in weapon_stack:
			current_weapon_stack.text += "\n" + weapon


func _on_weapon_holder_update_dict():
	pass # Replace with function body.
