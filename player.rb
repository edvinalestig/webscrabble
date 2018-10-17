class Player
    def initialize()
        @rack = []
        @points = 0
    end

    def points
        return @points
    end

    def points=(points)
        @points = points
    end

    def rack
        return @rack
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