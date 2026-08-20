extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

const ATTACK_RANGE = 140.0
const ATTACK_DAMAGE = 10

var health = 100


func _physics_process(delta: float):

	# GRAVITATIE
	if not is_on_floor():
		velocity += get_gravity() * delta


	# SARITURA - ENTER
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# MISCARE STANGA / DREAPTA
	var direction := Input.get_axis(
		"move_left",
		"move_right"
	)

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			SPEED
		)


	move_and_slide()


	# ATAC
	if Input.is_action_just_pressed("attack"):

		var enemy = get_tree().get_first_node_in_group("enemy")

		if enemy != null:

			var distance = global_position.distance_to(
				enemy.global_position
			)

			print("Distance:", distance)

			if distance <= ATTACK_RANGE:

				print("HIT!")

				enemy.take_damage(
					ATTACK_DAMAGE
				)


func take_damage(amount):

	health -= amount

	print("Player HP:", health)

	if health <= 0:

		print("PLAYER DEAD")
