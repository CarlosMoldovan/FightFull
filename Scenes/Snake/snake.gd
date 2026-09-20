extends "res://Scenes/Enemy/enemy.gd"

var facing_left = false

var is_moving = false
var is_preparing_attack = false
var is_attacking = false

const MOVE_SPEED = 100.0

const ATTACK_DISTANCE = 220.0
const RETREAT_DISTANCE = 140.0

const PREP_TIME = 0.8
const FAKE_TIME = 0.3

const ATTACK_SPEED = 700.0
const ATTACK_DURATION = 0.5

var attack_direction = 1
var attack_timer = 0.0

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
		
		# PLAYERUL ESTE DEASUPRA ȘARPELUI
	if player_on_top and not is_kicking:

		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true

			$KickSound.play()

			var throw_direction = 1

			if player.global_position.x < global_position.x:
				throw_direction = -1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("SNAKE THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(1.0).timeout

			is_kicking = false

	# ȘARPELE ESTE ÎN ATAC
	if is_attacking:

		velocity.x = attack_direction * ATTACK_SPEED
		velocity.y = 0

		move_and_slide()

		for i in get_slide_collision_count():

			var collision = get_slide_collision(i)
			var body = collision.get_collider()

			if body != null and body.is_in_group("player"):

				body.take_damage(ATTACK_DAMAGE)

				print("SNAKE HIT PLAYER")

				is_attacking = false
				velocity = Vector2.ZERO

				await get_tree().create_timer(1.0).timeout

				return

		attack_timer -= delta

		if attack_timer <= 0:

			is_attacking = false
			velocity = Vector2.ZERO

			await get_tree().create_timer(1.0).timeout

		return

	# ȘARPELE SE PREGĂTEȘTE DE ATAC
	if is_preparing_attack:

		velocity = Vector2.ZERO
		return

	var distance_to_player = global_position.distance_to(
		player.global_position
	)

	# PLAYERUL ESTE FOARTE APROAPE
	# Șarpele se retrage
	if distance_to_player <= RETREAT_DISTANCE:

		retreat_from_player()
		return

	# PLAYERUL A INTRAT ÎN RAZA DE ATAC
	if distance_to_player <= ATTACK_DISTANCE:

		start_attack()
		return

	# PLAYERUL ESTE DEPARTE
	# Șarpele se apropie lent
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

	move_and_slide()


func retreat_from_player():

	var direction = sign(
		global_position.x - player.global_position.x
	)

	if direction == 0:
		direction = 1

	velocity.x = direction * MOVE_SPEED
	velocity.y = 0

	set_facing(direction)

	move_and_slide()


func start_attack():

	if is_preparing_attack or is_attacking:
		return

	is_preparing_attack = true
	velocity = Vector2.ZERO
	$SnakeSound.play()

	# Se întoarce spre player
	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = 1

	attack_direction = direction

	set_facing(direction)

	# Se pregătește
	await get_tree().create_timer(PREP_TIME).timeout

	if is_dead or player == null:
		is_preparing_attack = false
		return

	# FENTA
	# Pare că atacă, dar încă nu pornește
	set_facing(attack_direction)

	await get_tree().create_timer(FAKE_TIME).timeout

	if is_dead or player == null:
		is_preparing_attack = false
		return

	# ATACUL REAL
	is_preparing_attack = false
	is_attacking = true

	attack_timer = ATTACK_DURATION

	velocity.x = attack_direction * ATTACK_SPEED
	velocity.y = 0

	move_and_slide()


func set_facing(direction):

	if direction < 0:

		facing_left = true

		if $AnimatedSprite2D.animation != "walk_reverse":
			$AnimatedSprite2D.play("walk_reverse")

	else:

		facing_left = false

		if $AnimatedSprite2D.animation != "walk":
			$AnimatedSprite2D.play("walk")

func _on_stomp_detector_body_entered(body):

	if body.is_in_group("player"):

		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF SNAKE")


func _on_stomp_detector_body_exited(body):

	if body.is_in_group("player"):

		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT SNAKE")
