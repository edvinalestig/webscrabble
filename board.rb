class Board
    def initialize()
        @tiles = []
        (0..14).each do |i|
            (0..14).each do |j|
                @tiles << Tile.new(i, j)
            end
        end
    end
end


class Tile
    # row & col decide position on the board
    # attribute tells if it's a special tile such as triple word och the centre tile
    # Available attributes are:
    # centre
    # 2W, 3W, 2L and 3L will be available in future versions
    # letter is the current letter placed on the tile
    def initialize(row, col) 
        @attribute = nil
        @row = row
        @col = col
        @letter = nil
    end


    def letter
        return @letter
    end


    def letter=(letter)
        @letter = letter
    end


    def attribute
        return @attribute
    end


    def attribute=(attribute)
        @attribute = attribute
    end


    def description
        return "Tile on position #{@row}, #{@col} with the attribute #{@attribute}. The current letter is #{@letter}"
    end

end

b = Board.new