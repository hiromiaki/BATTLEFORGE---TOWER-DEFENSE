extends KinematicBody2D

# --- Stats ---
export var max_health := 150
var health := max_health
export var fire_interval := 1.5
export var speed := 80
export var rotation_speed := 2.0
export var body_turn_speed := 1.5
export var attack_distance := 120.0  # 🆕 Shooting range

# --- References ---
var bullet_scene = preload("res://src/Bullet.tscn")
onready var turret = $turret
onready var muzzle = $turret/muzzle
onready var detection_area = $DetectionArea
onready var muzzle_flash = $turret/muzzleFlash
onready var anim_player = $AnimationPlayer
onready var track = $track
onready var track2 = $track2
onready var health_bar = $healthBar
onready var explosion = $explosion
onready var smoke = $Smoke

# --- State ---
var enemy_ref: Node = null
var tower_ref: Node = null
var fire_timer = 0.0

func _ready():
	health = max_health
	update_health_bar()
	track.play("working")
	track2.play("working")

	detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")
	detection_area.connect("body_exited", self, "_on_DetectionArea_body_exited")

	# Get enemy tower from group
	var towers = get_tree().get_nodes_in_group("enemytower")
	if towers.size() > 0:
		tower_ref = towers[0]

func _process(delta):
	if is_instance_valid(enemy_ref):
		# Chase and shoot enemy units
		_attack_target(enemy_ref, delta, true)
	elif is_instance_valid(tower_ref):
		# Always move toward tower, but only shoot if in range
		var dist_to_tower = global_position.distance_to(tower_ref.global_position)
		_attack_target(tower_ref, delta, dist_to_tower <= attack_distance)

func _attack_target(target, delta, can_shoot: bool):
	var dist_to_target = global_position.distance_to(target.global_position)
	if dist_to_target > attack_distance:
		_move_towards(target.global_position, delta)
	else:
		_stop_and_face(target, delta)

	_smooth_aim_turret_at_target(delta, target)

	if can_shoot:
		_handle_shooting(delta)

func _move_towards(target_pos, delta):
	var direction = (target_pos - global_position).normalized()
	var desired_angle = direction.angle()
	rotation = lerp_angle(rotation, desired_angle, body_turn_speed * delta)
	move_and_slide(Vector2.RIGHT.rotated(rotation) * speed)

func _stop_and_face(target, delta):
	var direction = (target.global_position - global_position).normalized()
	var desired_angle = direction.angle()
	rotation = lerp_angle(rotation, desired_angle, body_turn_speed * delta)

func _smooth_aim_turret_at_target(delta, target):
	var to_target = target.global_position - turret.global_position
	var current_angle = turret.global_rotation
	var desired_angle = to_target.angle()
	var angle_diff = wrapf(desired_angle - current_angle, -PI, PI)
	var new_angle = current_angle + angle_diff * rotation_speed * delta
	turret.global_rotation = new_angle

func _handle_shooting(delta):
	fire_timer -= delta
	if fire_timer <= 0:
		_shoot_bullet()
		fire_timer = fire_interval

func _shoot_bullet():
	if not bullet_scene:
		return
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
	if body.is_in_group("enemy") or body.is_in_group("enemytower"):
		enemy_ref = body

func _on_DetectionArea_body_exited(body):
	if body == enemy_ref:
		enemy_ref = null

# --- Damage ---
func take_damage(amount := 20):
	health -= amount
	update_health_bar()
	if health < 0:
		health = 0
	_update_smoke_visibility()
	if health <= 0:
		die()

func _update_smoke_visibility():
	smoke.visible = (health <= 60)

func update_health_bar():
	if health_bar:
		health_bar.value = health
		health_bar.max_value = max_health

func die():
	explosion.visible = true
	explosion.play("explode")
	$track.visible = false
	$track2.visible = false
	$body.visible = false
	$turret.visible = false
	explosion.connect("animation_finished", self, "_on_explosion_finished")

func _on_explosion_finished():
	queue_free()
