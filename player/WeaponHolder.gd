extends Node3D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var current_weapon = null
var weapon_stack = [] # the array of weapons that I have
var weapon_indicator = 0
var weapon_list = {}

@export var _weapon_resources: Array[Node3D]

@export var start_weapons: Array[String]

func _ready():
	initialize(start_weapons) #enter and new state machine
	
func initialize(start_weapons):
	#creating a dictionary to store our weapons
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
	for i in start_weapons:
		weapon_stack.push_back(i) # string reference to our start weapons
	
	current_weapon = weapon_list[weapon_stack[0]]
	enter()

func enter():
	animation_player.queue(current_weapon.activate_anim)

func exit():
	#in order to change weapons first call exit
	pass
	
func change_weapon():
	pass
	
