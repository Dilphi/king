extends Control

# Ссылки на элементы интерфейса
@onready var username_input: LineEdit = $VBoxContainer/Name
@onready var password_input: LineEdit = $VBoxContainer/Password
@onready var reg_button: Button = $VBoxContainer/Reg
@onready var auth_button: Button = $VBoxContainer/Aut
@onready var message_label: Label = $VBoxContainer/Message

func _ready():
	# Подключаем сигналы кнопок
	reg_button.connect("pressed", Callable(self, "_on_reg_button_pressed"))
	auth_button.connect("pressed", Callable(self, "_on_auth_button_pressed"))
	
	# Настраиваем поле ввода пароля
	password_input.secret = true  # Скрываем пароль звездочками

func _on_reg_button_pressed():
	var username = username_input.text
	var password = password_input.text
	
	# Валидация ввода
	if username.strip_edges().length() < 3:
		show_message("Имя должно быть не короче 3 символов")
		return
		
	if password.length() < 4:
		show_message("Пароль должен быть не короче 4 символов")
		return
	
	# Пытаемся зарегистрировать
	if Db.register_player(username, password):
		show_message("Регистрация успешна! Теперь войдите")
	else:
		show_message("Ошибка: имя уже занято")

func _on_auth_button_pressed():
	var username = username_input.text
	var password = password_input.text
	
	if Db.login(username, password):
		show_message("Вход выполнен!")
		# Переходим в главное меню после успешной авторизации
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	else:
		show_message("Ошибка: неверное имя или пароль")

func show_message(text: String):
	message_label.text = text
	message_label.modulate.a = 1.0  # Делаем видимым
	
	# Плавное исчезновение сообщения через 3 секунды
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 0.0, 1.0).set_delay(3.0)
	tween.tween_callback(message_label.set.bind("text", ""))
	tween.tween_property(message_label, "modulate:a", 1.0, 0.1)
