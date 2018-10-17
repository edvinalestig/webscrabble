require_relative("board.rb")
require_relative("letters.rb")
require_relative("player.rb")
require_relative("words.rb")

class Game
    def initialize(number_of_players)

        if number_of_players > 4
            raise "The maximum amount of players is 4."
        end
        if number_of_players < 2
            raise "The minimum amount of players is 2."
        end

        # Create all the necessary classes
        @board = Board.new
        @letters = Letters.new
        @words = Words.new

        # Create the players
        @players = []
        number_of_players.times do
            player = Player.new
            player.add_to_rack(@letters.draw(7))

            @players << player
        end
        # Set the turn to be the first player's
        @players[0].my_turn = true

        # Game variables
        @round = 0

        
        
    end

end