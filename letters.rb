# Class handling the letters in the game

class Letters
    def initialize()
        # Fill the letter bag with all the 100 letters
        @letter_bag = add_letters_to_bag()
        
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
    end


    def add_letters_to_bag()
        # I know it's awful, please fix it
        # Loops 12 times and adds the correct number of all letters to the bag

        bag = ["Z", "X", "J", "K", "Q"] # Letters which only appear once
        
        i = 0
        while i < 12
            if i < 2 # Letters which appear twice
                bag << "V"
                bag << "W"
                bag << "B"
                bag << "C"
                bag << "F"
                bag << "H"
                bag << "M"
                bag << "Y"
                bag << "BLANK"
                bag << "P"
            end

            if i < 3
                bag << "G"
            end

            if i < 4
                bag << "D"
                bag << "L"
                bag << "S"
                bag << "U"
            end

            if i < 6
                bag << "N"
                bag << "R"
                bag << "T"
            end

            if i < 8
                bag << "O"
            end

            if i < 9
                bag << "A"
                bag << "I"
            end

            bag << "E" # Add 12 of the letter E

            i += 1
        end

        return bag
    end


    # Return <number> letters from the letter bag and remove them from the bag
    def draw(number)
        @letter_bag = @letter_bag.shuffle
        letters = @letter_bag.pop(number)
        return letters
    end

    
    # Get the points for a letter
    # Should this be moved elsewhere?
    def get_points(letter)
        return @points[letter.upcase.to_sym]
    end
   

    # Get the remaining number of letters in the bag
    def length()
        return @letter_bag.length
    end

end