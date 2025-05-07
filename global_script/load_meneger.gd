extends Node
@onready var player: CharacterBody2D = $Player

var saved_data = {}

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



# Загружаем файл сохранения и возвращаем true/false
func load_save_file() -> bool:
	if not FileAccess.file_exists("user://savegame.save"):
		print("Файл не найден")
		return false

	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = file.get_line()
	var json = JSON.new()
	if json.parse(json_string) == OK:
		saved_data = json.get_data()
		return true
	else:
		print("Ошибка парсинга JSON")
		return false

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
