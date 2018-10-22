require_relative("board.rb")
require_relative("letters.rb")
require_relative("player.rb")
require_relative("words.rb")

require("json")

class Game
    def initialize(number_of_players)

        if number_of_players > 4
            raise ArgumentError, "The maximum amount of players is 4."
        end
        if number_of_players < 2
            raise ArgumentError, "The minimum amount of players is 2."
        end

        # Create all the necessary classes
        @board = Board.new
        @letter_bag = Letters.new
        @words = Words.new

        # Create the players
        @players = []
        number_of_players.times do
            player = Player.new
            player.add_to_rack(@letter_bag.draw(7))

            @players << player
        end
        # Set the turn to be the first player's
        @players[0].my_turn = true
        @current_turn = 0

        # Game variables
        @round = 0

    end


    def add_new_letters(letters)
        invalid_words = []
        
        # Find all new words
        new_words = []

        #Check if they are valid
        new_words.each do |word|
            if !@words.is_word?(word)
                invalid_words << word
            end
        end

        if invalid_words.length > 0
            # Not a valid turn, return to the client
        else
            # Add the tiles and calculate the points


            points = 0
            new_words.each do |word|
                points += calculate_points(word)
            end
            # Add the points to the player
            @players[current_turn] += points

        end
    end


    def calculate_points(word)
        # Not working with blanks
        
        points = 0
        word.each_char do |letter|
            points += @letter_bag.get_points(letter)
        end

        return points
    end

end