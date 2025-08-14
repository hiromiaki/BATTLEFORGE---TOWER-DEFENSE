extends CanvasLayer

onready var buy_aly_btn = $allies_button
onready var buy_bomb_btn = $bomb_button
onready var continue_button = $continue_button
onready var anim_player = $AnimationPlayer
onready var error_label = $"error-label"
onready var buy_sfx = $"buy-sfx"

func _ready():
	anim_player.play("aly_rotate")

func _on_buy_ally():
	if GameManager.coins >= 10:
		GameManager.coins -= 10
		buy_sfx.play()
		GameManager.spawn_ally()
		hide()
		get_tree().paused = false
		error_label.hide()
	else:
		show_message("Failed to purchase: Not enough coins.")

func _on_buy_bomb():
	if GameManager.coins >= 25:
		GameManager.coins -= 25
		buy_sfx.play()
		GameManager.buy_bomb_bullets()
		error_label.hide()
	else:
		show_message("Failed to purchase: Not enough coins.")

func _on_close_shop():
	hide()
	get_tree().paused = false

func show_message(text):
	error_label.text = text
	error_label.show()
	yield(get_tree().create_timer(2.0), "timeout")
	error_label.hide()
