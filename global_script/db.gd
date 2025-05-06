extends Node

var db: SQLite
var current_player_id: int = -1

func _init():
	db = SQLite.new()
	db.path = "res://game.db"
	if db.open_db():
		print("DB opened successfully")
		create_tables()
	else:
		print("DB open error:", db.error_message)

func create_tables():
	# Таблица игроков
	db.query("""
	CREATE TABLE IF NOT EXISTS Players (
		player_id INTEGER PRIMARY KEY AUTOINCREMENT,
		username TEXT UNIQUE NOT NULL,
		password TEXT NOT NULL,
		created_at TEXT DEFAULT CURRENT_TIMESTAMP
	);
	""")
	
	# Таблица смертей
	db.query("""
	CREATE TABLE IF NOT EXISTS Deaths (
		death_id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER,
		fall_deaths INTEGER DEFAULT 0,
		mob_deaths INTEGER DEFAULT 0,
		FOREIGN KEY(player_id) REFERENCES Players(player_id)
	);
	""")
	
	# Таблица монет
	db.query("""
	CREATE TABLE IF NOT EXISTS Coins (
		coin_id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER,
		amount INTEGER DEFAULT 0,
		FOREIGN KEY(player_id) REFERENCES Players(player_id)
	);
	""")
	
	# Таблица уровней
	db.query("""
	CREATE TABLE IF NOT EXISTS Levels (
		level_id INTEGER PRIMARY KEY,
		player_id INTEGER,
		is_unlocked BOOLEAN DEFAULT FALSE,
		best_time REAL DEFAULT 0,
		FOREIGN KEY(player_id) REFERENCES Players(player_id)
	);
	""")
	
	# Таблица сохранений
	db.query("""
	CREATE TABLE IF NOT EXISTS Saves (
		save_id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER,
		level_id INTEGER,
		coins INTEGER,
		timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY(player_id) REFERENCES Players(player_id)
	);
	""")

# Регистрация нового игрока
func register_player(username: String, password: String) -> bool:
	var hashed_pw = password.sha256_text()
	var query = "INSERT INTO Players (username, password) VALUES (?, ?);"
	
	if db.query_with_bindings(query, [username, hashed_pw]):
		var player_id = db.get_last_insert_rowid()
		
		# Инициализируем данные для нового игрока
		db.query("INSERT INTO Deaths (player_id) VALUES (%d);" % player_id)
		db.query("INSERT INTO Coins (player_id) VALUES (%d);" % player_id)
		db.query("INSERT INTO Levels (level_id, player_id, is_unlocked) VALUES (1, %d, TRUE);" % player_id)
		
		return true
	return false

# Авторизация игрока
func login(username: String, password: String) -> bool:
	var hashed_pw = password.sha256_text()
	var result = db.select_rows("Players", 
		"username = '%s' AND password = '%s'" % [username, hashed_pw], 
		["player_id"])
	
	if result.size() > 0:
		current_player_id = result[0]["player_id"]
		return true
	return false

# Функции для работы с монетами
func add_coins(amount: int):
	db.query("""
	UPDATE Coins 
	SET amount = amount + %d 
	WHERE player_id = %d;
	""" % [amount, current_player_id])

func get_coins() -> int:
	var result = db.select_rows("Coins", 
		"player_id = %d" % current_player_id, 
		["amount"])
	return result[0]["amount"] if result.size() > 0 else 0

# Функции для смертей
func add_fall_death():
	db.query("""
	UPDATE Deaths 
	SET fall_deaths = fall_deaths + 1 
	WHERE player_id = %d;
	""" % [current_player_id])

func add_mob_death():
	db.query("""
	UPDATE Deaths 
	SET mob_deaths = mob_deaths + 1 
	WHERE player_id = %d;
	""" % [current_player_id])

func get_death_stats() -> Dictionary:
	var result = db.select_rows("Deaths", 
		"player_id = %d" % current_player_id, 
		["fall_deaths", "mob_deaths"])
	
	if result.size() > 0:
		return {
			"falls": result[0]["fall_deaths"],
			"mobs": result[0]["mob_deaths"]
		}
	return {"falls": 0, "mobs": 0}

# Функции для уровней
func save_level_time(level_id: int, time: float):
	# Проверяем есть ли запись
	var existing = db.select_rows("Levels", 
		"level_id = %d AND player_id = %d" % [level_id, current_player_id], 
		["best_time"])
	
	if existing.size() > 0:
		# Обновляем если новое время лучше
		var best_time = existing[0]["best_time"]
		if time < best_time or best_time == 0:
			db.query("""
			UPDATE Levels 
			SET best_time = %f 
			WHERE level_id = %d AND player_id = %d;
			""" % [time, level_id, current_player_id])
	else:
		# Создаем новую запись
		db.query("""
		INSERT INTO Levels (level_id, player_id, best_time)
		VALUES (%d, %d, %f);
		""" % [level_id, current_player_id, time])

func unlock_level(level_id: int):
	db.query("""
	INSERT OR IGNORE INTO Levels (level_id, player_id, is_unlocked)
	VALUES (%d, %d, TRUE);
	""" % [level_id, current_player_id])

func is_level_unlocked(level_id: int) -> bool:
	var result = db.select_rows("Levels", 
		"level_id = %d AND player_id = %d" % [level_id, current_player_id], 
		["is_unlocked"])
	return result[0]["is_unlocked"] if result.size() > 0 else false

# Функции сохранения/загрузки
func save_game(level_id: int):
	var coins = get_coins()
	db.query("""
	INSERT INTO Saves (player_id, level_id, coins)
	VALUES (%d, %d, %d);
	""" % [current_player_id, level_id, coins])

func load_game() -> Dictionary:
	var result = db.select_rows(
		"Saves", 
		"player_id = %d" % current_player_id, 
		["level_id", "coins"],
	)
	
	if result.size() > 0:
		return {
			"level": result[0]["level_id"],
			"coins": result[0]["coins"]
		}
	return {"level": 1, "coins": 0}
