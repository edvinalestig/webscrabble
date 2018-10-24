class Player

    attr_accessor :points, :my_turn
    attr_reader :rack

    def initialize()
        @rack = [] # The player's current letters
        @points = 0
        @my_turn = false
    end

  
    def add_to_rack(*letters)
        # Ability to put in both arrays and single characters
        # Number of inputs is not defined, the user can choose
        letters.each do |letter|
            if letter.is_a? Array
                letter.each do |lett|
                    @rack << lett
                end
            else
                @rack << letter
            end
        end
    end
end