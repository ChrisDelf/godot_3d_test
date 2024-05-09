extends Node3D
class_name  WeaponParent

@export var weapon_name: String
@export var activate_anim: String
@export var hip_fire: String
@export var reload_anim: String
@export var deactivate_anim: String
@export var out_of_ammo_anim: String
@export var run_animation: String
@export var walk_animation: String


@export var current_ammo: int
@export var resrve_ammo: int
@export var magazine: int
@export var max_ammo: int

@export var auto_fire: bool

func reload():
	pass
	




