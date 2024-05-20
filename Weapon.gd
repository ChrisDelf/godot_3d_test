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
@export_flags("HitScan", "Projectile") var Type
@export var weapon_range: int
@export var damage: int
@export var projectile_to_load: PackedScene
@export var projectile_velocity:int

enum {NULL,HITSCAN, PROJECTILE}

@onready var animation_player = $"../../AnimationPlayer"
@onready var bullet_point = $"../BulletMarker"

var debug_bullet = preload("res://weapon_resources/bullet_debug.tscn")

func _ready():
	can_fire = true




func _physics_process(_delta):
	if !Globals.current_weapon == null:
		if Globals.current_weapon.name == weapon_name:
			if Input.is_action_just_pressed("reload"):
				if can_fire:
					reload()

			if Input.is_action_pressed("primary action"):
				if can_fire:
					
					if current_ammo > 0:
						fire()
					else:
						reload()

func reload():
	can_fire = false
	#grabbing my globals for the current ammo to update the reload
	var temp_array = Globals.ammo_list
	
	reserve_ammo = temp_array[1]
	current_ammo = temp_array[0]
	
	var reload_amount = magazine - current_ammo
	#checking to see if we have enough ammo
	
	#normal reload
	if reserve_ammo > reload_amount:
		reserve_ammo -= reload_amount
		current_ammo += reload_amount

		update_ammo()
		animation_player.play(reload_anim)
		can_fire= true
	else:
		# if we truly have no ammo left
		if reserve_ammo == 0:
			can_fire= true
			return
		else:
			# we have less ammo than what a magazine could fill
			current_ammo += reserve_ammo
			reserve_ammo = 0
			update_ammo()
			animation_player.play(reload_anim)
			can_fire= true

func fire():
	if !animation_player.is_playing():
		can_fire = false
		animation_player.play(hip_fire)
		current_ammo -= 1
		update_ammo()
		var camera_collision = get_camera_collision()
		
		match Type:
			NULL:
				print("A Weapon has not been Choosen")
			HITSCAN:
				hit_scan_collision(camera_collision)
			PROJECTILE:
				launch_projectile(camera_collision)
			
			


func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			update_ammo()
			
func update_ammo():
			var ammo_list = [current_ammo,reserve_ammo ]
			Globals.ammo_list = ammo_list

func get_camera_collision()->Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	#getting the center of the screen
	var ray_origin = camera.project_ray_origin(viewport/2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport/2)*weapon_range

	
	#now we create ray from the gun to the center of the screen
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)

	if not intersection.is_empty():
		#hitscan
		var col_point = intersection.position
		
		return col_point
	else:
		#projectile
		return ray_end

func hit_scan_collision(collision_point):
	var bullet_direction = (collision_point - bullet_point.get_global_transform().origin).normalized()
	var new_intersection = PhysicsRayQueryParameters3D.create(bullet_point.get_global_transform().origin,collision_point+bullet_direction*2)

	#pulling the mesh form the 3d world to see if we hit anything
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	if bullet_collision:
		#instantiating a bullet hit
		var hit_indicator = debug_bullet.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(hit_indicator)
		hit_indicator.global_translate(bullet_collision.position)
		
		hit_scan_damage(bullet_collision.collider)
		
	

func hit_scan_damage(collider):
	if collider.is_in_group("Targets") and collider.has_method("hit_successful"):
		
		collider.hit_successful(damage)

func launch_projectile(point: Vector3):
	
	var direction = (point - bullet_point.get_global_transform().origin).normalized()
	var projectile = projectile_to_load.instantiate()
	
	bullet_point.add_child(projectile)
	projectile.damage = damage
	projectile.set_linear_velocity(direction*projectile_velocity)

