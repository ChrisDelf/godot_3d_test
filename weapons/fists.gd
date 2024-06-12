extends Node3D
var can_punch_right = true
var can_punch_left = false

@onready var fist_animation_player = $AnimationPlayer
signal fist_animation_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_right_timer_timeout():
	print("false")
	can_punch_left = true


func _on_left_timer_timeout():
	can_punch_right = true


func _on_weapon_holder_melee_action(action: String):
	if action == "activate":
		fist_animation_player.queue("fist_activate")
		
	
	if action == "exit":
		if fist_animation_player.get_current_animation() != "fist_deactivate":
			fist_animation_player.play("fist_deactivate")
			return true
			
	if action == "attack":
		if can_punch_right == true:
			can_punch_right = false
			fist_animation_player.play("fist_punch_right")
			$RightTimer.start()
		elif can_punch_left == true:
			can_punch_left = false
			fist_animation_player.play("fist_punch_left")
			$LeftTimer.start()
			
		


func _on_animation_player_animation_finished(anim_name):
	
	if anim_name == "fist_deactivate":
		emit_signal("fist_animation_finished", anim_name)
		

