extends Control

onready var button_pressed = $"button-pressed"
onready var background_music = $"bg-music"
var bgMusicOn = true

func _ready():
	$AnimationPlayer.play("light")
	update_music_stats()

func update_music_stats():
	if bgMusicOn:
		if !background_music.playing:
			background_music.play()

func _on_startbutton_pressed():
	button_pressed.play()
	call_deferred("change_to_main_scene")

func change_to_main_scene():
	get_tree().change_scene("res://src/main.tscn")
	
