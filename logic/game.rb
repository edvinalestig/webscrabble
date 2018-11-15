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


    def response(obj)
        p obj

        add_new_letters(obj[:tiles])
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
        p letters

        if !check_placement(letters)
            # Not a valid turn, return to client
            puts "INVALID! TILES ALREADY ASSIGNED"
            return false
        end

        # Store indices for later removal
        indices = []
        p @players[@current_turn].rack

        # Go through the letters to confirm they are on the player's rack
        letters.each do |tile|
            found = false
            blank = false
            if tile[:letter].is_a? Hash
                blank = tile[:letter][:letter] == "blank"
            end

            @players[@current_turn].rack.each_with_index do |letter, i|
                if (blank and letter.is_a? Blank) or (!blank and tile[:letter] == letter)
                    if !indices.include? i
                        # Save the index
                        found = true
                        indices << i
                        break
                    end
                end
            end            


            if !found 
                puts "Letter #{tile[:letter]} not on player's rack."

                # Change later to tell the client
                return false
            end
        end

        invalid_words = []
        
        # Find all new words
        new_words = findWords(letters)
        p new_words

        if new_words.length == 0
            p "No words found (at least 2 letters)"
            return false
        end

        #Check if they are valid
        new_words.each do |word|
            if !@words.word?(word)
                invalid_words << word
            end
        end

        if invalid_words.length > 0
            # Not a valid turn, return to the client
            p "INVALID! #{invalid_words} are not valid words."
            return false
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

            # Remove letters from the player's rack
            p "Removing #{letters}"

            # Go through the array backwards to avoid removing wrong letters because of changing indices
            indices = indices.sort.reverse

            indices.each do |i|
                @players[@current_turn].rack.slice!(i)
            end

            end_turn()
            return true
        end
    end


    def findWords(tiles)
        # Cheaty way to deep copy
        tiles = JSON.parse(tiles.to_json, symbolize_names: true)
        p "Finding words"
        found_words = []
        axis = nil

        # Check which axis the letters were placed on
        if tiles.length > 1
            if tiles[0][:row] == tiles[1][:row]
                axis = "horizontal"
            else
                axis = "vertical"
            end
        end
        p axis

        # Add the new letters to the board to check new words
        board_copy = @board.deep_clone()
        tiles.each_with_index do |tile, i|
            r = tile[:row]
            c = tile[:col]

            if tile[:letter].is_a? Hash
                board_copy[r][c].letter = tile[:letter][:value]
                tiles[i][:letter] = tile[:letter][:value]
            else
                board_copy[r][c].letter = tile[:letter]
            end
        end
        

        # Horizontal words
        if axis == "horizontal"
            # Check the horizontal word only once to avoid duplicates
            word = check_row(tiles.first, board_copy)
            if word != nil
                found_words << word
            end
        else
            tiles.each do |tile|
                word = check_row(tile, board_copy)
                if word != nil
                    found_words << word
                end
            end
        end

        # Vertical words
        if axis == "vertical"
            word = check_column(tiles.first, board_copy)
            if word != nil
                found_words << word
            end
        else
            tiles.each do |tile|
                word = check_column(tile, board_copy)
                if word != nil
                    found_words << word
                end
            end
        end

        return found_words
    end


    def check_row(tile, board_copy)
        row = tile[:row]
        col = tile[:col]
        word = [tile[:letter]]
        
        # Check to the left
        k = 1
        while board_copy[row][col - k].letter != nil
            word.unshift(board_copy[row][col - k].letter)
            k += 1
        end

        # Check to the right
        k = 1
        while board_copy[row][col + k].letter != nil
            word.push(board_copy[row][col + k].letter)
            k += 1
        end

        # p word
        if word.length > 1
            s = ""
            word.each do |char|
                s += char
            end

            return s
        else
            return nil
        end
    end


    def check_column(tile, board_copy)
        row = tile[:row]
        col = tile[:col]
        word = [tile[:letter]]
        
        # Check above
        k = 1
        while board_copy[row - k][col].letter != nil
            word.unshift(board_copy[row - k][col].letter)
            k += 1
        end

        # Check under
        k = 1
        while board_copy[row + k][col].letter != nil
            word.push(board_copy[row + k][col].letter)
            k += 1
        end

        # p word
        if word.length > 1
            s = ""
            word.each do |char|
                s += char
            end

            return s
        else
            return nil
        end
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

        # Change the turn
        @current_turn += 1
        if @current_turn >= @players.length
            @current_turn = 0
            @round += 1
        end

        @players[@current_turn].my_turn = true

        # Refill the racks
        @players.each do |player|
            if player.rack.length < 7
                new_letters = @letter_bag.draw(7 - player.rack.length)
                player.add_to_rack(new_letters)
                p "Adding: #{new_letters}"
            end
        end

        # Send new info to the clients
    end


    def to_hash(playerNumber)
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
        
        rack = @players[playerNumber].rack
        rack.each_with_index do |letter, index|
            if letter.is_a? Blank
                rack[index] = {
                    letter: "blank",
                    value: letter.letter
                }
            end
        end

        dict = {
            board: @board.to_hash,
            players: players,
            you: {
                rack: rack
            },
            currentTurn: @current_turn,
            roundNumber: @round,
            lettersLeft: @letter_bag.length
        }
        dict[:board][:latestUpdatedTiles] = @latest_updated_tiles

        return dict
    end

end