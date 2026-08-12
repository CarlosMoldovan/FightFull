extends "res://enemy.gd"

@onready var attack_direction = $AttackDirection
@onready var milk = $AttackDirection/Milk
@onready var milk_hitbox = $AttackDirection/MilkHitbox
var facing_left = false

func _ready():

	super._ready()

	milk.visible = false
	milk_hitbox.monitoring = false

	attack_direction.scale.x = 1

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
		
