extends Area2D

var death_position = Vector2.ZERO

func _on_killzone_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("enemy") or body.is_in_group("allytank"):
		if body.has_method("die"):
			body.die()
