extends CharacterBody3D

#movement
var speed: float = 5
var jump_force: float = 4.5
const gravity: float = -9.8
const walking_speed: float = 5
const sprint_speed: float = 8
const crouch_speed: float = 3
const lerp_speed: float = 10
const air_lerp_speed: float = 3.5
const hit_stagger: float = 8
var direction: = Vector3.ZERO
var crouching_depth: float = -0.5
var mouse_sen: float = .08
var free_look_tilt_amount: float = 3
var last_velocity: Vector3 = Vector3.ZERO

# Player States
var walking: bool = false
var sprinting: bool = false
var crouching: bool = false
var free_looking: bool = false
var sliding: bool = false

#Slide Vars
var slide_timer: float = 0.0
var slide_timer_max: float = 1.0
var slide_vector: Vector2 = Vector2.ZERO
var slide_speed: float = 10.0
var can_slide: bool = true

#Head Bobbing vars
const head_bobbing_sprinting_speed: float = 22.0
const head_bobbing_walking_speed: float = 13.0
const head_bobbing_crouching_speed: float = 10.0

var head_bobbing_current_intensity: float = 0.0
const head_bobbing_sprinting_intensity: float = 0.2
const head_bobbing_walking_intensity: float = 0.1
const head_bobbing_crouching_intensity: float = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

#weapon related variables
var current_weapon: Node = null

#signals
signal player_hit


@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var eyes = $Neck/Head/Eyes
@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var camera = $Neck/Head/Eyes/Camera3D
@onready var head_lamp = $Neck/Head/SpotLight3D
@onready var ray_cast_3d = $RayCast3D
@onready var animation_player = $Neck/Head/Eyes/AnimationPlayer
@onready var crosshair = $Neck/Head/Eyes/Camera3D/CanvasLayer/CrossHair
@onready var _stick = $Neck/Head/Eyes/WeaponHolder/stick
@onready var hit_ui = $HitTaken/ColorRect


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#hear to readjust the camera... there is a bug somewhere I don't know how to fix.. might be related to camera setup.
	animation_player.play("landing")
	#to hide our default weapon... some reason it needs to be here I must be a noob
	_stick.visible = false

	
	
	


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
			if free_looking:
				neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sen))
				neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
			else:
				#rotates our head left to right
				rotate_y(deg_to_rad(-event.relative.x * mouse_sen))
	
			#rotates our head up and down
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sen))
			
			#the line below prevents us from rotating hour heads up and down 360*
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-75), deg_to_rad(75))
			
			
			

func _physics_process(delta):
	
	#Movement inpt
	var input_dir := Input.get_vector("left","right","foward","backward")
	
	#crouching
	if Input.is_action_pressed("crouch") || sliding:
	
		

		speed = lerp(speed, crouch_speed, delta * lerp_speed)
		
		head.position.y = lerp(head.position.y ,crouching_depth, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		#Slide begin
		if sprinting && input_dir != Vector2.ZERO && sliding != true && can_slide == true:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			can_slide = false
			$Timers/SlideCooldown.start()

		walking = false
		sprinting = false
		crouching = true
		
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y , 0.0, delta * lerp_speed)
	
	#Handling Sliding movement
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
			
	
	#Sprint
	if Input.is_action_pressed("sprint"):
		speed = lerp(speed, sprint_speed, delta * lerp_speed)
		
		walking = false
		sprinting = true
		crouching = false
	elif Input.is_action_pressed("crouch"):
		crouching = true
		sprinting = false
		walking = false
	else: 
		speed = lerp(speed, walking_speed, delta * lerp_speed)
		
		walking = true
		sprinting = false
		crouching = false
		
	#Handling the free looking
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(-7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(eyes.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y,0.0,delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z,0.0,delta * lerp_speed)
	
	#Head Bobbing
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
		Globals.player_state = "sprinting"
	elif walking and !crouching:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
		Globals.player_state = "walking"
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
		Globals.player_state = "crouching"
		
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity/2), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.y, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y,0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x,0.0, delta * lerp_speed)
		
	#Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		Globals.player_state = "falling"
		
	#Jumping 
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		#eyes.rotation.z = -deg_to_rad(eyes.rotation.y * free_look_tilt_amount)
		velocity.y = jump_force
		sliding = false
		animation_player.play("jump")
	
	#Handle landing
	if is_on_floor():
		if last_velocity.y < -6.0:
			print("hard fall")
			animation_player.play("landing")
		elif last_velocity.y < -4.0:
			animation_player.play("landing")
			
		
		
	#direction we are going to move
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized(),delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized(),delta * air_lerp_speed)
		
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0, slide_vector.y)).normalized()
		speed = (slide_timer + 0.1) * slide_speed
		Globals.player_state = "sliding"
	
		
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	
	if velocity.length() < 0.1:
		Globals.player_state="idle"
		
	last_velocity = velocity
	move_and_slide()
	

	
func hit(dir):
	hit_ui.visible = true
	emit_signal("player_hit", 5)
	await get_tree().create_timer(0.2).timeout
	hit_ui.visible = false
	velocity += dir * hit_stagger

func _on_slide_cooldown_timeout():
	can_slide = true


func _on_weapon_holder_weapon_swap(param1):
	current_weapon = param1


func _on_weapon_holder_update_weapon_stack():
	pass # Replace with function body.


func _on_fists_fist_animation_finished():
	pass # Replace with function body.
