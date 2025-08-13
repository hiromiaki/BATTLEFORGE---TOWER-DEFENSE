extends KinematicBody2D

var bullet_scene = preload("res://src/EnemyBullet.tscn")
var CoinScene = preload("res://src/Coin.tscn")

export var fire_interval := 1.5
export var health := 100
export var speed := 80
export var wander_interval := 2.0
export var rotation_speed := 2.0
export var body_turn_speed := 1.5

# --- New variables for spacing ---
export var attack_distance := 300   # Ideal shooting distance
export var min_distance := 200      # Minimum space to keep

onready var turret = $turret
onready var muzzle = $turret/muzzle
onready var detection_area = $DetectionArea
onready var muzzle_flash = $turret/muzzleFlash
onready var anim_player = $AnimationPlayer
onready var track = $AnimatedSprite
onready var track2 = $AnimatedSprite2
onready var explosion = $explosion
onready var smoke = $Smoke

var target_ref = null
var tower_ref = null

var fire_timer = 0.0
var wander_timer = 0.0
var target_body_angle = 0.0

func _ready():
	track.play("working")
	track2.play("working")
	_set_new_wander_direction()
	
	tower_ref = get_tree().get_root().find_node("Tower", true, false)

func _process(delta):
	if is_instance_valid(target_ref):
		_chase_target(delta, target_ref)
		_smooth_aim_turret_at_target(delta, target_ref)
		_handle_shooting(delta)
	elif is_instance_valid(tower_ref):
		_chase_target(delta, tower_ref)
		_smooth_aim_turret_at_target(delta, tower_ref)
		_handle_shooting(delta)
	else:
		_tank_like_wander(delta)
		_random_turret_rotation(delta)

# --- Movement with spacing ---
func _chase_target(delta, target):
	var distance = global_position.distance_to(target.global_position)
	var direction = (target.global_position - global_position).normalized()
	var desired_angle = direction.angle()
	rotation = lerp_angle(rotation, desired_angle, body_turn_speed * delta)

	if distance > attack_distance:
		# Too far, move closer
		move_and_slide(Vector2.RIGHT.rotated(rotation) * speed)
	elif distance < min_distance:
		# Too close, back away
		move_and_slide(Vector2.RIGHT.rotated(rotation + PI) * speed)
	else:
		# Perfect range, stop and aim
		move_and_slide(Vector2.ZERO)

func _smooth_aim_turret_at_target(delta, target):
	var to_target = target.global_position - turret.global_position
	var current_angle = turret.global_rotation
	var desired_angle = to_target.angle()
	var angle_diff = wrapf(desired_angle - current_angle, -PI, PI)
	var new_angle = current_angle + angle_diff * rotation_speed * delta
	turret.global_rotation = new_angle

# --- Shooting ---
func _handle_shooting(delta):
	fire_timer -= delta
	if fire_timer <= 0:
		_shoot_bullet()
		fire_timer = fire_interval

func _shoot_bullet():
	var bullet = bullet_scene.instance()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.rotation = turret.global_rotation
	bullet.direction = turret.global_transform.x.normalized()
	
	show_muzzle_flash()
	if anim_player.has_animation("muzzle_flash"):
		anim_player.play("muzzle_flash")

func show_muzzle_flash():
	muzzle_flash.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	muzzle_flash.visible = false

# --- Detection ---
func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("allytank"):
		target_ref = body

func _on_DetectionArea_body_exited(body):
	if body == target_ref:
		target_ref = null
		_set_new_wander_direction()

# --- Wandering ---
func _tank_like_wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		_set_new_wander_direction()

	rotation = lerp_angle(rotation, target_body_angle, body_turn_speed * delta)
	move_and_slide(Vector2.RIGHT.rotated(rotation) * speed)

func _set_new_wander_direction():
	target_body_angle = rand_range(-PI, PI)
	wander_timer = wander_interval

func _random_turret_rotation(delta):
	var random_angle = rand_range(-0.3, 0.3)
	turret.rotation += random_angle * delta * 0.5

# --- Damage ---
func take_damage(damage := 40):
	health -= damage
	if health < 0:
		health = 0
		
	_update_smoke_visibility()
	
	if health <= 0:
		die()

func _update_smoke_visibility():
	if health <= 60:
		smoke.visible = true
	else:
		smoke.visible = false

func die():
	GameManager.add_coins(3)
	explosion.visible = true
	explosion.play("explode")
	
	$AnimatedSprite.visible = false
	$AnimatedSprite2.visible = false
	$body.visible = false
	$turret.visible = false
	explosion.connect("animation_finished", self, "_on_explosion_finished")

func _on_explosion_finished():
	queue_free()

func spawn_coins(amount: int):
	var coin = CoinScene.instance()
	get_parent().add_child(coin)
	coin.global_position = global_position
