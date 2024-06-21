extends CharacterBody3D

const SPEED = 3.0
const ATTACK_RANGE = 2.5
var player = null

#creating state machine for animations
var state_machine



@export var player_path: NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"run":
				#navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			#getting the direction of player
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			#we want to look at the direction that we are moving
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, 
			player.global_position.z + velocity.z), Vector3.UP)
		"attack":
			#looking directly at the player
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
	
	
	#Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE
	
func hit_finished():
	print("bonk!")
