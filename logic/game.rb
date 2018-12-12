require_relative("board.rb")
require_relative("letters.rb")
require_relative("player.rb")
require_relative("words.rb")
require_relative("error.rb")

require("json")

class Game
    attr_reader :players, :current_turn

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
        # Check if the player passed or forfeited
        if obj[:passed]
            end_turn()
            return true
        end

        if obj[:forfeit]
            # The other player has won or the player will be excluded if there are more players.
            h = {"ended" => true, "winner" => (@current_turn+1) % 2}
            return h
        end

        success = add_new_letters(obj[:tiles])
        # Returns either true or an error hash
        # Send it to the client via the websocket
        return success
    end


    def check_placement(tiles)
        extends = false
        rows = []
        cols = []
        occupied = []

        tiles.each do |tile|
            r = tile[:row]
            c = tile[:col]
            rows << r
            cols << c

            if @board.tiles[r][c].letter != nil
                puts "Occupied!"
                occupied << {"row" => r, "column" => c}
            end

            # Check if there is at least one placed tile next to a new one
            if @board.tiles[r-1][c].letter != nil || @board.tiles[r+1][c].letter != nil
                extends = true
            elsif @board.tiles[r][c-1].letter != nil || @board.tiles[r][c+1].letter != nil
                extends = true
            end

        end

        if occupied.length > 0
            puts "Occupied!"
            return Error.create("tileOccupied", occupied)
        end
        
        if !extends
            # If there are no letters placed then it will fail
            # It's valid if the word is placed on the centre tile
            centre = false
            tiles.each do |tile|
                r = tile[:row]
                c = tile[:col]
                if @board.tiles[r][c].attribute == "centre"
                    centre = true
                    break
                end
            end
            
            if !centre
                puts "Not in the centre or does not extend current board!"
                return Error.create("invalidPlacement", true)
            end
        end

        same_rows = rows.uniq.length == 1
        same_cols = cols.uniq.length == 1

        if !same_rows && !same_cols
            puts "Not all placed on the same row or column!"
            return Error.create("invalidPlacement", true)
        end

        if same_rows
            cols = cols.sort
            p cols
            i = 1
            while i < cols.length
                if cols[i] != cols[i-1] + 1
                    puts "Letters not placed together!"
                    return Error.create("invalidPlacement", true)
                end
                i += 1
            end
        else
            rows = rows.sort
            p rows
            i = 1
            while i < rows.length
                if rows[i] != rows[i-1] + 1
                    puts "Letters not placed together!"
                    return Error.create("invalidPlacement", true)
                end
                i += 1
            end
        end

        puts "Whohoo!"
        return true
    end

    # Input should be an array of letters with their positions
    # letters = [{letter: f, row: 7, col: 4}]
    def add_new_letters(letters)
        p letters

        # Check if an error has been returned.
        # Does not do it currently but should be implemented
        pl = check_placement(letters)
        if pl.is_a? Hash
            puts "An error occured"
            p pl
            # Send the error to the client
            return pl
        end

        # Store indices for later removal
        indices = []
        p @players[@current_turn].rack

        # Go through the letters to confirm they are on the player's rack
        missing = []
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
                missing << tile[:letter]
            end
        end

        if missing.length > 0
            return Error.create("lettersNotOnRack", missing)
        end

        invalid_words = []
        
        # Find all new words
        new_words = find_words(letters)
        p new_words

        if new_words.length == 0
            p "No words found (at least 2 letters)"
            return Error.create("noWordsFound", true)
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
            return Error.create("invalidWords", invalid_words)
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

            end_turn() # Move this out of the method
            return true
        end
    end


    def find_words(tiles)
        # Cheaty way to deep copy
        # tiles = JSON.parse(tiles.to_json, symbolize_names: true)
        tiles_dup = tiles.map{ |letter| letter.dup }

        p "Finding words"
        found_words = []
        axis = nil

        # Check which axis the letters were placed on
        if tiles_dup.length > 1
            if tiles_dup[0][:row] == tiles_dup[1][:row]
                axis = "horizontal"
            else
                axis = "vertical"
            end
        end
        p axis

        # Add the new letters to the board to check new words
        board_copy = @board.deep_clone()
        tiles_dup.each_with_index do |tile, i|
            r = tile[:row]
            c = tile[:col]

            if tile[:letter].is_a? Hash
                board_copy[r][c].letter = tile[:letter][:value]
                tiles_dup[i][:letter] = tile[:letter][:value]
            else
                board_copy[r][c].letter = tile[:letter]
            end
        end
        

        check_vertical = true
        check_horizontal = true
        tiles_dup.each do |tile|
            if check_vertical
                word = check_column(tile, board_copy)
                if word != nil
                    found_words << word
                end
            end

            if check_horizontal
                word = check_row(tile, board_copy)
                if word != nil
                    found_words << word
                end
            end

            # Check the word axis only once to avoid duplicates
            if axis == "vertical"
                check_vertical = false
            elsif axis == "horizontal"
                check_horizontal = false
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
            return word.join()
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

        # Check below
        k = 1
        while board_copy[row + k][col].letter != nil
            word.push(board_copy[row + k][col].letter)
            k += 1
        end

        # p word
        if word.length > 1
            return word.join()
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


    def to_hash(player_number, all=false)
        # Add all the relevant data to a dictionary following the set json format
        # player_number makes the dict player-specific

        # Add the player data to an array of dicts
        players = []
        @players.each_with_index do |player, index|
            dict = {
                name: "Player #{index+1}",
                points: player.points,
                isYou: index == player_number
            }
            players << dict
        end
        
        rack = @players[player_number].rack
        rack.each_with_index do |letter, index|
            if letter.is_a? Blank
                rack[index] = {
                    letter: "blank",
                    value: letter.letter
                }
            end
        end

        dict = {
            board: {},
            players: players,
            you: {
                rack: rack
            },
            currentTurn: @current_turn,
            roundNumber: @round,
            lettersLeft: @letter_bag.length
        }

        dict[:board][:latestUpdatedTiles] = @latest_updated_tiles
        if all
            dict[:board][:tiles] = @board.to_hash
        end

        return {game: dict}
    end

end