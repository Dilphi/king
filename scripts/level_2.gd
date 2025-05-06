extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Разблокировать уровень
	Db.unlock_level(2)
	# Сохранить время прохождения уровня (в секундах)
	Db.save_level_time(1, 120.5)  # Уровень 1, время 2 минуты 0.5 секунды


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
