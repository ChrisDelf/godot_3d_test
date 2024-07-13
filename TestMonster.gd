extends CharacterBody3D

const SPEED = 3.0
@export var player_path: = "/root/Test_area/Player"
@onready var nav_agent = $NavigationAgent3D
@onready var vision_cast = $RayCast3D
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)


func _process(delta):
	velocity = Vector3.ZERO
	
	##navigation
	nav_agent.set_target_position(player.global_transform.origin)

	var next_nav_point = nav_agent.get_next_path_position()
	##getting the direction of player
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	##smoothing out the turning
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
	##we want to look at the direction that we are moving
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	move_and_slide()
	vision_cast.target_position = player.global_transform.origin
	

