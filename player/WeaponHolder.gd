extends Node3D
@onready var bullet_point = $BulletMarker
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var weapon_stack_label: Label = $"../Camera3D/CanvasLayer/VBoxContainer/WeaponStackContainer/WeaponStack"
var debug_bullet = preload("res://weapon_resources/bullet_debug.tscn")
var current_weapon = null
var weapon_stack = [] # the array of weapons that I have
#var weapon_indicator = 0
var weapon_list: = {}
var next_weapon: String
enum {NULL,HITSCAN, PROJECTILE}

@export var _weapon_resources: Array[weapon_resource]
@export var _start_weapons: Array[String]

signal weapon_changed
signal update_ammo
signal update_weapon_stack
signal weapon_swing



func _ready():
	initialize(_start_weapons) #enter and new state machine

func _input(event):
	if event.is_action_pressed("weapon_up"):	
		var get_ref = weapon_stack.find(current_weapon.weapon_name)
		get_ref = min(get_ref+1, weapon_stack.size()-1)
		exit(weapon_stack[get_ref])
		
	if event.is_action_pressed("weapon_down"):
		var get_ref = weapon_stack.find(current_weapon.weapon_name)
		get_ref = max(get_ref-1,0)
		exit(weapon_stack[get_ref])
	
	if event.is_action_pressed("drop"):
		drop(current_weapon.weapon_name)
	
func _physics_process(_delta):
	

	if Input.is_action_just_pressed("reload"):
		reload()

	if Input.is_action_pressed("primary action"):
		
		if current_weapon.current_ammo > 0 && !current_weapon.is_melee:
			fire()
		elif current_weapon.is_melee:
			attack()
		else:
			reload()
	if Input.is_action_pressed("Melee"):
		melee()
		
func attack():
	
	if !animation_player.is_playing():
		animation_player.play(current_weapon.hip_fire)
		emit_signal("weapon_swing")
		
		
func initialize(start_weapons: Array):
	
	#creates our dictionary for later use
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
		
	#pushing our weapons into our array
	for i in start_weapons:
		weapon_stack.push_back(i)
		
	# the first weapon in our stack and the first weapon we pull out
	current_weapon = weapon_list[weapon_stack[0]]
	call_deferred("_send_signal_to_weapon_stack_label", weapon_stack_label , weapon_stack)
	
	enter()
	
func enter():
	
	
	animation_player.queue(current_weapon.activate_anim)
	
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])	
	emit_signal("weapon_changed", current_weapon.weapon_name)

func exit(_next_weapon: String):
	if _next_weapon != current_weapon.weapon_name :
		if animation_player.get_current_animation() != current_weapon.deactivate_anim:
			
			animation_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon
			
	
func change_weapon(weapon_name: String):
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()

func fire():
	if current_weapon.current_ammo > 0:
		if !animation_player.is_playing():
			current_weapon.can_fire = false
			animation_player.play(current_weapon.hip_fire)
			current_weapon.current_ammo -= 1
			animation_player.play(current_weapon.hip_fire)
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
			
			var camera_collision = get_camera_collision(current_weapon.weapon_range)
			match current_weapon.Type:
				NULL:
					print("A Weapon has not been Choosen")
				HITSCAN:
					hit_scan_collision(camera_collision[1])
				PROJECTILE:
					launch_projectile(camera_collision[1])
				
func reload():
	#checking to make sure you don't reload an already full gun
	if current_weapon.current_ammo == current_weapon.magazine:
		return
	#make sure that no animtion are not playign
	if !animation_player.is_playing():
		if current_weapon.reserve_ammo != 0:
			animation_player.play(current_weapon.reload_anim)
		else:
			current_weapon.can_fire= true

func calculate_reload():
	current_weapon.can_fire = false
	#grabbing my globals for the current ammo to update the reload

	var reload_amount = current_weapon.magazine - current_weapon.current_ammo
	#checking to see if we have enough ammo
	if current_weapon.reserve_ammo > reload_amount:
			current_weapon.reserve_ammo -= reload_amount
			current_weapon.current_ammo += reload_amount
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
			current_weapon.can_fire= true
	else:	
		current_weapon.current_ammo += current_weapon.reserve_ammo
		current_weapon.reserve_ammo = 0
		emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
		current_weapon.can_fire= true

func melee():
	#we do not want to interrupt our animation if it is already a melee animation
	if animation_player.get_current_animation() != current_weapon.melee_anim:
		animation_player.play(current_weapon.melee_anim)
		var camera_collision = get_camera_collision(current_weapon.melee_range)
		if camera_collision[0]:
			var vector = (camera_collision[1] - bullet_point.get_global_transform().origin).normalized()
			hit_scan_damage(camera_collision[0],vector)
	
func get_camera_collision(_weapon_range)->Array:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()

	#getting the center of the screen
	var ray_origin = camera.project_ray_origin(viewport/2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport/2)*_weapon_range

	
	#now we create ray from the gun to the center of the screen
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)

	if not intersection.is_empty():
		#hitscan
		#var col_point = intersection.position
		var collision = [intersection.collider, intersection.position]
		return collision
	else:
		#projectile
		return [null,ray_end]

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
		
		hit_scan_damage(bullet_collision.collider, bullet_direction)

func hit_scan_damage(collider, vector):
	if collider.is_in_group("Targets") and collider.has_method("hit_successful"):
		collider.hit_successful(current_weapon.damage, "hitscan",vector)

func launch_projectile(point: Vector3):
	var direction = (point - bullet_point.global_transform.origin).normalized()
	var projectile = current_weapon.projectile_to_load.instantiate()
	projectile.damage = current_weapon.damage
	bullet_point.add_child(projectile)
	# Calculate rotation
	#print(direction.x)
	#projectile.look_at(direction.x, projectile.direction.y, projectile.direction.z, Vector3.UP)
	#var temp_rotation_degrees = Vector3(-90, 0, 0)
	#projectile.rotation =  temp_rotation_degrees

	projectile.set_position(bullet_point.global_transform.origin)
	projectile.set_linear_velocity(direction*100)
	
	
func _send_signal_to_weapon_stack_label(_label_node, stack):
	emit_signal("update_weapon_stack",  stack)
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)
		
	if anim_name == "rifleS_shoot":
		current_weapon.can_fire = true
		
	if anim_name == "blasterB2_shoot":
		current_weapon.can_fire = true
		
	if anim_name == current_weapon.reload_anim:
		calculate_reload()


func _on_pick_up_detection_body_entered(body):
	if body.is_pickup:
		#Checking to see if we already have the weapon in our inventory.
		var weapon_in_stack = weapon_stack.find(body.weapon_name, 0)
		if weapon_in_stack == -1 && body.pick_up_type == "Weapon":
			var get_ref = weapon_stack.find(current_weapon.weapon_name)
			weapon_stack.insert(get_ref, body.weapon_name)
			#zero out the ammo
			weapon_list[body.weapon_name].current_ammo = body.current_ammo
			weapon_list[body.weapon_name].reserve_ammo = body.reserve_ammo
			
			emit_signal("update_weapon_stack", weapon_stack)
			exit(body.weapon_name)
			body.queue_free()
		else:
			var remaining = add_ammo(body.weapon_name, body.current_ammo + body.reserve_ammo)
			if remaining == 0:
				body.queue_free()
		
			body.current_ammo = min(remaining, weapon_list[body.weapon_name].magazine)
			body.reserve_ammo = max(remaining - body.current_ammo, 0)
	
		
			
		
func drop(w_name: String):
	
	if weapon_list[w_name].is_droppable:
		# checking if the item in our inventory
		var weapon_ref = weapon_stack.find(w_name, 0)

		if weapon_ref != -1:
			# if so we are going to remove it from out weapon_stack or array
			weapon_stack.pop_at(weapon_ref)
			emit_signal("update_weapon_stack", weapon_stack)
			
			#we create the node the corresponds to the weapon being dropped
			var weapon_dropped = weapon_list[w_name].weapon_drop.instantiate()
			
			weapon_dropped.current_ammo = weapon_list[w_name].current_ammo
			weapon_dropped.reserve_ammo = weapon_list[w_name].reserve_ammo
			
			#now we need to set it's postion to the bullet_point that is at the end of our gun barrel.
			weapon_dropped.set_global_transform(bullet_point.get_global_transform())
			
			# now we need to add the weapon to the world first we need to get scene
			var world = get_tree().get_root().get_child(0)
			world.add_child(weapon_dropped)
			
			var get_ref = weapon_stack.find(current_weapon.weapon_name)
			get_ref = max(get_ref-1,0)
			exit(weapon_stack[get_ref])
		
func add_ammo(_weapon: String, ammo:int) -> int:
	var weapon = weapon_list[_weapon]
	
	
	var required = weapon.max_ammo - weapon.reserve_ammo
	var remaining = max(ammo - required, 0)

	weapon.reserve_ammo += min(ammo, required)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
	return remaining


	
