extends Area2D

func _ready():
	$AnimationPlayer.play("idle")

func _on_repair_body_entered(body):
	if body.is_in_group("player"):
		body.heal(10)
		queue_free() # Remove potion after pickup
