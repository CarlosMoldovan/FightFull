extends "res://Scenes/Enemy/enemy.gd"

var facing_left = false

var is_rolling = false
var is_preparing_roll = false

const MOVE_SPEED = 100.0

const ROLL_PREP_TIME = 0.7
const ROLL_SPEED = 650.0
const ROLL_DURATION = 2.5
const ROLL_DAMAGE = 15

const ATTACK_DISTANCE = 300.0

var roll_direction = 1
var roll_timer = 0.0

var has_hit_player = false

var player_on_top = false
var player_on_top_time = 0.0
var is_kicking = false

const MAX_STOMP_TIME = 1.2
const THROW_FORCE_X = 3500.0
const THROW_FORCE_Y = -350.0


func _ready():
	super._ready()

	$StompDetector.body_entered.connect(
		_on_stomp_detector_body_entered
	)

	$StompDetector.body_exited.connect(
		_on_stomp_detector_body_exited
	)


func _physics_process(delta):

	if is_dead:
		super._physics_process(delta)
		return

	if player == null:
		return

	# PLAYERUL ESTE DEASUPRA ARICIULUI
	if player_on_top and not is_kicking and not is_rolling:

		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true

			$KickSound.play()

			var throw_direction = 1

			if player.global_position.x < global_position.x:
				throw_direction = -1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("HEDGEHOG THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(1.0).timeout

			is_kicking = false

	# ARICIUL SE ROSTOGOLEȘTE
	if is_rolling:

		velocity.x = roll_direction * ROLL_SPEED
		velocity.y = 0

		move_and_slide()

		for i in get_slide_collision_count():

			var collision = get_slide_collision(i)
			var body = collision.get_collider()
			var normal = collision.get_normal()

			# A lovit playerul
			if body != null and body.is_in_group("player") and not has_hit_player:

				body.take_damage(ROLL_DAMAGE)

				body.velocity.x = roll_direction * 1000.0
				body.velocity.y = -400.0

				has_hit_player = true

				print("HEDGEHOG HIT PLAYER")

			# A lovit peretele
			if abs(normal.x) > 0.7:

				roll_direction = -roll_direction

				if roll_direction < 0:
					facing_left = true
				else:
					facing_left = false

		roll_timer -= delta

		if roll_timer <= 0:

			is_rolling = false
			velocity = Vector2.ZERO

			$AnimatedSprite2D.play("walk")

			await get_tree().create_timer(1.0).timeout

		return

	# SE PREGĂTEȘTE DE ROSTOGOLIRE
	if is_preparing_roll:

		velocity = Vector2.ZERO
		return

	var distance_to_player = global_position.distance_to(
		player.global_position
	)

	# Dacă playerul este suficient de aproape,
	# începe rostogolirea
	if distance_to_player <= ATTACK_DISTANCE:

		start_roll()
		return

	# Altfel se apropie lent
	move_towards_player()


func move_towards_player():

	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = 1

	velocity.x = direction * MOVE_SPEED
	velocity.y = 0

	set_facing(direction)

	$AnimatedSprite2D.play("walk" if direction > 0 else "walk_reverse")

	move_and_slide()


func start_roll():

	if is_rolling or is_preparing_roll:
		return

	is_preparing_roll = true
	velocity = Vector2.ZERO
	$HedgehogSound.play()

	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = 1

	roll_direction = direction

	set_facing(direction)

	# Se ghemuiește / pregătește atacul
	$AnimatedSprite2D.play("attack")

	await get_tree().create_timer(ROLL_PREP_TIME).timeout

	if is_dead or player == null:
		is_preparing_roll = false
		return

	is_preparing_roll = false
	is_rolling = true

	roll_timer = ROLL_DURATION
	has_hit_player = false

	$AnimatedSprite2D.play("attack")


func set_facing(direction):

	if direction < 0:

		facing_left = true

	else:

		facing_left = false


func _on_stomp_detector_body_entered(body):

	if body.is_in_group("player"):

		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF HEDGEHOG")


func _on_stomp_detector_body_exited(body):

	if body.is_in_group("player"):

		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT HEDGEHOG")
