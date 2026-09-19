extends "res://Scenes/Enemy/enemy.gd"

const EGG_SCENE = preload("res://Scenes/Chicken/Egg/egg.tscn")

var facing_left = false

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


func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player"):
		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF CHICKEN")


func _on_stomp_detector_body_exited(body):
	if body.is_in_group("player"):
		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT CHICKEN")


func move_towards_player():
	if player == null or is_kicking:
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
	can_attack = false
	velocity = Vector2.ZERO

	update_facing_direction()

	$ChickenSound.play()

	await get_tree().create_timer(0.5).timeout

	if facing_left:
		$AnimatedSprite2D.play("attack_reverse")
	else:
		$AnimatedSprite2D.play("attack")

	await get_tree().create_timer(0.5).timeout

	$EggThrow.play()

	var egg = EGG_SCENE.instantiate()
	get_parent().add_child(egg)

	egg.global_position = $EggSpawn.global_position

	if facing_left:
		egg.direction = Vector2.LEFT
		egg.velocity.y = -200.0
	else:
		egg.direction = Vector2.RIGHT
		egg.velocity.y = -200.0

	await get_tree().create_timer(0.5).timeout

	if facing_left:
		$AnimatedSprite2D.play("walk_reverse")
	else:
		$AnimatedSprite2D.play("walk")

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	can_attack = true


func _physics_process(delta):
	super._physics_process(delta)

	if player_on_top and not is_kicking:
		player_on_top_time += delta

		if player_on_top_time >= MAX_STOMP_TIME:

			is_kicking = true

			update_facing_direction()

			var throw_direction = 1

			if facing_left:
				$AnimatedSprite2D.play("attack_reverse")
				$KickSound.play()
				throw_direction = -1
			else:
				$AnimatedSprite2D.play("attack")
				$KickSound.play()
				throw_direction = 1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("CHICKEN THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(2.0).timeout

			is_kicking = false

			update_facing_direction()

			if facing_left:
				$AnimatedSprite2D.play("walk_reverse")
			else:
				$AnimatedSprite2D.play("walk")
