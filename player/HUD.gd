extends CanvasLayer

@onready var current_weapon_label = $Hud/VBoxContainer/CurrentWeaponContainer/CurrentWeapon
@onready var current_ammo = $Hud/VBoxContainer/AmmoContainer/CurrentAmmo
@onready var current_weapon_stack = $Hud/VBoxContainer/WeaponStackContainer/WeaponStack
@onready var current_player_stance = $Hud/VBoxContainer/StanceContainer/PlayerStance

func _ready():
	current_weapon_label.text = Globals.current_weapon
	
	var ammo = Globals.ammo_list

	if len(ammo) != 0:
		current_ammo.set_text(str(ammo[0])+ " / "+ str(ammo[1]))
	
	var weapon_stack = Globals.weapon_stack
	
	current_weapon_stack.set_text("")
	for weapon in weapon_stack:
		current_weapon_stack.text += "\n" + weapon

func _process(_delta):
	current_weapon_label.text = Globals.current_weapon
	
	var ammo = Globals.ammo_list

	if len(ammo) != 0:
		current_ammo.set_text(str(ammo[0])+ " / "+ str(ammo[1]))
	
	var weapon_stack = Globals.weapon_stack
	
	current_weapon_stack.set_text("")
	for weapon in weapon_stack:
		current_weapon_stack.text += "\n" + weapon




