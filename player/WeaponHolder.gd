extends Node3D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var current_weapon = null
var weapon_stack = [] # the array of weapons that I have
var weapon_indicator = 0
var weapon_list = {}

@export var _weapon_resources: Array[Weapons_Resource]

@export var start_weapons: Array[String]
