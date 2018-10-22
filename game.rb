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
        

        # Game variables
        @current_turn = 0
        @round = 1
        @latest_updated_tiles = []

    end


    def check_placement(tiles)
        tiles.each do |tile|
            r = tile[:row]
            c = tile[:col]

            if @board.tiles[r][c].letter != nil
                return false
            end
        end

        return true
    end

    # Input should be an array of letters with their positions
    # letters = [
    #               {
    #                 letter: f,
    #                 row: 7,
    #                 col: 4
    #               }
    #           ]
    def add_new_letters(letters)

        if !check_placement(letters)
            # Not a valid turn, return to client
            puts "INVALID! TILES ALREADY ASSIGNED"
        end
        
        invalid_words = []
        
        # Find all new words
        new_words = findWords(letters)
        p new_words

        #Check if they are valid
        new_words.each do |word|
            if !@words.is_word?(word)
                invalid_words << word
            end
        end

        if invalid_words.length > 0
            # Not a valid turn, return to the client
            p "INVALID! #{invalid_words} are not valid words."
        else
            # Update the tiles and calculate the points
            lut = []

            letters.each do |letter|
                @board.update_tile(letter[:row], letter[:col], letter[:letter])

                lut << {
                    row: letter[:row],
                    column: letter[:col]
                }
            end

            @latest_updated_tiles = lut

            points = 0
            new_words.each do |word|
                points += calculate_points(word)
            end

            # Add the points to the player
            @players[@current_turn].points += points

            end_turn()
        end
    end


    def findWords(tiles)
        p "Finding words"
        found_words = []
        
        # BUGS:
        # It only checks letters already on the board, not the new ones.

        # Horizontal words
        tiles.each do |tile|
            row = tile[:row]
            col = tile[:col]
            word = [tile[:letter]]
            
            # Check to the left
            k = 1
            while @board.tiles[row][col - k].letter != nil
                word.unshift(@board.tiles[row][col - k].letter)
                k += 1
            end

            # Check to the right
            k = 1
            while @board.tiles[row][col + k].letter != nil
                word.push(@board.tiles[row][col + k].letter)
                k += 1
            end

            # p word
            if word.length > 1
                s = ""
                word.each do |char|
                    s += char
                end

                found_words << s
            end
        end

        # Vertical words
        tiles.each do |tile|
            row = tile[:row]
            col = tile[:col]
            word = [tile[:letter]]
            
            # Check above
            k = 1
            while @board.tiles[row - k][col].letter != nil
                word.unshift(@board.tiles[row - k][col].letter)
                k += 1
            end

            # Check under
            k = 1
            while @board.tiles[row + k][col].letter != nil
                word.push(@board.tiles[row + k][col].letter)
                k += 1
            end

            # p word
            if word.length > 1
                s = ""
                word.each do |char|
                    s += char
                end

                found_words << s
            end
        end

        return found_words
    end


    def calculate_points(word)
        # Does not work with blanks
        
        points = 0
        word.each_char do |letter|
            points += @letter_bag.get_points(letter)
        end

        return points
    end


    def end_turn()
        @players[@current_turn].my_turn = false

        @current_turn += 1
        if @current_turn >= @players.length
            @current_turn = 0
            @round += 1
        end

        @players[@current_turn].my_turn = true

        @players.each do |player|
            if player.rack.length < 7
                new_letters = @letter_bag.draw(7 - player.rack.length)
                player.add_to_rack(new_letters)
            end
        end

        # Send new info to the clients
    end


    def dictify(playerNumber)
        # Add all the relevant data to a dictionary following the set json format
        # playerNumber makes the dict player-specific

        # Add the player data to an array of dicts
        players = []
        @players.each_with_index do |player, index|
            dict = {
                name: "Player #{index+1}",
                points: player.points,
                isYou: index == playerNumber
            }
            players << dict
        end
        

        dict = {
            board: @board.json(),
            players: players,
            you: {
                rack: @players[playerNumber].rack
            },
            currentTurn: @current_turn,
            roundNumber: @round,
            lettersLeft: @letter_bag.length
        }
        dict[:board][:latestUpdatedTiles] = @latest_updated_tiles

        return dict
    end

end