extends Camera3D

var ray_range = 2000

func _input(event):
	if Input.is_action_pressed("3rd Person"):
		print("Shoot")
		
