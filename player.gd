extends CharacterBody2D

const SPEED = 300.0
const ATTACK_RANGE = 140.0
const ATTACK_DAMAGE = 10
var health = 100

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = direction * SPEED

	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		var enemy = get_tree().get_first_node_in_group("enemy")

		if enemy != null:
			var distance = global_position.distance_to(enemy.global_position)
			print("Distance:", distance)

			if distance <= ATTACK_RANGE:
				print("HIT!")
				enemy.take_damage(ATTACK_DAMAGE)
				
func take_damage(amount):

	health -= amount

	print("Player HP:", health)

	if health <= 0:
		print("PLAYER DEAD")
