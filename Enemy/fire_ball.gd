extends RigidBody3D

var damage: int

func _on_body_entered(body):
	if body.is_in_group("Players") && body.has_method("hit"):
		body.hit(damage, "projectile", null)
		queue_free()
	queue_free()

func _on_timer_timeout():
	queue_free()
