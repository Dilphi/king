extends Control

@onready var pause_mode: Node2D = %PauseMode

func _on_new_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	LoadMeneger.load_game()


func _on_statistic_pressed() -> void:
	$VBoxContainer.visible = false
	$Back.visible = true
	$Stat.visible = true


func _ready():
	# Показывать кнопку Continue только если файл существует
	$VBoxContainer/Continue.visible = LoadMeneger.load_save_file()

	var text := ""
	text += get_coins_text()
	text += "\n" + get_deaths_text()
	text += "\n" + get_times_text()

	$Stat/InfoLabel.text = text


func get_coins_text() -> String:
	var data = Db.get_all_coins_info()
	var result = "💰 Монеты:\n"
	for row in data:
		result += "- %s: %d монет\n" % [row["username"], row["amount"]]
	return result

func get_deaths_text() -> String:
	var data = Db.get_all_death_info()
	var result = "💀 Смерти:\n"
	for row in data:
		result += "- %s: Падения: %d, Мобы: %d\n" % [row["username"], row["fall_deaths"], row["mob_deaths"]]
	return result

func get_times_text() -> String:
	var data = Db.get_all_best_times()
	var result = "⏱️ Лучшее время:\n"
	for row in data:
		result += "- %s (уровень %d): %.2f сек\n" % [row["username"], row["level_id"], row["best_time"]]
	return result


func _on_back_pressed() -> void:
	$Back.visible = false
	$VBoxContainer.visible = true
	$Stat.visible = false
