extends Area2D

export var speed := 500
export var life_time := 0.6
var direction = Vector2.ZERO
var is_exploding = false  # Prevent moving while exploding

func _ready():
	$Timer.wait_time = life_time
	$Timer.start()
	$Timer.connect("timeout", self, "_on_life_timeout")
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta):
	if not is_exploding:
		position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if is_exploding:
		return
	
	if body.is_in_group("enemy"):
		body.take_damage()
		explode()
		return
	
	if body.is_in_group("enemytower"):
		body.take_damage(10)
		explode()
		return

func _on_life_timeout():
	explode()

func explode():
	is_exploding = true
	$Sprite.visible = false
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("explode")
	$Timer.stop()
	# When animation finishes, remove bullet
	$AnimatedSprite.connect("animation_finished", self, "_on_explode_finished")

func _on_explode_finished():
	queue_free()
