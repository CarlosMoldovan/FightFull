extends CharacterBody2D 
 
 
const SPEED = 300.0 
const JUMP_VELOCITY = -500.0 
 
const ATTACK_RANGE = 140.0 
const ATTACK_DAMAGE = 10 
 
var health = 50 
 
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var distortion = $"../DeathEffect/Distortion"
@onready var black_hole = get_tree().get_first_node_in_group("black_hole")
@onready var black_hole_sound = $BlackHoleSound
@onready var game_over_ui = $"../GameOverUI"
@onready var laser = $AttackDirection/Laser
var laser_right_texture = preload("res://SpritesImages/Player/Attack/attackR.png")
@onready var laser_sound = $LaserSound
@onready var laser_hitbox = $AttackDirection/LaserHitbox

var is_dying = false
var death_timer = 0.0

const DEATH_DURATION = 5.0
const MAX_SHAKE = 8.0

func _ready():
	laser_hitbox.monitoring = false
 
 
func _physics_process(delta: float):
	if is_dying:
		handle_death_sequence(delta)
		return
 
	# GRAVITATIE 
	if not is_on_floor(): 
		velocity += get_gravity() * delta 
 
 
	# SARITURA - ENTER 
	if Input.is_action_just_pressed("jump") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY 
 
 
	# MISCARE STANGA / DREAPTA 
	var direction := Input.get_axis( 
		"move_left", 
		"move_right" 
	) 
 
	if direction: 
		velocity.x = direction * SPEED 
		if direction < 0: 
			animated_sprite.play("walk")
			laser.texture = laser_right_texture
			$AttackDirection.scale.x = -1
		else: 
			animated_sprite.play("walk_reverse")
			laser.texture = laser_right_texture
			$AttackDirection.scale.x = 1
	else: 
		velocity.x = move_toward( 
			velocity.x, 
			0, 
			SPEED 
		) 
		animated_sprite.stop() 
 
 
	move_and_slide() 
	if Input.is_action_just_pressed("attack"):
		shoot_laser()
 
 
func take_damage(amount):

	if is_dying:
		return

	health -= amount

	print("Player HP:", health)

	if health <= 0:

		print("PLAYER DEAD")

		is_dying = true
		velocity = Vector2.ZERO
		black_hole_sound.play()
		
func handle_death_sequence(delta: float):

	death_timer += delta

	velocity = Vector2.ZERO

	var progress = min(
		death_timer / DEATH_DURATION,
		1.0
	)

	var shader_material = distortion.material as ShaderMaterial

	if shader_material:
		shader_material.set_shader_parameter(
			"distortion_strength",
			lerp(0.0, 0.35, progress)
		)

	# ROTATIA PLAYERULUI
	animated_sprite.rotation += 2.5 * delta

	# MICSOAREA PLAYERULUI
	var death_scale = lerp(
		0.12,
		0.1,
		progress
	)

	animated_sprite.scale = Vector2(
		death_scale,
		death_scale
	)

	# ZOOM CAMERA
	var camera_zoom = lerp(
		1.1,
		1.45,
		progress
	)

	camera.zoom = Vector2(
		camera_zoom,
		camera_zoom
	)

	# ROTATIA CAMEREI
	camera.rotation = lerp(
		0.0,
		0.04,
		progress
	)

	# CAMERA PULL + SCREEN SHAKE
	if black_hole != null:

		var direction_to_black_hole = (
			black_hole.global_position - camera.global_position
		).normalized()

		var camera_pull_distance = 120.0 * progress

		var pull_offset = (
			direction_to_black_hole
			* camera_pull_distance
		)

		var shake_strength = MAX_SHAKE * progress

		var shake_offset = Vector2(
			randf_range(
				-shake_strength,
				shake_strength
			),
			randf_range(
				-shake_strength,
				shake_strength
			)
		)

		camera.position = pull_offset + shake_offset

	else:

		var shake_strength = MAX_SHAKE * progress

		camera.position = Vector2(
			randf_range(
				-shake_strength,
				shake_strength
			),
			randf_range(
				-shake_strength,
				shake_strength
			)
		)

	# FINAL CINEMATIC
	if death_timer >= DEATH_DURATION:

		camera.position = Vector2.ZERO

		if shader_material:
			shader_material.set_shader_parameter(
				"distortion_strength",
				0.0
			)

		print("DEATH CINEMATIC FINISHED")
		game_over_ui.show_game_over()
		
func shoot_laser():
	
	laser_sound.play()

	laser.visible = true
	laser_hitbox.monitoring = true

	await get_tree().create_timer(0.15).timeout

	laser.visible = false
	laser_hitbox.monitoring = false


func _on_laser_hitbox_body_entered(body):

	if body.is_in_group("enemy"):

		body.take_damage(ATTACK_DAMAGE)
