extends "res://Scenes/Enemy/enemy.gd"

const BANANA_SCENE = preload("res://Scenes/Monkey/Banana/banana.tscn")

var facing_left = false

var is_jumping = false
var is_preparing_jump = false
var is_attacking = false

var player_on_top = false
var player_on_top_time = 0.0
var is_kicking = false

const MAX_STOMP_TIME = 1.2
const THROW_FORCE_X = 3500.0
const THROW_FORCE_Y = -350.0

const JUMP_PREP_TIME = 0.5
const JUMP_FORCE_X = 450.0
const JUMP_FORCE_Y = -650.0

const CLOSE_DISTANCE = 180.0
const FAR_DISTANCE = 350.0

const BANANA_ATTACK_DISTANCE = 350.0
const BANANA_PREP_TIME = 1.0

var jump_direction = 1


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
	
		# PLAYERUL ESTE DEASUPRA MAIMUȚEI
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

			print("MONKEY THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(1.0).timeout

			is_kicking = false

	# MAIMUȚA ESTE ÎN AER
	if is_jumping:

		velocity += get_gravity() * delta
		move_and_slide()

		if is_on_floor():

			velocity = Vector2.ZERO
			is_jumping = false

			await get_tree().create_timer(0.5).timeout

			if not is_jumping and not is_preparing_jump and not is_attacking:
				decide_jump()

		return

	# Dacă atacă, nu face nimic altceva
	if is_attacking:
		return

	# MAIMUȚA ESTE PE SOL
	if not is_preparing_jump:
		decide_jump()


func decide_jump():

	if player == null:
		return

	var distance_to_player = global_position.distance_to(
		player.global_position
	)

	# PLAYER FOARTE APROAPE
	# Sare peste el și se îndepărtează
	if distance_to_player <= CLOSE_DISTANCE:

		start_jump_away()
		return

	# PLAYER LA DISTANȚĂ
	# Se oprește, aruncă banana, apoi sare spre player
	if distance_to_player >= BANANA_ATTACK_DISTANCE:

		banana_attack()
		return

	# DISTANȚĂ MEDIE
	# Sare spre player
	start_jump_towards()


func banana_attack():

	if is_attacking or is_jumping or is_preparing_jump:
		return

	if player == null:
		return

	is_attacking = true
	velocity = Vector2.ZERO
	$MonkeySound.play()

	# Se întoarce spre player
	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = 1

	set_facing(direction)

	# Stă o secundă și se uită spre player
	await get_tree().create_timer(BANANA_PREP_TIME).timeout

	if is_dead or player == null:
		is_attacking = false
		return

	# Creează banana
	var banana = BANANA_SCENE.instantiate()

	get_parent().add_child(banana)

	banana.global_position = $BananaSpawn.global_position

	# Banana zboară direct spre player
	banana.direction = (
		player.global_position - banana.global_position
	).normalized()

	# Termină atacul
	is_attacking = false

	# După banană sare spre player
	start_jump_towards()


func start_jump_towards():

	if is_jumping or is_preparing_jump:
		return

	is_preparing_jump = true
	velocity = Vector2.ZERO

	var direction = sign(
		player.global_position.x - global_position.x
	)

	if direction == 0:
		direction = 1

	jump_direction = direction

	set_facing(direction)

	await get_tree().create_timer(JUMP_PREP_TIME).timeout

	if is_dead or player == null:
		is_preparing_jump = false
		return

	is_preparing_jump = false
	is_jumping = true

	velocity.x = jump_direction * JUMP_FORCE_X
	velocity.y = JUMP_FORCE_Y


func start_jump_away():

	if is_jumping or is_preparing_jump:
		return

	is_preparing_jump = true
	velocity = Vector2.ZERO

	var direction = sign(
		global_position.x - player.global_position.x
	)

	if direction == 0:
		direction = 1

	jump_direction = direction

	set_facing(direction)

	await get_tree().create_timer(JUMP_PREP_TIME).timeout

	if is_dead or player == null:
		is_preparing_jump = false
		return

	is_preparing_jump = false
	is_jumping = true

	velocity.x = jump_direction * JUMP_FORCE_X
	velocity.y = JUMP_FORCE_Y


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

		print("PLAYER ON TOP OF MONKEY")


func _on_stomp_detector_body_exited(body):

	if body.is_in_group("player"):

		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT MONKEY")
