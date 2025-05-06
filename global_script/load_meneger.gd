extends Node
@onready var player: CharacterBody2D = $player/Player
var saved_data = {}

func save(data):
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()

func load_save_file(): 
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
	if not load_save_file():  
		return

	var scene_path = saved_data.get("level_scene", "")
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
		await get_tree().process_frame

func select_level():
	pass
