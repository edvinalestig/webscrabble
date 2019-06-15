# Class for the players
class Player

    attr_accessor :points, :my_turn, :dead
    attr_reader :rack

    def initialize(rack: [], points: 0, my_turn: false, dead: false)
        @rack = rack # The player's current letters
        @points = points
        @my_turn = my_turn
        @dead = dead
    end

    # Add letters to the rack
    # Arguments:
    # letters - Array or String or Blank object, can be multiple ones.
    # Returns nil
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

    def to_hash
        return {
            rack: @rack.map { |letter| letter.is_a? Blank ? "Blank" : letter },
            points: @points,
            my_turn: @my_turn,
            dead: @dead
        }
    end
end