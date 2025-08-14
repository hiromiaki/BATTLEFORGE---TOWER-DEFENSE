extends Area2D

export var speed := 400
export var life_time := 0.6
export var damage := 10  # Damage dealt per hit
var direction: Vector2 = Vector2.RIGHT

onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = life_time
	timer.start()

func _physics_process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body):
	# If the target can take damage, deal it
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("tower") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("allytank") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func _on_Timer_timeout():
	queue_free()
