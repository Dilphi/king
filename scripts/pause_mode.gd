extends Node2D

@onready var pause_menu = $"../CanvasLayer/PauseMenu"

var game_pause : bool = false

@onready var player: CharacterBody2D = $"../Player"



func save():
	GlobalPlayer.player_pos = player.position


func  _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		game_pause = !game_pause
		
	if game_pause == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()


func _on_resume_pressed() -> void:
	game_pause = !game_pause


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_pause_btn_pressed() -> void:
	game_pause = !game_pause


func _save_game():
	var save_game = FileAccess.open("user://savegame.save",FileAccess.WRITE)
	var json_string = JSON.stringify(save())
	save_game.store_line(json_string)
	

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("Save file not found!")
		return

	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var node_data = {}

	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			node_data = json.get_data()
		else:
			print("Error parsing save file!")
			return

	LoadMeneger.load_game()
	# После загрузки уровня, заново получаем нужные узлы
	player = get_node("../Player")


	# Восстановление состояния игрока
	if node_data.has("hp") and node_data.has("position"):
		GlobalPlayer.healths = node_data["hp"]
		var pos = node_data["position"]
		GlobalPlayer.player_pos = Vector2(pos[0], pos[1])
		player.position = GlobalPlayer.player_pos
		player.set_health(GlobalPlayer.healths)
		print("Game Loaded: Health =", GlobalPlayer.healths, "Position =", GlobalPlayer.player_pos)
	else:
		print("Error: Missing player data")


func _on_save_pressed() -> void:
	# Получение текущего здоровья игрока
	var current_health = player.get_health()  # Убедитесь, что у объекта `player` есть метод `get_health()`
	#var current_health_value = 
	# Получение текущего количества патронов
	var current_ammo = player.get_ammo()
	# Обновление записи в базе данных
	Db.update_player_state(current_health, current_ammo)
	Db.update_save_record()
	# Выключение паузы
	game_pause = !game_pause
	_save_game()
	print("Состояние игрока сохранено: Здоровье:", current_health, "Патроны:", current_ammo)


func _on_load_pressed() -> void:
	load_game()
	game_pause = !game_pause
