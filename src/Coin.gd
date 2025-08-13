extends Area2D

export var coin_value := 1

onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("idle")
	
func _on_Coin_body_entered(body):
	if body.is_in_group("player"):             
		GameManager.add_coins(coin_value)
		queue_free()
