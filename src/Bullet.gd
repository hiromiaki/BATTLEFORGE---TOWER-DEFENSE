extends Area2D

export var speed := 500
export var life_time := 0.6
var direction = Vector2.ZERO

func _ready():
	$Timer.wait_time = life_time
	$Timer.start()
	$Timer.connect("timeout", self, "queue_free")
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):  # Make sure your enemies are in this group
		body.take_damage()
		queue_free()
		return
	
	if body.is_in_group("enemytower"):
		body.take_damage(20)
		queue_free()
		return
