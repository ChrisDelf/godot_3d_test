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
		
		if current_weapon.current_ammo > 0:
			fire()
		else:
			reload()
	
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
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])

func exit(_next_weapon: String):
	if _next_weapon != current_weapon.weapon_name:
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
			
			var camera_collision = get_camera_collision()
		
			match current_weapon.Type:
				NULL:
					print("A Weapon has not been Choosen")
				HITSCAN:
					hit_scan_collision(camera_collision)
				PROJECTILE:
					launch_projectile(camera_collision)
				
func reload():
	current_weapon.can_fire = false
	#grabbing my globals for the current ammo to update the reload

	
	var reload_amount = current_weapon.magazine - current_weapon.current_ammo
	#checking to see if we have enough ammo
	
	#normal reload
	if current_weapon.reserve_ammo > reload_amount:
		current_weapon.reserve_ammo -= reload_amount
		current_weapon.current_ammo += reload_amount

		emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
		animation_player.play(current_weapon.reload_anim)
		current_weapon.can_fire= true
	else:
		# if we truly have no ammo left
		if current_weapon.reserve_ammo == 0:
			current_weapon.can_fire= true
			return
		else:
			# we have less ammo than what a magazine could fill
			current_weapon.current_ammo += current_weapon.reserve_ammo
			current_weapon.reserve_ammo = 0
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
			animation_player.play(current_weapon.reload_anim)
			current_weapon.can_fire= true

func get_camera_collision()->Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	#getting the center of the screen
	var ray_origin = camera.project_ray_origin(viewport/2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport/2)*current_weapon.weapon_range

	
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
		
		collider.hit_successful(current_weapon.damage)

func launch_projectile(point: Vector3):
	
	var direction = (point - bullet_point.get_global_transform().origin).normalized()
	var projectile = current_weapon.projectile_to_load.instantiate()
	
	bullet_point.add_child(projectile)
	projectile.damage = current_weapon.damage
	projectile.set_linear_velocity(direction*current_weapon.projectile_velocity)
	
	
func _send_signal_to_weapon_stack_label(_label_node, stack):
	emit_signal("update_weapon_stack",  stack)
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)
		
	if anim_name == "rifleS_shoot":
		current_weapon.can_fire = true
		
	if anim_name == "blasterB2_shoot":
		current_weapon.can_fire = true
	


func _on_pick_up_detection_body_entered(body):
	print(body.pick_up_type)
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
				print("delete weapon on ground")
				body.queue_free()
		
			body.current_ammo = min(remaining, weapon_list[body.weapon_name].magazine)
			print(max(remaining - body.current_ammo, 0))
			body.reserve_ammo = max(remaining - body.current_ammo, 0)
			print(body.reserve_ammo)
			
		
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
	var weapon = 	weapon_list[_weapon]
	
	
	var required = weapon.max_ammo - weapon.reserve_ammo
	var remaining = max(ammo - required, 0)

	weapon.reserve_ammo += min(ammo, required)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
	print(remaining)
	return remaining
		
	
