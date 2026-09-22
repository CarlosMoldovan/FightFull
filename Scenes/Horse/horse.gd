extends "res://Scenes/Enemy/enemy.gd"

var facing_left = false

var is_attacking = false
var is_preparing_attack = false
var attack_timer = 0.0
var has_hit_player = false

const MOVE_SPEED = 100.0

const ATTACK_DISTANCE = 130
const PREP_TIME = 0.8
const ATTACK_DURATION = 1.0

const KNOCKBACK_X = 1000.0
const KNOCKBACK_Y = -500.0

var attack_direction = 1

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


	# PLAYERUL ESTE DEASUPRA CALULUI

	if player_on_top and not is_kicking and not is_attacking:

		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true

			$KickSound.play()

			var throw_direction = 1

			if player.global_position.x < global_position.x:
				throw_direction = -1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("HORSE THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(1.0).timeout

			is_kicking = false


	# CALUL ATACĂ

	if is_attacking:

		velocity = Vector2.ZERO

		move_and_slide()

		for i in get_slide_collision_count():

			var collision = get_slide_collision(i)
			var body = collision.get_collider()

			if body != null and body.is_in_group("player") and not has_hit_player:

				body.take_damage(ATTACK_DAMAGE)

				body.velocity.x = attack_direction * KNOCKBACK_X
				body.velocity.y = KNOCKBACK_Y

				has_hit_player = true

				print("HORSE HIT PLAYER")

		attack_timer -= delta

		if attack_timer <= 0:

			is_attacking = false

			velocity = Vector2.ZERO

			if facing_left:
				$AnimatedSprite2D.play("walk_reverse")
			else:
				$AnimatedSprite2D.play("walk")

			await get_tree().create_timer(1.0).timeout

		return


	# CALUL SE PREGĂTEȘTE DE ATAC

	if is_preparing_attack:

		velocity = Vector2.ZERO

		return


	# DISTANȚA FAȚĂ DE PLAYER

	var distance_to_player = global_position.distance_to(
		player.global_position
	)


	# DACĂ ESTE DESTUL DE APROAPE, ATACĂ

	if distance_to_player <= ATTACK_DISTANCE:

		start_attack()

		return


	# ALTFEL MERGE SPRE PLAYER

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


func start_attack():

	if is_attacking or is_preparing_attack:
		return

	is_preparing_attack = true

	velocity = Vector2.ZERO
	$HorseSound.play()

	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = 1

	attack_direction = direction

	if direction < 0:

		facing_left = true
		$AnimatedSprite2D.play("attack_reverse")

	else:

		facing_left = false
		$AnimatedSprite2D.play("attack")

	print("HORSE PREPARING ATTACK")

	await get_tree().create_timer(PREP_TIME).timeout

	if is_dead or player == null:

		is_preparing_attack = false

		return

	is_preparing_attack = false

	is_attacking = true

	has_hit_player = false

	attack_timer = ATTACK_DURATION

	velocity = Vector2.ZERO

	print("HORSE ATTACK")


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

		print("PLAYER ON TOP OF HORSE")


func _on_stomp_detector_body_exited(body):

	if body.is_in_group("player"):

		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT HORSE")
