extends Node
@onready var score_label: Label = $ScoreLabel


var score = 0

func add_point():
	score +=1
	score_label.text = "Собранно: " + str(score) + " монет из 8"

func select_level():
	if score == 9:
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")
