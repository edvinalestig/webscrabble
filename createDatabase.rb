require 'sqlite3'

db = SQLite3::Database.new 'database.db'
db.execute("DROP TABLE IF EXISTS currentgames;")
db.execute("DROP TABLE IF EXISTS finishedgames;")
db.execute("DROP TABLE IF EXISTS users;")
db.execute(
    "CREATE TABLE currentgames 
    (id INTEGER PRIMARY KEY UNIQUE, room_id INTEGER NOT NULL UNIQUE, 
    player1 VARCHAR(16), player2 VARCHAR(16), player3 VARCHAR(16), player4 VARCHAR(16),
    game_data VARCHAR(8192),
    FOREIGN KEY(player1) REFERENCES users(id), FOREIGN KEY(player2) REFERENCES users(id), 
    FOREIGN KEY(player3) REFERENCES users(id), FOREIGN KEY(player4) REFERENCES users(id));"
)
db.execute(
    "CREATE TABLE finishedgames
    (id INTEGER PRIMARY KEY UNIQUE,
    player1 VARCHAR(16), player2 VARCHAR(16), player3 VARCHAR(16), player4 VARCHAR(16),
    scores VARCHAR(64), winner VARCHAR(16),
    FOREIGN KEY(player1) REFERENCES users(id), FOREIGN KEY(player2) REFERENCES users(id), 
    FOREIGN KEY(player3) REFERENCES users(id), FOREIGN KEY(player4) REFERENCES users(id),
    FOREIGN KEY(winner) REFERENCES users(id));"
)
db.execute(
    "CREATE TABLE users
    (id INTEGER PRIMARY KEY UNIQUE,
    username VARCHAR(16) NOT NULL UNIQUE, password VARCHAR(64) NOT NULL);"
)