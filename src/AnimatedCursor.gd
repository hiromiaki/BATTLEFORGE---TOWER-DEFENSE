extends Node2D

func _ready():
	$AnimationPlayer.play("rotating")

func _process(delta):
	position = get_viewport().get_mouse_position()
