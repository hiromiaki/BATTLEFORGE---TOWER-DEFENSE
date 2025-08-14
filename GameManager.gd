extends Node

# === Global Game Variables ===
var coins = 0
var wave_number: int = 1
var enemies_alive: int = 0
var is_wave_active: bool = false
var is_game_over: bool = false
var player = null

# === Upgrades ===
var bomb_bullets_enabled = false
var bomb_bullet_ammo = 0
var AllyTankScene = preload("res://src/AllyTank.tscn")

# === Signals ===
signal coins_updated(new_amount)
signal wave_started(wave_number)
signal wave_ended()

func _ready():
	print("GameManager ready")

func add_coins(amount):
	coins += amount
	emit_signal("coins_updated", coins)

func upgrade_tank_speed():
	if player:
		player.speed += 50
		print("Tank speed upgraded to: ", player.speed)

func unlock_bomb_bullets():
	bomb_bullets_enabled = true
	if player:
		player.has_bomb_bullets = true
	print("Bomb bullets unlocked!")

func spawn_ally():
	if get_tree().current_scene:
		var ally = AllyTankScene.instance()
		get_tree().current_scene.add_child(ally)

		# Example: place ally near the player if available
		if player:
			ally.global_position = player.global_position + Vector2(100, 0)
		else:
			ally.global_position = Vector2(300, 300)
		emit_signal("coins_updated", coins)

func buy_bomb_bullets():
	bomb_bullets_enabled = true
	bomb_bullet_ammo += 9  
	emit_signal("coins_updated", coins)
	print("Bomb bullets purchased! Current ammo: %d" % bomb_bullet_ammo)

func coins_label():
	emit_signal("coins_update", coins)

# === Reset function for new game ===
func reset():
	coins = 0
	wave_number = 1
	enemies_alive = 0
	is_wave_active = false
	is_game_over = false
	player = null

	bomb_bullets_enabled = false
	bomb_bullet_ammo = 0

	emit_signal("coins_updated", coins)
	print("Game variables have been reset!")
