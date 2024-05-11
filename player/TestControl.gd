extends Control

@onready var status_text = $StanceText
@onready var weapon_text = $WeaponText

func _process(_delta):
	status_text.text = Globals.player_state
	weapon_text.text = Globals.current_weapon
