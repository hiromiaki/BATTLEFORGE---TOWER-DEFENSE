extends Control

func _ready():
	$AnimationPlayer.play("light")

func _on_startbutton_pressed():
	get_tree().change_scene("res://src/main.tscn")
	
