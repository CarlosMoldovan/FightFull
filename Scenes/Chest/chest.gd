extends Area2D


var player_near = false
var is_open = false


func _ready():
	$AnimatedSprite2D.play("closed")


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		print("PLAYER NEAR CHEST")


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		print("PLAYER LEFT CHEST")
		
func _process(delta):
	if player_near and not is_open and Input.is_key_pressed(KEY_E):
		open_chest()


func open_chest():
	if is_open:
		return

	is_open = true
	$AnimatedSprite2D.play("open")

	print("CHEST OPENED")
