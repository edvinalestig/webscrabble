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
        # Loops 12 times and adds the correct number of all letters to the bag

        bag = ["Z", "X", "J", "K", "Q"] # Letters which only appear once
        
        2.times do 
            bag << "V"
            bag << "W"
            bag << "B"
            bag << "C"
            bag << "F"
            bag << "H"
            bag << "M"
            bag << "Y"
            bag << Blank.new
            bag << "P"
        end

        3.times do bag << "G" end

        4.times do
            bag << "D"
            bag << "L"
            bag << "S"
            bag << "U"
        end

        6.times do
            bag << "N"
            bag << "R"
            bag << "T"
        end
        
        8.times do bag << "O" end        

        9.times do
            bag << "A"
            bag << "I"
        end

        12.times do bag << "E" end

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


class Blank 

    attr_accessor :letter

    def initialize
        @letter = nil
    end
end