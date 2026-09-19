extends "res://Scenes/Enemy/enemy.gd"

var facing_left = false

var is_charging = false
var is_preparing_charge = false
var charge_direction = Vector2.ZERO
var player_on_top = false
var player_on_top_time = 0.0
var is_kicking = false

const MAX_STOMP_TIME = 1.2
const THROW_FORCE_X = 3500.0
const THROW_FORCE_Y = -350.0

const CHARGE_DISTANCE = 400.0
const CHARGE_PREP_TIME = 1.0
const CHARGE_SPEED = 800.0
const POST_CHARGE_WAIT = 3.0
const CHARGE_DAMAGE = 10

func _ready():
	super._ready()

	$StompDetector.body_entered.connect(
		_on_stomp_detector_body_entered
	)

	$StompDetector.body_exited.connect(
		_on_stomp_detector_body_exited
	)


func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player"):
		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF RAM")


func _on_stomp_detector_body_exited(body):
	if body.is_in_group("player"):
		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT RAM")

func move_towards_player():
	if player == null:
		return

	# Dacă se pregătește sau aleargă, nu mai merge normal
	if is_charging or is_preparing_charge:
		return

	var distance = global_position.distance_to(player.global_position)

	# Începe încărcarea când ajunge la distanța dorită
	if distance <= CHARGE_DISTANCE:
		start_charge()
		return

	var direction = sign(player.global_position.x - global_position.x)

	if direction < 0:
		facing_left = true

		if $AnimatedSprite2D.animation != "walk_reverse":
			$AnimatedSprite2D.play("walk_reverse")
	else:
		facing_left = false

		if $AnimatedSprite2D.animation != "walk":
			$AnimatedSprite2D.play("walk")

	velocity.x = direction * SPEED
	velocity.y = 0
	move_and_slide()


func update_facing_direction():
	if player == null:
		return

	if player.global_position.x < global_position.x:
		facing_left = true
	else:
		facing_left = false


func attack():
	# Berbecul nu folosește atacul generic
	if not is_charging and not is_preparing_charge:
		start_charge()


func start_charge():
	if player == null:
		return

	if is_charging or is_preparing_charge:
		return

	is_preparing_charge = true
	velocity = Vector2.ZERO

	update_facing_direction()
	$RamSound.play()

	# Stă pe loc și se pregătește
	if facing_left:
		$AnimatedSprite2D.play("walk_reverse")
	else:
		$AnimatedSprite2D.play("walk")

	await get_tree().create_timer(CHARGE_PREP_TIME).timeout

	if player == null:
		is_preparing_charge = false
		return

	# Fixăm direcția exact în momentul pornirii
	charge_direction = Vector2(
	sign(player.global_position.x - global_position.x),
	0
)

	is_preparing_charge = false
	is_charging = true

	# Direcția vizuală
	if charge_direction.x < 0:
		facing_left = true
		$AnimatedSprite2D.play("walk_reverse")
	else:
		facing_left = false
		$AnimatedSprite2D.play("walk")


func _physics_process(delta):
	super._physics_process(delta)

	# PLAYER ESTE DEASUPRA BERBECULUI
	if player_on_top and not is_kicking:

		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true

			update_facing_direction()

			var throw_direction = 1

			if facing_left:
				$AnimatedSprite2D.play("walk_reverse")
				$KickSound.play()
				throw_direction = -1
			else:
				$AnimatedSprite2D.play("walk")
				$KickSound.play()
				throw_direction = 1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("RAM THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(2.0).timeout

			is_kicking = false

			update_facing_direction()

			if facing_left:
				$AnimatedSprite2D.play("walk_reverse")
			else:
				$AnimatedSprite2D.play("walk")


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

				is_charging = false
				is_preparing_charge = true
				velocity = Vector2.ZERO

				await get_tree().create_timer(POST_CHARGE_WAIT).timeout

				is_preparing_charge = false
				break

			# A lovit un perete lateral
			if abs(normal.x) > 0.7:

				is_charging = false
				is_preparing_charge = true
				velocity = Vector2.ZERO

				# Schimbăm direcția
				charge_direction.x = -charge_direction.x
				charge_direction.y = 0

				# Îl scoatem din perete
				global_position.x += charge_direction.x * 30.0

				# Pauză după impact
				await get_tree().create_timer(3.0).timeout

				is_preparing_charge = false
				is_charging = true

				# Păstrăm direcția de ricoșeu
				if charge_direction.x < 0:
					facing_left = true
					$AnimatedSprite2D.play("walk_reverse")
				else:
					facing_left = false
					$AnimatedSprite2D.play("walk")

				break
