extends CanvasLayer

signal shop_opened

onready var tower_health = $towerHealth
onready var timer = $Timer
onready var health_bar = $healthBar
onready var damage_bar = $damageBar
var health = 0
var max_value = 200  

var is_opening_shop := false  

func _ready():
	# Connect to GameManager's coins_updated signal
	if GameManager.has_signal("coins_updated"):
		GameManager.connect("coins_updated", self, "_on_coins_updated")
	# Set initial coin label
	_on_coins_updated(GameManager.coins)
	
	var tower = get_tree().root.get_node("main/Tower")
	if tower:
		tower.connect("tower_health_changed", self, "_on_tower_health_changed")

func _on_tower_health_changed(current_health, max_health):
	tower_health.max_value = max_health
	tower_health.value = current_health

func _on_ShopButton_pressed():
	if is_opening_shop:
		return  # Prevent recursion
	is_opening_shop = true
	
	emit_signal("shop_opened")
	
	is_opening_shop = false

func set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0, max_value)

	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		queue_free()
	
	if health < prev_health:
		timer.start()
	elif damage_bar:
		damage_bar.value = health

func init_health(_health):
	health = _health
	max_value = _health

	if health_bar:
		health_bar.max_value = _health
		health_bar.value = _health
	
	if damage_bar:
		damage_bar.max_value = _health
		damage_bar.value = _health

# Called whenever coins change
func _on_coins_updated(new_amount):
	if has_node("coinLabel"):
		$coinLabel.text = "Coins: " + str(new_amount)

func _on_Timer_timeout():
	if damage_bar:
		damage_bar.value = health

