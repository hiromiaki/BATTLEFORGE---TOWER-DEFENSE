extends StaticBody2D

export var max_health := 500
var current_health := max_health

signal tower_destroyed
signal tower_health_changed(current_health, max_health) # ✅ New signal

onready var health_bar = $healthBar
onready var explosion = $explosion
onready var destroyed_tower = $destroyed
onready var tower = $Sprite
onready var game_over = $"../GameOver"
onready var hud_2 = $"../HUD2"
onready var hud = $"../HUD"
onready var screenfade_player = $"../HUD/ScreenFade/AnimationPlayer"

func _ready():
	health_bar.max_value = max_health
	health_bar.value = current_health
	emit_signal("tower_health_changed", current_health, max_health) # ✅ Send initial value

func take_damage(amount):
	current_health -= amount
	health_bar.value = current_health
	emit_signal("tower_health_changed", current_health, max_health) # ✅ Notify HUD

	if current_health <= 0:
		emit_signal("tower_destroyed")
		destroyed()

func destroyed():
	explosion.visible = true
	explosion.play("default")
	explosion.connect("animation_finished", self, "_on_explosion_finished")
	tower.visible = false
	destroyed_tower.visible = true
	screenfade_player.play("fade_to_black")
	yield(screenfade_player, "animation_finished")
	hud.hide()
	hud_2.hide()
	game_over.show()

func _on_explosion_finished():
	explosion.stop()
