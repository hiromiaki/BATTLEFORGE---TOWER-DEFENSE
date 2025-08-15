extends Area2D

export var speed := 400
export var life_time := 0.6
export var damage := 10
var direction: Vector2 = Vector2.RIGHT
var is_exploding = false

onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = life_time
	timer.start()
	$AnimatedSprite.visible = false  # Hide explosion by default

func _physics_process(delta):
	if not is_exploding:
		position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if is_exploding:
		return
	
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		explode()
	elif body.is_in_group("tower") and body.has_method("take_damage"):
		body.take_damage(damage)
		explode()
	elif body.is_in_group("allytank") and body.has_method("take_damage"):
		body.take_damage(damage)
		explode()

func _on_Timer_timeout():
	explode()

func explode():
	is_exploding = true
	$Sprite.visible = false            # Hide bullet sprite
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("explode")
	timer.stop()
	$AnimatedSprite.connect("animation_finished", self, "_on_explode_finished")

func _on_explode_finished():
	queue_free()
