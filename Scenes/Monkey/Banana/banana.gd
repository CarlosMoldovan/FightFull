extends Area2D

const SPEED = 600.0
const DAMAGE = 10

var direction = Vector2.ZERO


func _ready():
	body_entered.connect(_on_body_entered)


func _physics_process(delta):

	position += direction * SPEED * delta


func _on_body_entered(body):

	if body.is_in_group("player"):

		body.take_damage(DAMAGE)
		queue_free()
