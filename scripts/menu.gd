extends Control
@onready var pause_mode: Node2D = %PauseMode

# Если используешь LoadManager через Autoload
func _ready() -> void:
	# Показывать кнопку Continue только если файл существует
	$VBoxContainer/Continue.visible = LoadMeneger.load_save_file()

func _on_new_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	LoadMeneger.load_game()
