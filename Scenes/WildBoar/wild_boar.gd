extends "res://Scenes/Enemy/enemy.gd"

var facing_left = false

var is_charging = false
var is_preparing_charge = false

var is_stunned = false

var player_on_top = false
var player_on_top_time = 0.0
var is_kicking = false

const MAX_STOMP_TIME = 1.2
const THROW_FORCE_X = 3500.0
const THROW_FORCE_Y = -350.0

const STUN_DURATION = 0.8
const POST_HIT_SPEED = 350.0
const POST_HIT_DURATION = 0.5

const CHARGE_PREP_TIME = 0.7
const CHARGE_SPEED = 400.0
const CHARGE_DURATION = 1.2
const CHARGE_DAMAGE = 10

var charge_direction = Vector2.ZERO


func _ready():
	super._ready()

	$StompDetector.body_entered.connect(
		_on_stomp_detector_body_entered
	)

	$StompDetector.body_exited.connect(
		_on_stomp_detector_body_exited
	)


func move_towards_player():
	if player == null:
		return

	if is_charging or is_preparing_charge:
		return

	start_charge()


func attack():
	if is_charging or is_preparing_charge:
		return

	start_charge()


func start_charge():
	if player == null:
		return

	if is_charging or is_preparing_charge:
		return

	is_preparing_charge = true
	velocity = Vector2.ZERO

	# Se întoarce spre player
	if player.global_position.x < global_position.x:
		facing_left = true
		$AnimatedSprite2D.play("walk_reverse")
	else:
		facing_left = false
		$AnimatedSprite2D.play("walk")

	# Pregătire înainte de charge
	await get_tree().create_timer(CHARGE_PREP_TIME).timeout

	if player == null or is_dead:
		is_preparing_charge = false
		return

	# Direcție fixă spre player
	charge_direction = Vector2(
		sign(player.global_position.x - global_position.x),
		0
	)

	is_preparing_charge = false
	is_charging = true
	$WildBoarSound.play()

	# Animația de charge
	if charge_direction.x < 0:
		facing_left = true
		$AnimatedSprite2D.play("walk_reverse")
	else:
		facing_left = false
		$AnimatedSprite2D.play("walk")


func _physics_process(delta):
	super._physics_process(delta)

	if is_dead:
		return

	# PLAYER ESTE DEASUPRA MISTREȚULUI
	if player_on_top and not is_kicking and not is_stunned:

		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true
			$KickSound.play()

			var throw_direction = 1

			if player.global_position.x < global_position.x:
				throw_direction = -1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("WILD BOAR THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(1.0).timeout

			is_kicking = false

	# Mistrețul este amețit și poate fi lovit
	if is_stunned:

		velocity = Vector2.ZERO
		return

	# Mistrețul face charge
	if is_charging:

		velocity = charge_direction * CHARGE_SPEED
		move_and_slide()

		for i in get_slide_collision_count():

			var collision = get_slide_collision(i)
			var body = collision.get_collider()
			var normal = collision.get_normal()

			# A lovit playerul
			if body != null and body.is_in_group("player"):

				body.take_damage(CHARGE_DAMAGE)

				# Aruncă playerul
				body.velocity.x = charge_direction.x * 1200.0
				body.velocity.y = -500.0

				print("WILD BOAR HIT PLAYER")

				# Nu se oprește instant
				# Continuă puțin după impact
				is_charging = false
				velocity = charge_direction * POST_HIT_SPEED

				await get_tree().create_timer(POST_HIT_DURATION).timeout

				# Intră în starea de vulnerabilitate
				velocity = Vector2.ZERO
				is_stunned = true

				await get_tree().create_timer(STUN_DURATION).timeout

				is_stunned = false

				break

			# A lovit un perete lateral
			if abs(normal.x) > 0.7:

				# Întoarce direcția
				charge_direction.x = -charge_direction.x

				# Îl scoatem puțin din perete
				global_position.x += charge_direction.x * 20.0

				# Întoarce sprite-ul
				if charge_direction.x < 0:
					facing_left = true
					$AnimatedSprite2D.play("walk_reverse")
				else:
					facing_left = false
					$AnimatedSprite2D.play("walk")

				break



func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player"):
		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF WILD BOAR")


func _on_stomp_detector_body_exited(body):
	if body.is_in_group("player"):
		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT WILD BOAR")
