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
    end

    # Add a letter to a tile
    def update_tile(row, col, letter)
        @tiles[row][col].letter = letter
    end


    def json()
        dict = {
            tiles: []
        }

        @tiles.each do |row|
            arr = []
            row.each do |tile|
                arr << tile.dictionary()
            end
            dict[:tiles] << arr
        end 

        return dict

    end


    def copy()
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


class Tile

    attr_accessor :letter, :attribute
    attr_reader :row, :col
  
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



    def description
        return "Tile on position #{@row}, #{@col} with the attribute #{@attribute}. The current letter is #{@letter}"
    end


    def dictionary()
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
