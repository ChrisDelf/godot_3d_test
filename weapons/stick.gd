extends Node3D
@onready var hit_box = $WeaponMesh/StickHitBox
var damage
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_weapon_holder_weapon_swing():
	hit_box.monitoring = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "stick_attack":
		hit_box.monitoring = false
	


func _on_stick_hit_box_body_entered(body):
	if body.is_in_group("Targets") and body.has_method("hit_successful"):
		var attack_vector = get_collision_force()
		body.hit_successful(5,"melee",attack_vector)
		
func get_collision_force():
	# we need to get the direction of the force
	var force_direction = global_transform.origin - hit_box.global_transform.origin
	force_direction = force_direction.normalized() #Normalize the direction vector
	var force_magnitude = 10.0 #Adjust the magnitude of the force
	var force = force_direction * force_direction
	print(force)
	return force
