extends "res://enemy.gd"

@onready var attack_direction = $AttackDirection
@onready var milk = $AttackDirection/Milk
@onready var milk_hitbox = $AttackDirection/MilkHitbox
@onready var stomp_detector = $StompDetector
@onready var kick_sound = $KickSound
var facing_left = false
var is_kicking = false

var player_on_top = false
var player_on_top_time = 0.0

const MAX_STOMP_TIME = 1.2
const THROW_FORCE_X = 3500.0
const THROW_FORCE_Y = -350.0

func _ready():

	super._ready()

	milk.visible = false
	milk_hitbox.monitoring = false

	attack_direction.scale.x = 1

	stomp_detector.body_entered.connect(
		_on_stomp_detector_body_entered
	)

	stomp_detector.body_exited.connect(
		_on_stomp_detector_body_exited
	)
func _on_stomp_detector_body_entered(body):

	if body.is_in_group("player"):
		
		player_on_top = true
		player_on_top_time = 0.0

		print("PLAYER ON TOP OF COW")
		
func _on_stomp_detector_body_exited(body):

	if body.is_in_group("player"):
		
		player_on_top = false
		player_on_top_time = 0.0

		print("PLAYER LEFT COW")
		

func update_facing_direction():

	if player == null:
		return

	if player.global_position.x < global_position.x:
		facing_left = true
	else:
		facing_left = false
		
func play_attack_animation():

	if facing_left:
		$AnimatedSprite2D.play("attack_reverse")
	else:
		$AnimatedSprite2D.play("attack")
		
func play_walk_animation():

	if facing_left:
		$AnimatedSprite2D.play("walk_reverse")
	else:
		$AnimatedSprite2D.play("walk")

func attack():

	can_attack = false

	velocity = Vector2.ZERO

	update_facing_direction()

	if facing_left:
		$AnimatedSprite2D.play("attack_reverse")
		attack_direction.scale.x = -1
	else:
		$AnimatedSprite2D.play("attack")
		attack_direction.scale.x = 1

	await get_tree().create_timer(0.8).timeout

	milk.visible = true
	milk_hitbox.monitoring = true
	$MooSound.play()

	await get_tree().create_timer(1).timeout

	milk.visible = false
	milk_hitbox.monitoring = false

	await get_tree().create_timer(0.9).timeout

	$AnimatedSprite2D.play("idle")

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	can_attack = true

func move_towards_player():
	if is_kicking:
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

func _on_milk_hitbox_body_entered(body):

	if body.is_in_group("player"):
		body.take_damage(ATTACK_DAMAGE)
		
func _physics_process(delta):

	super._physics_process(delta)

	if player_on_top and not is_kicking:

		player_on_top_time += delta

		print("ON TOP:", player_on_top_time)

		if player_on_top_time >= MAX_STOMP_TIME:

			print("1.2 SECONDS REACHED")

			is_kicking = true

			update_facing_direction()

			var throw_direction = 1

			if facing_left:

				$AnimatedSprite2D.play("kick")
				kick_sound.play()
				throw_direction = -1

			else:

				$AnimatedSprite2D.play("kick_reverse")
				kick_sound.play()
				throw_direction = 1

			player.velocity.x = THROW_FORCE_X * throw_direction
			player.velocity.y = THROW_FORCE_Y

			print("COW THREW PLAYER")

			player_on_top = false
			player_on_top_time = 0.0

			await get_tree().create_timer(2.0).timeout

			is_kicking = false

			update_facing_direction()

			if facing_left: 
				$AnimatedSprite2D.play("walk_reverse")

			else: 
				$AnimatedSprite2D.play("walk")
