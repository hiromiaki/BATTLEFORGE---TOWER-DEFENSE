extends Area2D

export var speed := 500
export var life_time := 0.6
export var damage := 100
var direction = Vector2.ZERO
var exploding := false

onready var explosion = $explosion
onready var timer = $Timer
onready var bomb = $bomb

func _ready():
	bomb.play("default")
	timer.wait_time = life_time
	timer.start()
	timer.connect("timeout", self, "_on_timeout")
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta):
	if exploding:
		return  # Stop moving when exploding
	position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if exploding:
		return
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		_trigger_explosion()
		return
		
	if body.is_in_group("enemytower"):
		body.take_damage(damage)
		_trigger_explosion()
		return

func _on_timeout():
	_trigger_explosion()

func _trigger_explosion():
	if exploding:
		return
	exploding = true
	speed = 0
	$CollisionShape2D.disabled = true
	explosion.play("explode")
	# Wait for the animation to finish before freeing
	explosion.connect("animation_finished", self, "_on_explosion_finished")

func _on_explosion_finished():
	queue_free()
