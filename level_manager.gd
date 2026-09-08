extends Node

var current_level = 1
var level_finished = false

var levels = {
	1: ["Raw"],
	2: ["Chicken"],
	3: ["Cow"]
}

const COW_SCENE = preload("res://cow.tscn")
const CHICKEN_SCENE = preload("res://chicken.tscn")
const RAW_SCENE = preload("res://raw.tscn")


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

	elif enemy_name == "Chicken":
		var chicken = CHICKEN_SCENE.instantiate()

		var spawn = get_parent().get_node("EnemySpawn")
		chicken.global_position = spawn.global_position

		get_parent().call_deferred("add_child", chicken)

	elif enemy_name == "Raw":
		var ram = RAW_SCENE.instantiate()

		var spawn = get_parent().get_node("EnemySpawn")
		ram.global_position = spawn.global_position

		get_parent().call_deferred("add_child", ram)


func level_complete():

	print("LEVEL COMPLETE!")

	await get_tree().create_timer(2.0).timeout

	current_level += 1

	if !levels.has(current_level):
		print("GAME COMPLETED!")
		return

	start_level()
