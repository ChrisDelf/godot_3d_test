extends CharacterBody3D

var speed: float = 5
var jump_force: float = 4.5
const gravity: float = -9.8
const walking_speed: float = 5
const sprint_speed: float = 8
const crouch_speed: float = 3
const lerp_speed: float = 10
var direction: = Vector3.ZERO
var crouching_depth: float = -0.5

@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
@onready var head_lamp: SpotLight3D = $Neck/SpotLight3D
@onready var ray_cast_3d = $RayCast3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#capturing mouse actions 
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#makes the cursor visiable again
	elif Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	#mouse motion rotates the camera
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			#rotates our head left to right
			neck.rotate_y(-event.relative.x * 0.005)
			#rotates our head up and down
			camera.rotate_x(-event.relative.y * 0.005)
			#rotates our light source up and down
			head_lamp.rotate_x(-event.relative.y * 0.005)
			#the line below prevents us from rotating hour heads up and down 360*
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
			head_lamp.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
			
			
	
func _process(_delta):
	if Input.is_action_pressed("primary action"):
		print("shoot")

func _physics_process(delta):
	var input_dir := Input.get_vector("left","right","foward","backward")
	
	#crouching
	if Input.is_action_pressed("crouch"):
		speed = crouch_speed
		neck.position.y = lerp(neck.position.y , 1.605 + crouching_depth, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	#Sprinting
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		neck.position.y = lerp(neck.position.y , 1.605, delta * lerp_speed)
		if Input.is_action_pressed("sprint"):
			speed = sprint_speed
		else: 
			speed = walking_speed	
		
	
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		
	#direction we are going to move
	direction = lerp(direction,(neck.transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized(),delta * lerp_speed)
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
