extends Area2D
@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	Engine.time_scale = 0.5
	Db.add_mob_death()
	body.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout() -> void:
	Db.add_fall_death()
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
