extends Node2D

export (PackedScene) var enemy_scene
export (PackedScene) var repair_scene

export var base_enemies_per_wave := 5
export var time_between_waves := 5.0

var current_wave := 0
var enemies_alive := 0
var spawning := false
var spawn_points = []

# === HUD ===
onready var wave_countdown = $HUD/WaveCountdown
onready var enemies_alive_label = $HUD/EnemiesAlive
onready var hud = $HUD2
onready var shop_ui = $ShopUI

#=== Repair ===
onready var repair_timer = $RepairTimer
var active_repair = null

# === sound ===
onready var train_sound = $train/Node2D/Path2D/PathFollow2D/StaticBody2D/AudioStreamPlayer2D
onready var sfx_voice = $"sfx-voice"

func _ready():
	randomize()

	# Populate spawn_points with Position2D nodes under EnemySpawner
	var spawner = $EnemySpawner
	for child in spawner.get_children():
		if child is Position2D:
			spawn_points.append(child)

	if spawn_points.empty():
		push_error("No spawn points found under EnemySpawner!")
	
	start_next_wave()

	# Connect the player's shoot signal to this scene
	$Player.connect("shoot", self, "_on_Player_shoot")
	
	hud.connect("shop_opened", self, "_on_ShopOpened")
	train_sound.play()

func _on_ShopOpened():
	shop_ui.visible = true
	get_tree().paused = true

func set_camera_limits():
	var map_limits = $Ground.get_used_rect()
	var map_cellsize = $Ground.cell_size
	$Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func start_next_wave():
	current_wave += 1
	var enemies_this_wave = base_enemies_per_wave 
	spawn_wave(enemies_this_wave)

func spawn_wave(count):
	spawning = true
	sfx_voice.play()
	for i in range(count):
		yield(get_tree().create_timer(0.5), "timeout")
		spawn_enemy()
	spawning = false

func spawn_enemy():
	if enemy_scene == null:
		push_error("Enemy scene is not assigned!")
		return

	# Instance and add enemy to the scene
	var enemy = enemy_scene.instance()
	get_tree().current_scene.add_child(enemy)

	# Select random spawn point
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	enemy.global_position = spawn_point.global_position

	# Increase enemies alive and update HUD
	enemies_alive += 1
	_update_enemies_alive_label()

	# Connect to signal when enemy dies or is removed
	if not enemy.is_connected("tree_exited", self, "_on_enemy_died"):
		enemy.connect("tree_exited", self, "_on_enemy_died")

func _on_enemy_died():
	enemies_alive -= 1
	_update_enemies_alive_label()

	if enemies_alive <= 0 and not spawning:
		# Start countdown before next wave
		call_deferred("_start_wave_countdown")

func _update_enemies_alive_label():
	enemies_alive_label.text = "Enemies Alive: " + str(enemies_alive)

func _start_wave_countdown():
	var countdown := int(time_between_waves)
	while countdown > 0:
		wave_countdown.text = "Enemies will spawn in: " + str(countdown) + "s"
		yield(get_tree().create_timer(1.0), "timeout")
		countdown -= 1

	wave_countdown.text = ""  # Clear after countdown
	start_next_wave()


func _delayed_start_wave():
	yield(get_tree().create_timer(time_between_waves), "timeout")
	start_next_wave()

# Player shooting bullet spawn
func _on_Player_shoot(bullet_scene, spawn_position, direction):
	var bullet = bullet_scene.instance()
	bullet.global_position = spawn_position
	bullet.direction = direction
	add_child(bullet)


func _on_RepairTimer_timeout():
	
	if is_instance_valid(active_repair):
		return

	var spawn_points = get_tree().get_nodes_in_group("repair_spawns")
	if spawn_points.empty():
		print("No potion spawn points!")
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var repair = repair_scene.instance()
	repair.position = spawn_point.global_position
	add_child(repair)

	active_repair = repair

	if repair.has_signal("tree_exited"):
		repair.connect("tree_exited", self, "_on_repair_disappeared")

func _on_repair_disappeared():
	active_repair = null
