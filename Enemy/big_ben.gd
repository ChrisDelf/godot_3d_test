extends CharacterBody3D

const SPEED = 3.0
const ATTACK_RANGE = 2.5
const MAX_DISTANCE: float = 100.0
var player = null
var health = 20
#creating state machine for animations
var state_machine
var is_dead = false

@export var player_path: = "/root/Test_area/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var marker = $MarkerFire
@onready var vision_raycast = $VisionRaycast
@onready var vision_area = $VisionArea



# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func _process(delta):
	pass
	#velocity = Vector3.ZERO

		
		
	#match state_machine.get_current_node():
			#"run":
				##navigation
				#nav_agent.set_target_position(player.global_transform.origin)
				#var next_nav_point = nav_agent.get_next_path_position()
				##getting the direction of player
				#velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
				##smoothing out the turning
				#rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
				##we want to look at the direction that we are moving
			#"cast_finished":
				##looking directly at the player
				#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
				#
		#
	##Conditions
	#anim_tree.set("parameters/conditions/is_in_range", _target_in_range())
	#anim_tree.set("parameters/conditions/is_run", !_target_in_range())
	#move_and_slide()

func _target_in_range():
	if global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		return true
	else:
		return false
		
func _fire_ball():
	print("fire_ball")

	

	


func _on_vision_timer_timeout():
	var overlaps = vision_area.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
	
				vision_raycast.target_position = overlap.global_transform.origin
				vision_raycast.force_raycast_update()
				if vision_raycast.is_colliding():
					var collider = vision_raycast.get_collider()
					
					if collider.name == "Player":
						print("I see you")
					else:
						print("where did you go")
