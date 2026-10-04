extends Area2D


var is_open = false


func _ready():
	$AnimatedSprite2D.play("closed")


func open_rocket():
	if is_open:
		return

	is_open = true
	$AnimatedSprite2D.play("open")

	print("ROCKET OPENED")


func start_flying():
	if is_open:
		$AnimatedSprite2D.play("fly")
		print("ROCKET STARTED FLYING")
