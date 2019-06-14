# Class handling the letters in the game
class Letters
    def initialize()
        # Fill the letter bag with all the 100 letters
        @letter_bag = add_letters_to_bag()
    end

    # Add the 100 letters to the bag
    def add_letters_to_bag()

        bag = ["Z", "X", "J", "K", "Q"] # Letters which only appear once
        
        2.times do       # Letters which appear twice
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
    # Arguments:
    # number - Integer of how many letters
    # Returns Array of strings or Blank objects
    def draw(number)
        @letter_bag = @letter_bag.shuffle
        letters = @letter_bag.pop(number)
        return letters
    end
   

    # Get the remaining number of letters in the bag
    # Returns Integer
    def length()
        return @letter_bag.length
    end

end

# Class for the blank letters
class Blank 

    attr_accessor :letter

    def initialize
        @letter = nil
    end
end