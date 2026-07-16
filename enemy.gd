extends CharacterBody2D

const SPEED = 150.0
var health = 50

var player: CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED

	move_and_slide()
	
func take_damage(amount: int):
	health -= amount
	print("Enemy HP:", health)

	if health <= 0:
		print("Enemy defeated!")
		queue_free()
