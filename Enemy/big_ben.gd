extends CharacterBody3D

const SPEED = 3.0
const ATTACK_RANGE = 30
const MAX_DISTANCE: float = 100.0
var player = null
var health = 20
#creating state machine for animations
var state_machine
var is_dead = false
var rotationSpeed: float = 10.0
var is_los = false
#var projectile_to_load = preload("res://Enemy/enemy_bullet.tscn")
var projectile_to_load = preload("res://weapon_resources/bullet.tscn")
@onready var player_path: = $"../../Player"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var bullet_point = $Armature/Marker3D
@onready var vision_raycast = $VisionRaycast
@onready var vision_area = $VisionArea




# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_path
	state_machine = anim_tree.get("parameters/playback")
func _process(delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
			"run":
				##navigation
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point = nav_agent.get_next_path_position()
				##getting the direction of player
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
				##smoothing out the turning
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
				##we want to look at the direction that we are moving
			"cast_finished":
				##looking directly at the player
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	#Conditions
	if !is_los:
		anim_tree.set("parameters/conditions/is_run", !_target_in_range())
	
	
	move_and_slide()

	
	

func _target_in_range():
	if global_position.distance_to(player.global_position) <= ATTACK_RANGE && is_los:
		return true
	elif is_los == false:
		return false
	else:
		return false
		
		
		
		
		
func _fire_ball():
	if is_los:
		print("fire_ball")
		launch_projectile(player.get_global_transform().origin)


func launch_projectile(point: Vector3):
	var direction = (point - bullet_point.get_global_transform().origin).normalized()
	var projectile = projectile_to_load.instantiate()
	bullet_point.add_child(projectile)
	#projectile.look_at(Vector3(direction.x, direction.y + .1, direction.z),Vector3.UP)
	projectile.set_linear_velocity(Vector3(direction.x, direction.y + .1, direction.z) * 45)

	


func _on_vision_timer_timeout():
	var overlaps = vision_area.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				var player_position = overlap.global_transform.origin
				var temp_vector3 = Vector3(player_position.x,player_position.y + 1, player_position.z)
				vision_raycast.look_at(temp_vector3, Vector3.UP)
				vision_raycast.force_raycast_update()
				if vision_raycast.is_colliding():
					var collider = vision_raycast.get_collider()
					if collider.name == "Player":
						#print("I see you")
						is_los = true
						anim_tree.set("parameters/conditions/is_in_range", _target_in_range())
						anim_tree.set("parameters/conditions/is_run", false)
						anim_tree.set("parameters/conditions/idle", false)
						return
					else:
						#print("where did you go")
						is_los = false
						anim_tree.set("parameters/conditions/is_run", true)
						anim_tree.set("parameters/conditions/is_in_range", false)
						anim_tree.set("parameters/conditions/idle", false)
			else:
				anim_tree.set("parameters/conditions/is_run", true)
				anim_tree.set("parameters/conditions/is_in_range", false)
				anim_tree.set("parameters/conditions/idle", false)





func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "cast_finished":
		anim_tree.set("parameters/conditions/idle", true)
		anim_tree.set("parameters/conditions/is_in_range", false)
		anim_tree.set("parameters/conditions/is_run", false)
	if anim_name == "idle" && _target_in_range() == false:
		anim_tree.set("parameters/conditions/idle", false)
		anim_tree.set("parameters/conditions/is_in_range", false)
		anim_tree.set("parameters/conditions/is_run", false)
	if anim_name == "idle" && _target_in_range() == true:
		anim_tree.set("parameters/conditions/is_in_range", true)
		anim_tree.set("parameters/conditions/idle", false)
		anim_tree.set("parameters/conditions/is_run", false)

