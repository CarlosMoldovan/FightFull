extends Node2D


@onready var viewport_container = $SubViewportContainer
@onready var sub_viewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/World3D/Camera3D
@onready var black_hole = $SubViewportContainer/SubViewport/World3D/BlackHole3D


const CAMERA_SPEED = 0.5


func _ready():

	var screen_size = get_viewport().get_visible_rect().size

	viewport_container.position = Vector2.ZERO
	viewport_container.size = screen_size

	sub_viewport.size = screen_size
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	camera.current = true

	print("STORY ARENA STARTED")
	print("SCREEN SIZE:", screen_size)


func _process(delta):

	camera.position.z -= CAMERA_SPEED * delta
