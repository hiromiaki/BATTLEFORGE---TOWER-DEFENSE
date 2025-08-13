extends Node2D

func _ready():
	if $AnimatedSprite:
		$AnimatedSprite.play("explode")
		$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished():
	queue_free()
