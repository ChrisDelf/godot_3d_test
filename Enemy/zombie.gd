extends CharacterBody3D

const SPEED = 3.0
const ATTACK_RANGE = 2.5
var player = null
var health = 20
#creating state machine for animations
var state_machine
var is_dead = false



@export var player_path: = "/root/Test_area/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## movement
	velocity = Vector3.ZERO
	if !is_dead:
		match state_machine.get_current_node():
			"run":
					#navigation
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point = nav_agent.get_next_path_position()
				#getting the direction of player
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
				#smoothing out the turning
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
				#we want to look at the direction that we are moving
			"attack":
				#looking directly at the player
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
				
		
		#Conditions
		anim_tree.set("parameters/conditions/is_attack", _target_in_range())
		anim_tree.set("parameters/conditions/is_run", !_target_in_range())
		move_and_slide()
	

	
func _target_in_range():
	if global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		return true
	else:
		return false
	
func hit_finished():
	#want to see if the player is still in range
	if global_position.distance_to(player.global_position) <= ATTACK_RANGE + 1.0 && !is_dead:
		# want to get the direction of the hit to create stagger
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
	
		


func hit_successful(damage,hit_type, vector):
	if hit_type == "hitscan":
		health -= damage
		anim_tree.set("parameters/conditions/is_stagger", true)
	if hit_type == "melee":
		health -= damage
		anim_tree.set("parameters/conditions/is_stagger", true)
	if hit_type == "projectile":
		health -= damage
		anim_tree.set("parameters/conditions/is_stagger", true)
	if health <= 0:
		anim_player.play("death")
		is_dead = true
		

func stagger_end():
	anim_tree.set("parameters/conditions/is_stagger", false)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()
		return
	


