extends Area2D

const SPEED = 500.0
const GRAVITY = 900.0
const ARC_FORCE = -650.0
const DAMAGE = 10

var direction = Vector2.ZERO
var velocity = Vector2.ZERO

func _physics_process(delta):
	velocity.x = direction.x * SPEED
	velocity.y += GRAVITY * delta

	position += velocity * delta


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(DAMAGE)
		queue_free()
