require 'sqlite3'

db = SQLite3::Database.new 'database.db'
db.execute("DROP TABLE IF EXISTS currentgames")
db.execute("DROP TABLE IF EXISTS finishedgames")
db.execute(
    "CREATE TABLE currentgames 
    (id INTEGER PRIMARY KEY UNIQUE, room_id INTEGER NOT NULL UNIQUE, 
    player1 VARCHAR(64), player2 VARCHAR(64), player3 VARCHAR(64), player4 VARCHAR(64), 
    game_data VARCHAR(8192))"
)
db.execute(
    "CREATE TABLE finishedgames
    (id INTEGER PRIMARY KEY UNIQUE,
    player1 VARCHAR(64), player2 VARCHAR(64), player3 VARCHAR(64), player4 VARCHAR(64),
    scores VARCHAR(64), winner VARCHAR(64))"
)