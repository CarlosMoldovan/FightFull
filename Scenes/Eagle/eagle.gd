extends "res://Scenes/Enemy/enemy.gd"

var facing_left = false

var is_flying = false
var is_taking_off = false
var attack_direction = 1
var is_preparing_dive = false
var is_diving = false
var has_hit_player = false

const DIVE_DISTANCE = 250.0
const DIVE_PREP_TIME = 0.7
const DIVE_SPEED = 700.0
const DIVE_DURATION = 1.0

const DIVE_DAMAGE = 20
const DIVE_KNOCKBACK_X = 1200.0
const DIVE_KNOCKBACK_Y = -500.0

var dive_timer = 0.0
var dive_direction = Vector2.ZERO

const FLY_SPEED = 250.0

const TAKEOFF_DISTANCE = 400.0
const TAKEOFF_TIME = 0.8
const TAKEOFF_SPEED = 350.0

var takeoff_timer = 0.0

var is_landing = false
var is_on_ground = true

const GROUND_TIME_MIN = 3.0
const GROUND_TIME_MAX = 5.0

const LANDING_SPEED = 300.0

var ground_timer = 0.0

var flight_timer = 0.0

const FLIGHT_TIME_MIN = 5.0
const FLIGHT_TIME_MAX = 8.0


func _ready():
	super._ready()

	velocity = Vector2.ZERO

	$AnimatedSprite2D.play("walk")


func _physics_process(delta):

	if is_dead:
		super._physics_process(delta)
		return

	if player == null:
		return


	# ==========================================
	# DECOLARE
	# ==========================================

	if is_taking_off:

		velocity.x = 0
		velocity.y = -TAKEOFF_SPEED

		move_and_slide()

		takeoff_timer -= delta

		if takeoff_timer <= 0:

			is_taking_off = false
			is_flying = true
			is_on_ground = false
			flight_timer = randf_range(
			  FLIGHT_TIME_MIN,
			  FLIGHT_TIME_MAX
			 )

			velocity = Vector2.ZERO

			print("EAGLE IS FLYING")

		return


	# ==========================================
	# ATERIZARE
	# ==========================================

	if is_landing:

		velocity.x = 0
		velocity.y = LANDING_SPEED

		move_and_slide()

		if is_on_floor():

			is_landing = false
			is_flying = false
			is_on_ground = true

			velocity = Vector2.ZERO

			if facing_left:
				$AnimatedSprite2D.play("walk_reverse")
			else:
				$AnimatedSprite2D.play("walk")

			ground_timer = randf_range(
				GROUND_TIME_MIN,
				GROUND_TIME_MAX
			)

			print("EAGLE LANDED")

		return


	# ==========================================
	# VULTURUL ESTE PE SOL
	# ==========================================

	if is_on_ground:

		velocity = Vector2.ZERO

		ground_timer -= delta

		# A stat destul pe jos -> decolează
		if ground_timer <= 0:

			start_takeoff()

			return

		# Se uită spre player
		var ground_direction = sign(
			player.global_position.x - global_position.x
		)

		if ground_direction < 0:

			facing_left = true

			if $AnimatedSprite2D.animation != "walk_reverse":
				$AnimatedSprite2D.play("walk_reverse")

		elif ground_direction > 0:

			facing_left = false

			if $AnimatedSprite2D.animation != "walk":
				$AnimatedSprite2D.play("walk")

		return


	# ==========================================
	# VULTURUL ZBOARĂ
	# ==========================================

	if is_flying:
		
		flight_timer -= delta
		if flight_timer <= 0:
			start_landing()
			return

		# ------------------------------------------
		# PICaj
		# ------------------------------------------

		if is_diving:

			velocity = dive_direction * DIVE_SPEED

			move_and_slide()

			for i in get_slide_collision_count():

				var collision = get_slide_collision(i)
				var body = collision.get_collider()

				if body != null and body.is_in_group("player") and not has_hit_player:

					body.take_damage(DIVE_DAMAGE)

					body.velocity.x = dive_direction.x * DIVE_KNOCKBACK_X
					body.velocity.y = DIVE_KNOCKBACK_Y

					has_hit_player = true

					print("EAGLE HIT PLAYER")

			dive_timer -= delta

			if dive_timer <= 0:

				is_diving = false

				velocity = Vector2.ZERO

				await get_tree().create_timer(0.8).timeout

				# După atac se ridică iar
				if not is_dead:

					is_flying = true

			return


		# ------------------------------------------
		# PREGĂTIRE PICaj
		# ------------------------------------------

		if is_preparing_dive:

			velocity = Vector2.ZERO

			return


		# ------------------------------------------
		# ZBOR NORMAL
		# ------------------------------------------

		var difference_x = player.global_position.x - global_position.x

		var distance_to_player = global_position.distance_to(
			player.global_position
		)


		# Playerul este suficient de aproape -> picaj
		if distance_to_player <= DIVE_DISTANCE:

			start_dive()

			return


		# Urmărește playerul pe orizontală
		if abs(difference_x) > 20:

			var direction = sign(difference_x)

			attack_direction = direction

			velocity.x = direction * FLY_SPEED

			set_facing(direction)

		else:

			velocity.x = 0

		velocity.y = 0

		move_and_slide()

		return
func start_takeoff():

	if is_taking_off or is_flying:
		return

	is_taking_off = true

	takeoff_timer = TAKEOFF_TIME

	velocity = Vector2.ZERO

	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction < 0:

		facing_left = true
		$AnimatedSprite2D.play("fly_reverse")

	else:

		facing_left = false
		$AnimatedSprite2D.play("fly")

	print("EAGLE TAKING OFF")


func set_facing(direction):

	if abs(player.global_position.x - global_position.x) < 20:
		return

	if direction < 0:

		facing_left = true

		if $AnimatedSprite2D.animation != "fly_reverse":
			$AnimatedSprite2D.play("fly_reverse")

	else:

		facing_left = false

		if $AnimatedSprite2D.animation != "fly":
			$AnimatedSprite2D.play("fly")
			
func start_dive():

	if is_preparing_dive or is_diving:
		return

	is_preparing_dive = true
	
	$EagleSound.play()

	velocity = Vector2.ZERO

	# Salvăm poziția playerului în momentul atacului
	dive_direction = (
		player.global_position - global_position
	).normalized()

	# Alegem animația în funcție de direcția orizontală
	if dive_direction.x < 0:

		facing_left = true

		if $AnimatedSprite2D.animation != "fly_reverse":
			$AnimatedSprite2D.play("fly_reverse")

	else:

		facing_left = false

		if $AnimatedSprite2D.animation != "fly":
			$AnimatedSprite2D.play("fly")

	print("EAGLE PREPARING DIVE")

	await get_tree().create_timer(DIVE_PREP_TIME).timeout

	if is_dead or player == null:

		is_preparing_dive = false

		return

	is_preparing_dive = false
	is_diving = true

	has_hit_player = false
	dive_timer = DIVE_DURATION

	print("EAGLE DIVE ATTACK")
	
func start_landing():

	if is_landing or is_on_ground:
		return

	is_landing = true
	is_flying = false
	is_diving = false
	is_preparing_dive = false

	velocity = Vector2.ZERO

	print("EAGLE LANDING")
