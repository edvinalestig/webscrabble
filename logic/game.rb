require_relative("board.rb")
require_relative("letters.rb")
require_relative("player.rb")
require_relative("words.rb")
require_relative("error.rb")

require("json")


# The main game class. Every ongoing game will be its own instance of the class.
# Arguments:
# number_of_players - 2, 3 or 4.
class Game
    attr_reader :players, :current_turn
    attr_accessor :winner

    # Creates the game and sets up the start conditions. The board, the players and the letter bag are created.
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
        @winner = nil
        @ended = false
    end

    # The method to call when a player has ended their turn.
    # Arguments:
    # obj - A hash in the clienttoserver.json format
    # Returns boolean or Hash if the player forfeited or someone has won.
    def response(obj, player=nil)
        p obj

        if player == nil
            player = obj[:player]
        end

        if obj[:forfeit]
            # The other player has won or the player will be excluded if there are more players
            if player > 1
                return {
                    error: {
                        notYourTurn: "You are a spectator!"
                    }
                }
            end
            @winner = (player+1) % 2
            @ended = true
            h = {"ended" => true, "winner" => @winner}
            p "FORFEIT"
            
            return h
        end

        if player != @current_turn
            return {
                error: {
                    notYourTurn: true
                }
            }
        end

        # Check if the player passed or forfeited
        if obj[:passed]
            end_turn()
            return true
        end

        success = add_new_letters(obj[:tiles])
        # Returns either true or an error hash
        # Send it to the client via the websocket

        # Check if the game has ended and if so who the winner is
        # No draws allowed!
        if check_end()
            player = nil
            points = 0
            @players.each_with_index do |players, i|
                if players.points > points
                    player = i
                end
            end
            @winner = player
            @ended = true
            p "WINNER"
            return {"ended" => true, "winner" => @winner}
        end

        return success
    end

    # Checks if the game has ended
    # Goes through the racks and the bag to see if they are all 
    # empty in which case the game has ended
    # Returns nil
    def check_end()
        if @letter_bag.length > 0
            return false
        end

        @players.each do |player|
            if player.rack.length > 0
                return false
            end
        end

        return true
    end


    # Method to check if the placement is valid or not.
    # Arguments:
    # tiles - Array with the newly placed letters.
    # Returns true or an error message in the form of a Hash.
    def check_placement(tiles)
        extends = false
        rows = []
        cols = []
        occupied = []

        tiles.each do |tile|
            r = tile[:row]
            c = tile[:column]
            rows << r
            cols << c
            p r
            p c

            # Check if the tile already has a letter on it.
            if @board.tiles[r][c].letter != nil
                puts "Occupied!"
                occupied << {"row" => r, "column" => c}
            end

            # Check if there is at least one placed tile next to a new one.
            # The letters has to be connected to the old letters already on the board.
            if @board.tiles[r-1][c].letter != nil
                extends = true
            elsif @board.tiles[r][c-1].letter != nil
                extends = true
            end
            begin
                if @board.tiles[r+1][c].letter != nil
                    extends = true
                end
            rescue NoMethodError
            end
            begin
                if @board.tiles[r][c+1].letter != nil
                    extends = true
                end
            rescue NoMethodError
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
                c = tile[:column]
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

        # Check if the placed tiles are placed in the same column or row.
        # One of them has to be true for it to be a valid turn.
        same_rows = rows.uniq.length == 1
        same_cols = cols.uniq.length == 1

        if !same_rows && !same_cols
            puts "Not all placed on the same row or column!"
            return Error.create("invalidPlacement", true)
        end

        # Check if the letters are placed together in a continous line.
        # Sort the rows/columns and check if they have a gap between them.
        gaps = []
        if same_rows
            cols = cols.sort
            p cols
            i = 1
            while i < cols.length
                # Check if there is a gap
                if cols[i] - cols[i-1] != 1
                    # Add all the cols in the gap to an array
                    gaps.concat [*(cols[i-1] + 1)..(cols[i] - 1)]
                end
                i += 1
            end

            if gaps.length > 0
                # There are gaps in the word
                gaps.each do |col|
                    # Check if the gaps already have letters
                    if @board.tiles[rows[0]][col].letter == nil
                        puts "Letters not placed together!"
                        return Error.create("invalidPlacement", true)
                    end
                end
            end
        else
            rows = rows.sort
            p rows
            i = 1
            while i < rows.length
                if rows[i] - rows[i-1] != 1
                    gaps.concat [*(rows[i-1] + 1)..(rows[i] - 1)]
                end
                i += 1
            end

            if gaps.length > 0
                # There are gaps
                gaps.each do |row|
                    # Check if the gaps already have letters
                    if @board.tiles[row][cols[0]].letter == nil
                        puts "Letters not placed together!"
                        return Error.create("invalidPlacement", true)
                    end
                end
            end
        end

        puts "Whohoo!"
        return true
    end


    # Method for adding the new letters on the board.
    # Error checks are performed before committing.
    # Arguments: 
    # letters - Array of the placed tiles.
    # Returns true or an error message in the form of a Hash.
    def add_new_letters(letters)
        p letters

        letters.each do |letter|
            if letter[:letter].is_a? Hash
                if letter[:letter][:value] == nil
                    return {
                        error: {
                            invalidPlacement: "Letter not chosen for a blank tile"
                        }
                    }
                end
            end
        end

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
                if (blank && letter.is_a?(Hash)) || (!blank && tile[:letter] == letter)
                    if !indices.include? i
                        # Save the index
                        found = true
                        indices << i
                        break
                    end
                elsif !blank && tile[:letter] == letter

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
        # Returns the words as an array of letters, not a string. This is to preserve blanks.
        p "new_words: #{new_words}"

        if new_words.length == 0
            p "No words found (at least 2 letters)"
            return Error.create("noWordsFound", true)
        end

        # Turn the word arrays into strings for validity checks.
        new_words.each do |word|
            word_str = ""
            word.each do |char|
                if char[:letter].is_a? String
                    word_str.concat char[:letter]
                elsif char[:letter].is_a? Hash
                    word_str.concat char[:letter][:value]
                else
                    word_str.concat char[:letter].letter
                end
            end

            # Check if it's valid
            if !@words.word?(word_str)
                invalid_words << word_str
            end
        end

        if invalid_words.length > 0
            # Not a valid turn, return to the client
            p "INVALID! #{invalid_words} are not valid words."
            return Error.create("invalidWords", invalid_words)
        else
            # Update the tiles and calculate the points
            points = 0
            new_words.each do |word|
                points += calculate_points(word)
                p "Points: #{points}"
            end

            lut = []
            letters.each do |letter|
                @board.update_tile(letter[:row], letter[:column], letter[:letter])

                lut << {
                    row: letter[:row],
                    column: letter[:column]
                }
            end
            @latest_updated_tiles = lut

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

    # Method for finding new words created by the placed letters.
    # Arguments:
    # tiles - Array of the placed tiles.
    # Returns Array of found words. The words are an array of tiles.
    def find_words(tiles)
        # Make a deep copy to avoid changing stuff which shouldn't be changed.
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
        tiles_dup.each do |tile|
            r = tile[:row]
            c = tile[:column]
            board_copy[r][c].letter = tile[:letter]
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

    # Method for finding words placed in a row.
    # Arguments:
    # tile - Hash of the tile to check the row of.
    # board_copy - The copy of the board with the new letters placed on it.
    # Returns the word found or nil if no word was found.
    def check_row(tile, board_copy)
        row = tile[:row]
        col = tile[:column]
        word = [{
            row: row,
            col: col,
            letter: tile[:letter]
        }]
        
        # Check to the left
        k = 1
        while board_copy[row][col - k].letter != nil
            if col - k < 0
                break
            end
            t = {
                row: row,
                col: col - k,
                letter: board_copy[row][col - k].letter
            }
            word.unshift(t)
            k += 1
        end

        # Check to the right
        k = 1
        begin
            while board_copy[row][col + k].letter != nil
                t = {
                    row: row,
                    col: col + k,
                    letter: board_copy[row][col + k].letter
                }
                word.push(t)
                k += 1
            end
        rescue NoMethodError
        end

        # p word
        if word.length > 1
            return word
        else
            return nil
        end
    end

    # Method for finding words placed in a column.
    # Arguments:
    # tile - Hash of the tile to check the column of.
    # board_copy - The copy of the board with the new letters placed on it.
    # Returns the word found or nil if no word was found.
    def check_column(tile, board_copy)
        row = tile[:row]
        col = tile[:column]
        word = [{
            row: row,
            col: col,
            letter: tile[:letter]
        }]
        
        # Check above
        k = 1
        while board_copy[row - k][col].letter != nil
            if row - k < 0
                break
            end

            t = {
                row: row - k,
                col: col,
                letter: board_copy[row - k][col].letter
            }
            word.unshift(t)
            k += 1
        end

        # Check below
        k = 1
        begin
            while board_copy[row + k][col].letter != nil
                    t = {
                        row: row + k,
                        col: col,
                        letter: board_copy[row + k][col].letter
                    }
                    word.push(t)
                k += 1
            end
        rescue NoMethodError
        end

        # p word
        if word.length > 1
            return word
        else
            return nil
        end
    end

    # Method for calculating the points which should be given for the word.
    # Arguments: 
    # word - The word in the form of an Array of tiles.
    # Returns Integer
    def calculate_points(word) 
        p "POINT CALC #{word}"
        points = 0
        times = 1 # Word multiplier

        word.each do |letter|
            lp = @letter_bag.get_points(letter[:letter])
            ltimes = 1 # Letter multiplier

            # Check attributes
            a = @board.tiles[letter[:row]][letter[:col]].attribute
            if a == "TW"
                times *= 3
            elsif a == "DW"
                times *= 2
            elsif a == "TL"
                ltimes *= 3
            elsif a == "DL"
                ltimes *= 2
            end
            if a
                p "ltimes: #{ltimes}"
            end
            points += lp * ltimes
        end
        p "times: #{times}"
        points *= times

        return points
    end

    # Method called when the turn has ended and it's the next player's turn.
    # Returns nil
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

    # Method for creating a Hash of the game
    # All the information about the game is added to a Hash in the 
    # set format for the json for sending to the client.
    # Arguments:
    # player_number - Integer, the player number of the one requesting it. Only that player's rack will be added to the Hash.
    # all - Boolean, if all the information is requested, otherwise the board will be left out to save memory.
    # Returns Hash of the game information.
    def to_hash(player_number, all=false)

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
        
        if player_number < @players.length
            rack = @players[player_number].rack
            rack.each_with_index do |letter, index|
                if letter.is_a? Blank
                    rack[index] = {
                        letter: "blank",
                        value: letter.letter
                    }
                end
            end
        else
            # Spectator, not in the game
            rack = []
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
            dict[:board][:tiles] = @board.to_array
        end

        return {
            game: dict,
            ended: @ended
        }
    end

end
