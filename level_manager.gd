extends Node

var current_level = 1
var level_finished = false

var levels = {
	1: ["Cow"],
	2: ["Cow"],
	3: ["Cow"]
}

const COW_SCENE = preload("res://cow.tscn")


func _ready():
	start_level()


func _process(delta):

	if level_finished:
		return

	var enemies = get_tree().get_nodes_in_group("enemy")

	if enemies.size() == 0:
		level_finished = true
		level_complete()


func start_level():

	level_finished = false

	print("Current level:", current_level)

	for enemy in levels[current_level]:
		spawn_enemy(enemy)


func spawn_enemy(enemy_name: String):

	if enemy_name == "Cow":
		var cow = COW_SCENE.instantiate()

		var spawn = get_parent().get_node("EnemySpawn")
		cow.global_position = spawn.global_position

		get_parent().call_deferred("add_child", cow)


func level_complete():

	print("LEVEL COMPLETE!")

	await get_tree().create_timer(2.0).timeout

	current_level += 1

	if !levels.has(current_level):
		print("GAME COMPLETED!")
		return

	start_level()
