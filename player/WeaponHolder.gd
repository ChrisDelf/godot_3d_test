extends Node3D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var current_weapon = null
var weapon_stack = [] # the array of weapons that I have
var weapon_indicator = 0
var weapon_list = {}
var next_weapon: String

signal weapon_change
signal update_weapon_ammo_enter
signal update_stack
signal update_dict
signal update_current_weapon
@export var _weapon_resources: Array[Node3D]

@export var _start_weapons: Array[String]


func _ready():
	initialize(_start_weapons) #enter and new state machine
	
	

func _input(event):
	if event.is_action_pressed("weapon_up"):
		weapon_indicator = min(weapon_indicator+1, weapon_stack.size()-1)
		exit(weapon_stack[weapon_indicator])
		
	if event.is_action_pressed("weapon_down"):
		weapon_indicator = max(weapon_indicator-1, 0)
		exit(weapon_stack[weapon_indicator])
	
func initialize(start_weapons: Array):
	#creating a dictionary to store our weapons
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
	for i in start_weapons:
		weapon_stack.push_back(i) # string reference to our start weapons
	
	current_weapon = weapon_list[weapon_stack[0]]
	Globals.weapon_stack = weapon_stack
	Globals.weapon_dict = weapon_list
	emit_signal("update_stack", weapon_stack)
	if weapon_list != null:
		emit_signal("update_dict", weapon_list)
	
	enter()

func enter():
	animation_player.queue(current_weapon.activate_anim)
	Globals.current_weapon = current_weapon


func exit(_next_weapon: String):
	#in order to change weapons first call exit
	if _next_weapon != current_weapon.weapon_name:
		if animation_player.get_current_animation() != current_weapon.deactivate_anim:
			animation_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon
	
func change_weapon(weapon_name: String):
	current_weapon = weapon_list[weapon_name]
	emit_signal("weapon_change", current_weapon)
	next_weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)
		
		

