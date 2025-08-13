extends PathFollow2D

var speed = 100  # in pixels per second

func _process(delta):
	offset += speed * delta
