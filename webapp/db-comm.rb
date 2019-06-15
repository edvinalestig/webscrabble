require 'sqlite3'

class Database

    def self.get_user username
        db = SQLite3::Database.new 'database.db'
        db.results_as_hash = true

        return db.execute("SELECT * FROM users WHERE username = ?", [username]).first
    end

    def self.create_user username, password
        db = SQLite3::Database.new 'database.db'
        db.results_as_hash = true

        if self.get_user username
            return false
        end
        db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, password])
        return true
    end

    def self.create_game room, players, data
        db = SQLite3::Database.new 'database.db'
        db.results_as_hash = true

        db.execute(
            "INSERT INTO currentgames (room_id, game_data) VALUES (?, ?)",
            [room, data]
        )
    end

    def self.update_game room, data
        db = SQLite3::Database.new 'database.db'

        db.execute("UPDATE currentgames SET game_data = ? WHERE room_id = ?", [data, room])
        return self.get_game room
    end

    def self.get_game room
        db = SQLite3::Database.new 'database.db'
        db.results_as_hash = true

        return db.execute("SELECT * FROM currentgames WHERE room_id = ?", [room]).first
    end

    def self.delete_game room
        db = SQLite3::Database.new 'database.db'
        db.execute("DELETE FROM currentgames WHERE room_id = ?", [room])
    end

    def self.all_games
        db = SQLite3::Database.new 'database.db'
        db.results_as_hash = true

        return db.execute("SELECT * FROM currentgames")
    end
end