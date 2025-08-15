extends StaticBody2D

signal destroyed
export var max_health := 700
var current_health := max_health

onready var screenfade_player = $"../HUD/ScreenFade/AnimationPlayer"
onready var win_ui = $"../WinUI"
onready var health_bar = $healthBar

func _ready():
	# Initialize health bar values
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)  # Prevent negatives

	# Update health bar
	if health_bar:
		health_bar.value = current_health

	if current_health <= 0:
		win()

func win():
	screenfade_player.play("fade_to_black")
	yield(screenfade_player, "animation_finished")
	win_ui.show()
	emit_signal("destroyed")
	queue_free()
