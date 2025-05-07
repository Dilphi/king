extends Node2D

@onready var pause_menu = $"../CanvasLayer/PauseMenu"
@onready var player: CharacterBody2D = $"../Player"
var game_pause : bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		game_pause = !game_pause
		
	if game_pause:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()

func _on_resume_pressed() -> void:
	game_pause = !game_pause

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_pause_btn_pressed() -> void:
	game_pause = !game_pause


func save():
	var data = {
		"level_scene": get_tree().current_scene.scene_file_path,
		"player_position": {"x": player.position.x, "y": player.position.y},

		"coins": Db.get_coins()
	}
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()
	Db.save_game(GlobalPlayer.current_level, data["coins"])

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("Сохранение не найдено")
		return

	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json = JSON.new()
	var content = file.get_line()
	if json.parse(content) != OK:
		print("Ошибка парсинга JSON")
		return

	var data = json.get_data()
	var level_scene = data.get("level_scene", "")
	var pos_dict = data.get("player_position", {"x": 0, "y": 0})

	if typeof(pos_dict) == TYPE_DICTIONARY:
		var pos = Vector2(pos_dict["x"], pos_dict["y"])
		GlobalPlayer.player_pos = pos
	else:
		print("Ошибка: позиция игрока не в виде словаря")
		GlobalPlayer.player_pos = Vector2.ZERO

	if level_scene != "":
		get_tree().change_scene_to_file(level_scene)


func _on_area_2d_body_entered(body: Node2D) -> void:
	save()
