extends PathFollow2D

var speed = 500  # in pixels per second

func _process(delta):
	offset += speed * delta
