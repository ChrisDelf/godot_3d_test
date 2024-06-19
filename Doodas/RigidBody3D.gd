extends RigidBody3D

var health = 5

func hit_successful(damage,hit_type,vector):

	if hit_type == "hitscan":
		var force = Vector3(vector)*150
		print(vector)
		health -= damage
		apply_impulse(force)
	else:
		health -= damage
	if health <= 0:
		queue_free()
