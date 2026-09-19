extends Node

var current_level = 1
var level_finished = false

var levels = {
	1: ["Monkey"],
	2: ["Frog"],
	3: ["Wboar"],
	4: ["Raw"],
	5: ["Chicken"],
	6: ["Cow"]
}

const COW_SCENE = preload("res://Scenes/Cow/cow.tscn")
const CHICKEN_SCENE = preload("res://Scenes/Chicken/chicken.tscn")
const RAW_SCENE = preload("res://Scenes/Raw/raw.tscn")
const FROG_SCENE = preload("res://Scenes/Frog/frog.tscn")
const WBOAR_SCENE = preload("res://Scenes/WildBoar/wild_boar.tscn")
const MONKEY_SCENE = preload("res://Scenes/Monkey/monkey.tscn")


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
	
	elif enemy_name == "Frog":
		var frog = FROG_SCENE.instantiate()
		var spawn = get_parent().get_node("EnemySpawn")
		frog.global_position = spawn.global_position
		get_parent().call_deferred("add_child", frog)
		
	elif enemy_name == "Wboar":
		var wb = WBOAR_SCENE.instantiate()
		var spawn = get_parent().get_node("EnemySpawn")
		wb.global_position = spawn.global_position
		get_parent().call_deferred("add_child", wb)
		
	elif enemy_name == "Monkey":
		var monkey = MONKEY_SCENE.instantiate()
		var spawn = get_parent().get_node("EnemySpawn")
		monkey.global_position = spawn.global_position
		get_parent().call_deferred("add_child", monkey)
		
		


func level_complete():

	print("LEVEL COMPLETE!")

	await get_tree().create_timer(2.0).timeout

	current_level += 1

	if !levels.has(current_level):
		print("GAME COMPLETED!")
		return

	start_level()
