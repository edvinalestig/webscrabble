# The board. The board for the game is an instance of te Board class.
class Board

    attr_reader :tiles

    def initialize()
        @tiles = []
        # Create a 15*15 board in a 2D array

        (0..14).each do |row|
            column = []

            (0..14).each do |col|
                column << Tile.new(row, col)
            end
            @tiles << column
        end

        # Define the centre tile
        @tiles[7][7].attribute = "centre"

        # Triple word
        @tiles[0][0].attribute = "TW"
        @tiles[0][7].attribute = "TW"
        @tiles[0][14].attribute = "TW"
        @tiles[7][0].attribute = "TW"
        @tiles[7][14].attribute = "TW"
        @tiles[14][0].attribute = "TW"
        @tiles[14][7].attribute = "TW"
        @tiles[14][14].attribute = "TW"

        # Double word
        @tiles[1][1].attribute = "DW"
        @tiles[2][2].attribute = "DW"
        @tiles[3][3].attribute = "DW"
        @tiles[4][4].attribute = "DW"

        @tiles[1][13].attribute = "DW"
        @tiles[2][12].attribute = "DW"
        @tiles[3][11].attribute = "DW"
        @tiles[4][10].attribute = "DW"

        @tiles[10][10].attribute = "DW"
        @tiles[11][11].attribute = "DW"
        @tiles[12][12].attribute = "DW"
        @tiles[13][13].attribute = "DW"

        @tiles[13][1].attribute = "DW"
        @tiles[12][2].attribute = "DW"
        @tiles[11][3].attribute = "DW"
        @tiles[10][4].attribute = "DW"

        # Triple letter
        @tiles[5][1].attribute = "TL"
        @tiles[9][1].attribute = "TL"
        @tiles[1][5].attribute = "TL"
        @tiles[1][9].attribute = "TL"
        @tiles[5][13].attribute = "TL"
        @tiles[9][13].attribute = "TL"
        @tiles[13][5].attribute = "TL"
        @tiles[13][9].attribute = "TL"

        @tiles[5][5].attribute = "TL"
        @tiles[5][9].attribute = "TL"
        @tiles[9][9].attribute = "TL"
        @tiles[9][5].attribute = "TL"

        # Double letter
        @tiles[3][0].attribute = "DL"
        @tiles[11][0].attribute = "DL"
        @tiles[3][14].attribute = "DL"
        @tiles[11][14].attribute = "DL"
        @tiles[0][3].attribute = "DL"
        @tiles[0][11].attribute = "DL"
        @tiles[14][3].attribute = "DL"
        @tiles[14][11].attribute = "DL"

        @tiles[6][6].attribute = "DL"
        @tiles[6][8].attribute = "DL"
        @tiles[8][6].attribute = "DL"
        @tiles[8][8].attribute = "DL"

        @tiles[7][3].attribute = "DL"
        @tiles[7][11].attribute = "DL"
        @tiles[3][7].attribute = "DL"
        @tiles[11][7].attribute = "DL"

        @tiles[6][2].attribute = "DL"
        @tiles[8][2].attribute = "DL"
        @tiles[2][6].attribute = "DL"
        @tiles[2][8].attribute = "DL"
        @tiles[6][12].attribute = "DL"
        @tiles[8][12].attribute = "DL"
        @tiles[12][6].attribute = "DL"
        @tiles[12][8].attribute = "DL"
    end

    # Add a letter to a tile
    # Arguments:
    # row - Integer, the row in which the tile should be placed in.
    # col - Integer, the column in which the tiles should be placed in.
    # letter - Hash or String, the letter which should be placed.
    # Returns nil
    def update_tile(row, col, letter)
        if letter.is_a? Hash
            l = Blank.new
            l.letter = letter[:value]
            letter = l
        end
        @tiles[row][col].letter = letter
        @tiles[row][col].attribute = nil
    end

    # Method for converting the board to an Array.
    # Returns a 2D Array of the tiles on the board.
    def to_array
        tile_array = []

        @tiles.each do |row|
            arr = []
            row.each do |tile|
                arr << tile.to_hash
            end
            tile_array << arr
        end 

        return tile_array
    end

    # Creates a deep copy of the board. 
    # Returns a 2D Array of the tiles on the board.
    def deep_clone()
        tiles = []

        (0..14).each_with_index do |row, i|
            column = []

            (0..14).each_with_index do |col, j|
                att = @tiles[i][j].attribute
                let = @tiles[i][j].letter
                column << Tile.new(row, col, att, let)
            end
            tiles << column
        end

        return tiles
    end
end

# An object for each tile.
# The board is made up of Tile instances.
class Tile

    attr_accessor :letter, :attribute
    attr_reader :row, :col
  
    # Arguments: 
    # row & col decide position on the board
    # attribute tells if it's a special tile such as triple word och the centre tile
    # Available attributes are:
    # centre
    # 2W, 3W, 2L and 3L will be available in future versions
    # letter is the current letter placed on the tile
    def initialize(row, col, attribute=nil, letter=nil) 
        @attribute = attribute
        @row = row
        @col = col
        @letter = letter
    end

    # Convert the tile into a Hash
    # Returns Hash of the tile's information
    def to_hash
        l = @letter
        if l.is_a? Blank
            l = {
                letter: "blank",
                value: @letter.letter
            }
        end

        tile = {
            attribute: @attribute,
            row: @row,
            column: @col,
            letter: l
        }
        return tile
    end

end
