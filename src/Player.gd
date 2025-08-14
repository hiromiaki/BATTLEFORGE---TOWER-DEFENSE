extends KinematicBody2D

# === Signals ===
signal shoot(bullet_scene, spawn_position, direction)
signal health_changed(new_health)
signal dead

# === Exported Variables ===
export (PackedScene) var Bullet
export (PackedScene) var BombBullet
export (int) var base_speed := 200
export (float) var rotation_speed := 2.0
export (float) var gun_cooldown := 0.5
export (int) var maxHealth := 200

# === Internal Variables ===
var velocity = Vector2()
var can_shoot = true
var alive = true
var currentHealth = 0

# === Node References ===
onready var gun_timer = $GunTimer
onready var turret = $turret
onready var muzzle = $turret/muzzle
onready var muzzle_flash = $turret/muzzleFlash
onready var track = $track
onready var track_2 = $track2
onready var health_ui = $"../HUD2"
onready var explosion = $explosion
onready var smoke = $Smoke
onready var screenfade_player = $"../HUD/ScreenFade/AnimationPlayer"
onready var game_over = $"../GameOver"
onready var shoot_sfx = $"shoot-sfx"
onready var movement_sfx = $"movement-sfx"
onready var idle_sfx = $"idle-sfx"
onready var bomb_sfx = $"bomb-sfx"

func _ready():
	currentHealth = maxHealth
	emit_signal("health_changed", currentHealth)

	if health_ui.has_method("init_health"):
		health_ui.call("init_health", maxHealth)

	gun_timer.wait_time = gun_cooldown
	gun_timer.one_shot = true
	gun_timer.connect("timeout", self, "_on_GunTimer_timeout")

	# Register player in GameManager
	GameManager.player = self

# === PHYSICS ===
func _physics_process(delta):
	if not alive:
		return

	handle_input(delta)
	move_and_slide(velocity)

	if Input.is_action_just_pressed("shoot"):
		shoot_bullet()

# === INPUT ===
func handle_input(delta):
	turret.look_at(get_global_mouse_position())

	# Rotate body
	var rotation_direction = 0
	if Input.is_action_pressed("turn_right"):
		rotation_direction += 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction -= 1
	rotation += rotation_direction * rotation_speed * delta

	# Movement
	velocity = Vector2.ZERO
	var current_speed = base_speed
	if Input.is_action_pressed("forward"):
		idle_sfx.play()
		track.play("working")
		track_2.play("working")
		velocity = Vector2(current_speed, 0).rotated(rotation)
	elif Input.is_action_pressed("back"):
		idle_sfx.play()
		track.play("working")
		track_2.play("working")
		velocity = Vector2(-current_speed / 2, 0).rotated(rotation)
	else:
		movement_sfx.play()
		track.play("idle")
		track_2.play("idle")

# === SHOOTING ===
func shoot_bullet():
	if not can_shoot:
		return

	can_shoot = false
	gun_timer.start()
	
	shoot_sfx.play()
	var direction = Vector2.RIGHT.rotated(turret.global_rotation)
	var spawn_pos = muzzle.global_position

	# Flash effect
	show_muzzle_flash()

	# Bomb bullet mode
	if GameManager.bomb_bullets_enabled and GameManager.bomb_bullet_ammo > 0:
		if BombBullet != null:
			bomb_sfx.play()
			emit_signal("shoot", BombBullet, spawn_pos, direction)
			GameManager.bomb_bullet_ammo -= 1
			print("Bomb bullet fired. Remaining: ", GameManager.bomb_bullet_ammo)
			if GameManager.bomb_bullet_ammo <= 0:
				GameManager.bomb_bullets_enabled = false
	else:
		if Bullet != null:
			emit_signal("shoot", Bullet, spawn_pos, direction)

func show_muzzle_flash():
	muzzle_flash.visible = true
	muzzle_flash.play("fire")
	yield(get_tree().create_timer(0.5), "timeout")
	muzzle_flash.visible = false

func _on_GunTimer_timeout():
	can_shoot = true

# === DAMAGE ===
func take_damage(amount = 20):
	if not alive:
		return

	currentHealth -= amount
	currentHealth = clamp(currentHealth, 0, maxHealth)
	emit_signal("health_changed", currentHealth)

	if health_ui.has_method("set_health"):
		health_ui.call("set_health", currentHealth)

	_update_smoke_visibility()

	if currentHealth <= 0:
		die()

func heal(amount):
	if not alive:
		return

	currentHealth += amount
	currentHealth = clamp(currentHealth, 0, maxHealth)
	emit_signal("health_changed", currentHealth)

	if health_ui.has_method("set_health"):
		health_ui.call("set_health", currentHealth)

	_update_smoke_visibility()

func _update_smoke_visibility():
	smoke.visible = currentHealth <= 60

func die():
	if not alive:
		return
	alive = false
	explosion.visible = true
	explosion.play("explode")
	screenfade_player.play("fade_to_black")
	yield(screenfade_player, "animation_finished")
	game_over.show()
	emit_signal("dead")
	queue_free()
