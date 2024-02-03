extends CharacterBody3D

var speed: float = 10.0

var jump_force: float = 4.5

var gravity: float = -9.8

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D

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
			#the line below prevents us from rotating hour heads up and down 360*
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	

func _physics_process(delta:float) -> void:

	
	var input_dir := Input.get_vector("left","right","foward","backward")
	
	var direction := (neck.transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	direction = direction.normalized()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		
	
	
	move_and_slide()
