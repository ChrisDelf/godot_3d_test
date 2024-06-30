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
	body.hit_successful(5,"melee",null)
