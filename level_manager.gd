extends Node

var current_level = 1

var levels = {
	1: ["Cow"],
	2: ["Cow"],
	3: ["Cow"]
}
const COW_SCENE = preload("res://cow.tscn")
func _ready():
	print("Current level:", current_level)

	for enemy in levels[current_level]:
		spawn_enemy(enemy)
	
func spawn_enemy(enemy_name: String):
	if enemy_name == "Cow":
		var cow = COW_SCENE.instantiate()
		get_parent().call_deferred("add_child", cow)
		var spawn = get_parent().get_node("EnemySpawn")
		cow.global_position = spawn.global_position
		print("Groups:", cow.get_groups())
		
