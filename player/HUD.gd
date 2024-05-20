extends CanvasLayer

@onready var current_weapon_label = $VBoxContainer/CurrentWeaponContainer/CurrentWeapon
@onready var current_ammo = $VBoxContainer/AmmoContainer/CurrentAmmo
@onready var current_weapon_stack = $VBoxContainer/WeaponStackContainer/WeaponStack
@onready var current_player_stance =$VBoxContainer/StanceContainer/PlayerStance



func _physics_process(_delta):
	current_player_stance.text = Globals.player_state


func _on_weapon_holder_update_ammo(ammo):
	if current_weapon_stack != null:
		current_ammo.set_text(str(ammo[0] , "/" , ammo[1]))


func _on_weapon_holder_update_weapon_stack(weapon_stack):
	print("hello")
	if current_weapon_stack != null:
		current_weapon_stack.set_text("")
		for i in weapon_stack:
			print(i)
			current_weapon_stack.text += "\n" + i


func _on_weapon_holder_weapon_changed(weapon_name):
	if current_weapon_stack != null:
		current_weapon_label.set_text(weapon_name)
