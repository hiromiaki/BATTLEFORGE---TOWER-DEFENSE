extends Area2D

onready var hud_2 = $"../../../../../../HUD2"
var death_position = Vector2.ZERO

func _on_killzone_body_entered(body):
	if body.is_in_group("enemy") or body.is_in_group("allytank"):
		if body.has_method("die"):
			body.die()
	
	if body.is_in_group("player"):
		if body.has_method("die"):
			hud_2.visible = false
			body.die()
