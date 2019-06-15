require_relative 'webapp/db-comm'

# p Database.create_user "Uffe", "123"
# p Database.get_user "kalle"
Database.create_game 2, nil, File.read("game.json")
p Database.all_games
# Database.delete_game 2