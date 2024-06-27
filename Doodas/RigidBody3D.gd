extends RigidBody3D

var health = 20

func hit_successful(damage,hit_type,vector):

	if hit_type == "hitscan":
		var force = Vector3(vector)*200
		health -= damage
		apply_impulse(force)
	if hit_type == "melee":
		health -= damage
		apply_impulse(vector)
	if hit_type == "projectile":
		health -= damage
	if health <= 0:
		queue_free()
