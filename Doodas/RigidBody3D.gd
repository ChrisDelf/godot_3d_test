extends RigidBody3D

var health = 5

func hit_successful(damage):
	health -= damage
	#print("Target hit" + str(health))
	if health <= 0:
		queue_free()
