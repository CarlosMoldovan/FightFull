extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("BUTTON")
	get_tree().change_scene_to_file("res://Scenes/Arena/arena.tscn")


func _on_button_2_pressed() -> void:
	print("STORY")
	get_tree().change_scene_to_file("res://Scenes/StoryArena/story_arena.tscn")
