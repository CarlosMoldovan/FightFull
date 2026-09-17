extends "res://enemy.gd"

var facing_left = false

var is_jumping = false
var is_preparing_jump = false
var jump_waiting = false
var jump_wait_timer = 0.0

const JUMP_PREP_TIME = 0.8
const JUMP_WAIT_TIME = 2.0
const MIN_JUMP_DISTANCE = 150.0
const LANDING_OFFSET = 100.0
const JUMP_FORCE_X = 300.0
const JUMP_FORCE_Y = -700.0

var is_attacking = false
var can_tongue_attack = true

const TONGUE_RANGE = 220.0
const TONGUE_DAMAGE = 10
const TONGUE_DURATION = 0.25
const TONGUE_COOLDOWN = 1.5

var player_under_frog = false
var is_top_attacking = false

var player_on_top = false
var player_on_top_time = 0.0
var is_kicking = false

const MAX_STOMP_TIME = 1.2
const THROW_FORCE_X = 3500.0
const THROW_FORCE_Y = -350.0

const TOP_ATTACK_DAMAGE = 10
const TOP_ATTACK_FORCE_Y = -800.0
const TOP_ATTACK_DURATION = 0.3


func move_towards_player():
	if player == null:
		return

	if is_jumping or is_preparing_jump:
		return

	start_jump()


func start_jump():
	if player == null:
		return

	if is_jumping or is_preparing_jump:
		return

	# Dacă playerul este prea aproape, nu sare
	var distance = global_position.distance_to(player.global_position)

	if distance <= MIN_JUMP_DISTANCE:
		velocity = Vector2.ZERO
		is_preparing_jump = false
		return

	is_preparing_jump = true
	velocity = Vector2.ZERO
	
	
	$FrogSound.play()

	# Se întoarce spre player
	if player.global_position.x < global_position.x:
		facing_left = true
		$AnimatedSprite2D.play("walk_reverse")
	else:
		facing_left = false
		$AnimatedSprite2D.play("walk")

	# Pregătire înainte de salt
	await get_tree().create_timer(JUMP_PREP_TIME).timeout

	if player == null or is_dead:
		is_preparing_jump = false
		return

	# Verificăm din nou dacă playerul este prea aproape
	distance = global_position.distance_to(player.global_position)

	if distance <= MIN_JUMP_DISTANCE:
		is_preparing_jump = false
		velocity = Vector2.ZERO
		return

	# Alegem o destinație LÂNGĂ player, niciodată pe el
	var landing_position_x

	if player.global_position.x < global_position.x:
		landing_position_x = player.global_position.x + LANDING_OFFSET
	else:
		landing_position_x = player.global_position.x - LANDING_OFFSET

	var jump_direction = sign(landing_position_x - global_position.x)

	velocity.x = jump_direction * JUMP_FORCE_X
	velocity.y = JUMP_FORCE_Y

	is_preparing_jump = false
	is_jumping = true

func _physics_process(delta):
	# Lăsăm partea de moarte a enemy.gd să funcționeze
	if is_dead:

		if not pulling:

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

	# PLAYER ESTE DEASUPRA BROAȘTEI
	if player_on_top and not is_kicking and not is_top_attacking:

		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true

			$KickSound.play()

			var throw_direction = 1

			if player.global_position.x < global_position.x:
				throw_direction = -1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("FROG THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(1.0).timeout

			is_kicking = false

	# BROASCA ESTE ÎN AER
	if is_jumping:

		velocity += get_gravity() * delta
		move_and_slide()

		var landed_on_real_floor = false
		var hit_player = false

		for i in get_slide_collision_count():

			var collision = get_slide_collision(i)
			var body = collision.get_collider()
			var normal = collision.get_normal()

			# A atins playerul
			if body != null and body.is_in_group("player"):
				hit_player = true

			# A atins podeaua reală
			if normal.y < -0.7 and (body == null or not body.is_in_group("player")):
				landed_on_real_floor = true

		# A aterizat pe podeaua reală
		if landed_on_real_floor:

			velocity = Vector2.ZERO
			is_jumping = false

			if player_under_frog:
				top_attack()
			else:
				jump_waiting = true
				jump_wait_timer = JUMP_WAIT_TIME

		# Dacă a lovit playerul de dedesubt,
		# continuă să cadă
		elif hit_player:

			velocity.y = 100.0

		return

	# Așteaptă după aterizare
	if jump_waiting:

		velocity = Vector2.ZERO

		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player <= MIN_JUMP_DISTANCE:
			jump_waiting = false
			return

		jump_wait_timer -= delta

		if jump_wait_timer <= 0:

			jump_waiting = false

			# Dacă playerul este sub broască, face top attack
			if player_under_frog:
				top_attack()
			elif distance_to_player <= TONGUE_RANGE:
				tongue_attack()
			else:
				start_jump()

		return

	# Broasca stă pe loc
	if not is_preparing_jump and not is_attacking:

		var distance_to_player = global_position.distance_to(player.global_position)

		if player_under_frog:
			top_attack()
		elif distance_to_player <= TONGUE_RANGE:
			tongue_attack()
		else:
			start_jump()
func tongue_attack():
	if player == null:
		return

	if is_attacking or not can_tongue_attack:
		return

	is_attacking = true
	can_tongue_attack = false
	velocity = Vector2.ZERO

	# Întoarce broasca spre player
	if player.global_position.x < global_position.x:
		facing_left = true
		$AnimatedSprite2D.play("walk_reverse")
	else:
		facing_left = false
		$AnimatedSprite2D.play("walk")

	# Poziționează limba în fața broaștei
	$Tongue.visible = true

	if facing_left:
		$Tongue.flip_h = true
		$Tongue.position.x = -abs($Tongue.position.x)
	else:
		$Tongue.flip_h = false
		$Tongue.position.x = abs($Tongue.position.x)

	# Limba lovește playerul
	player.take_damage(TONGUE_DAMAGE)

	# Limba apare pentru scurt timp
	await get_tree().create_timer(TONGUE_DURATION).timeout

	$Tongue.visible = false

	is_attacking = false

	# Cooldown
	await get_tree().create_timer(TONGUE_COOLDOWN).timeout

	can_tongue_attack = true

func top_attack():
	if player == null:
		return

	if is_top_attacking:
		return

	is_top_attacking = true
	player_under_frog = false

	velocity = Vector2.ZERO

	print("FROG TOP ATTACK")

	# Damage o singură dată
	player.take_damage(TOP_ATTACK_DAMAGE)

	# Aruncă playerul violent în sus și puțin într-o parte
	player.velocity.y = -1800.0
	player.velocity.x = randf_range(-500.0, 500.0)

	# Broasca sare puternic de pe player
	velocity.y = -1200.0
	velocity.x = randf_range(-300.0, 300.0)

	# Broasca revine în fizica normală de săritură
	is_jumping = true
	jump_waiting = false
	is_preparing_jump = false

	# Cooldown pentru atac
	await get_tree().create_timer(0.8).timeout

	is_top_attacking = false
func _ready():
	super._ready()

	$Tongue.visible = false

	$TopAttackDetector.body_entered.connect(
		_on_top_attack_detector_body_entered
	)

	$TopAttackDetector.body_exited.connect(
		_on_top_attack_detector_body_exited
	)

	$StompDetector.body_entered.connect(
		_on_stomp_detector_body_entered
	)

	$StompDetector.body_exited.connect(
		_on_stomp_detector_body_exited
	)


func _on_top_attack_detector_body_entered(body):
	if body.is_in_group("player"):
		player_under_frog = true
		print("PLAYER UNDER FROG")

		if is_jumping and not is_top_attacking:
			is_jumping = false
			velocity = Vector2.ZERO
			top_attack()


func _on_top_attack_detector_body_exited(body):
	if body.is_in_group("player"):
		player_under_frog = false
		print("PLAYER LEFT FROG")
		
func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player"):
		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF FROG")


func _on_stomp_detector_body_exited(body):
	if body.is_in_group("player"):
		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT FROG")
