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
@export var reserve_ammo: int
@export var magazine: int
@export var max_ammo: int

@export var auto_fire: bool
@export var can_fire: bool

@onready var animation_player = $"../../AnimationPlayer"

func _ready():
	can_fire = true




func _process(_delta):
	if Globals.current_weapon == weapon_name:
		if Input.is_action_pressed("reload"):
			if can_fire:
				print("reload")
	
		if Input.is_action_pressed("primary action"):
			if can_fire:
				
				if current_ammo > 0:
					fire()
				else:
					reload()

func reload():
	can_fire = false
	
	var reload_amount = reserve_ammo - current_ammo
	#checking to see if we have enough ammo
	if reserve_ammo > reload_amount:
		reserve_ammo -= reload_amount
		current_ammo = magazine
	else:
		if reserve_ammo == 0:
			print("no ammo left")
			can_fire= true
			return
			
		else:
			current_ammo = reserve_ammo
			current_ammo = 0

func fire():
	if !animation_player.is_playing():
		can_fire = false
		animation_player.play(hip_fire)
		current_ammo -= 1
		var ammo_list = []
		ammo_list.append(current_ammo)
		ammo_list.append(reserve_ammo)
		Globals.ammo_list = ammo_list








