extends CanvasLayer


@onready var panel = $Control/CenterContainer/Panel
@onready var play_again_button = $Control/CenterContainer/Panel/VBoxContainer/Button
@onready var main_menu_button = $Control/CenterContainer/Panel/VBoxContainer/Button2


func _ready():

	hide()

	play_again_button.pressed.connect(
		_on_play_again_pressed
	)

	main_menu_button.pressed.connect(
		_on_main_menu_pressed
	)


func show_game_over():

	show()

	get_tree().paused = true


func _on_play_again_pressed():

	get_tree().paused = false

	get_tree().reload_current_scene()


func _on_main_menu_pressed():

	get_tree().paused = false

	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
	)
