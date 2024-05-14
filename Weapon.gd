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

#signal update_ammo

func _ready():
	can_fire = true




func _process(_delta):
	if Globals.current_weapon == weapon_name:
		if Input.is_action_just_pressed("reload"):
			if can_fire:
				reload()
	
		if Input.is_action_pressed("primary action"):
			if can_fire:
				
				if current_ammo > 0:
					fire()
				else:
					update_ammo()
					reload()

func reload():
	can_fire = false
	print(reserve_ammo, "/current ammo ", current_ammo)
	#grabbing my globals for the current ammo to update the reload
	var temp_array = Globals.ammo_list
	print("temp_array", temp_array)
	reserve_ammo = temp_array[1]
	current_ammo = temp_array[0]
	var reload_amount = magazine - current_ammo
	#checking to see if we have enough ammo
	if reserve_ammo > reload_amount:
		
		reserve_ammo -= reload_amount
	
		current_ammo += reload_amount
		animation_player.play(reload_anim)
	
		update_ammo()
		can_fire= true
		
	else:
		
		if reserve_ammo == 0:
			print("no ammo left")
			can_fire= true
			return
			
		else:
			current_ammo += reload_amount
			reserve_ammo = 0
			update_ammo()
			can_fire= true

func fire():
	if !animation_player.is_playing():
		can_fire = false
		animation_player.play(hip_fire)
		current_ammo -= 1
		print(current_ammo)
		update_ammo()


func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			update_ammo()
			
func update_ammo():
			var ammo_list = [current_ammo,reserve_ammo ]
			Globals.ammo_list = ammo_list






