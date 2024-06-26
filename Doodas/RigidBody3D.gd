extends RigidBody3D

var health = 20

func hit_successful(damage,hit_type,vector):
	if hit_type == "hitscan":
		var force = Vector3(vector)*200
		health -= damage
		apply_impulse(force)
	if hit_type == "melee":
		health -= damage
		if vector:
			apply_impulse(vector*100)
	if hit_type == "projectile":
		health -= damage
	
	if health <= 0:
		queue_free()
