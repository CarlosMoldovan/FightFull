extends CharacterBody2D

const SPEED = 150.0

const ATTACK_RANGE = 150.0
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 1.5

var health = 50
var is_dead = false
var can_attack = true

var player: CharacterBody2D
var black_hole: Marker2D

# Animatia gaurii negre
var orbit_angle = 0.0
var orbit_radius = 0.0
var orbit_turns = 0.0
var orbit_speed = 6.0
var pulling = false
var suction_speed = 0.0


func _ready():
	player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D.play("idle")
	black_hole = get_tree().get_first_node_in_group("black_hole")


func _physics_process(delta):

	if is_dead:

		if !pulling:

			orbit_angle += orbit_speed * delta
			orbit_turns += orbit_speed * delta

			orbit_radius = max(orbit_radius - 45 * delta, 18)

			global_position = black_hole.global_position + Vector2(
				cos(orbit_angle),
				sin(orbit_angle)
			) * orbit_radius

			rotation += 14 * delta

			scale = scale.lerp(Vector2(0.25, 0.25), 2.2 * delta)

			modulate.a = lerp(modulate.a, 0.4, 1.5 * delta)

			if orbit_turns >= PI * 6:
				pulling = true
				suction_speed = 700

		else:

			suction_speed += 1800 * delta

			global_position = global_position.move_toward(
				black_hole.global_position,
				suction_speed * delta
			)

			rotation += 30 * delta

			scale = scale.lerp(Vector2.ZERO, 7 * delta)

			modulate.a = lerp(modulate.a, 0.0, 5 * delta)

			if global_position.distance_to(black_hole.global_position) < 4:
				queue_free()

		return

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > ATTACK_RANGE:

		move_towards_player()

	else:

		velocity = Vector2.ZERO

		if can_attack:
			attack()


func move_towards_player():

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * SPEED

	move_and_slide()

func attack():

	can_attack = false

	print("Generic attack")

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	can_attack = true


func take_damage(amount):

	health -= amount
	print("Enemy HP:", health)

	if health <= 0:

		print("Enemy defeated!")

		is_dead = true

		orbit_radius = global_position.distance_to(
			black_hole.global_position
		)

		orbit_angle = (
			global_position - black_hole.global_position
		).angle()

		orbit_turns = 0.0
		pulling = false
