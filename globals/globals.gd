extends Node
signal stat_change

var player_health: = 100:
	set(value):
		player_health = value
		stat_change.emit()
var player_state: = "idle":
	set(value):
		player_state = value
		stat_change.emit()
var current_weapon: = "unarmed":
	set(value):
		current_weapon = value
		stat_change.emit()
		emit_signal("stat_change")
var weapon_stack: = []:
	set(value):
		weapon_stack = value
		stat_change.emit()
		emit_signal("stat_change")
var ammo_list: = []:
	set(value):
		ammo_list = value
		stat_change.emit()
		emit_signal("stat_change")
var weapon_dict: = {}:
	set(value):
		weapon_dict = value
		stat_change.emit()
		emit_signal("stat_change")

		
		

		
	





