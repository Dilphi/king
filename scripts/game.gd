extends Node

@onready var game_manager: Node = %GameManeger

var level_start_time: float = 0.0
var current_level: int = 1

func _ready():
	for coin in get_node("Coins").get_children():
		coin.add_to_group("Coins")

	start_level_timer()

func _physics_process(delta: float) -> void:
	# Проверка, остались ли объекты монет на сцене
	if get_tree().get_nodes_in_group("Coins").is_empty():
		complete_level()

func start_level_timer():
	# Запоминаем время начала уровня
	level_start_time = Time.get_ticks_msec() / 1000.0

func complete_level():
	# Рассчитываем время прохождения уровня
	var end_time = Time.get_ticks_msec() / 1000.0
	var completion_time = end_time - level_start_time

	# Сохраняем результат в базе данных
	Db.save_level_time(current_level, completion_time)

	# Разблокировка следующего уровня
	var next_level = current_level + 1
	Db.unlock_level(next_level)

	print("Уровень %d завершён за %.1f секунд" % [current_level, completion_time])

	# Переход к следующему уровню
	current_level = next_level
	start_level_timer()
	get_tree().change_scene_to_file("res://scenes/level_%d.tscn" % current_level)
