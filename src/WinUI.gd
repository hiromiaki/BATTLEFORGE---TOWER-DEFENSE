extends CanvasLayer



func _on_TextureButton_pressed():
	GameManager.reset()
	get_tree().reload_current_scene()
