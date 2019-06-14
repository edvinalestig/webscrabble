class Utility
    # All corresponding points to the letters
    @points = {
        A:1,
        B:3,
        C:3,
        D:2,
        E:1,
        F:4,
        G:2,
        H:4,
        I:1,
        J:8,
        K:5,
        L:1,
        M:3,
        N:1,
        O:1,
        P:3,
        Q:10,
        R:1,
        S:1,
        T:1,
        U:1,
        V:4,
        W:4,
        X:8,
        Y:4,
        Z:10,
        BLANK:0
    }

    # Get the points for a letter
    # Should this be moved elsewhere?
    # Arguments:
    # letter - The letter which points are requested for
    # Returns Integer of the points
    def self.get_points(letter)
        if letter.is_a?(Hash) || letter.is_a?(Blank)
            return 0
        else
            return @points[letter.upcase.to_sym]
        end
    end

    # Method for calculating the points which should be given for the word.
    # Arguments: 
    # word - The word in the form of an Array of tiles.
    # Returns Integer
    def self.calculate_points(word, board) 
        p "POINT CALC #{word}"
        points = 0
        times = 1 # Word multiplier

        word.each do |letter|
            lp = self.get_points(letter[:letter])
            ltimes = 1 # Letter multiplier

            # Check attributes
            a = board.tiles[letter[:row]][letter[:col]].attribute
            if a == "TW"
                times *= 3
            elsif a == "DW"
                times *= 2
            elsif a == "TL"
                ltimes *= 3
            elsif a == "DL"
                ltimes *= 2
            end
            points += lp * ltimes
        end
        points *= times

        return points
    end
end