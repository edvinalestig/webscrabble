# Class for creating error messages
class Error

    # Creates an error message
    # Returns Hash with error type and description
    def self.create(type, data)
        # Error checking
        error_list = ["invalidWords", "lettersNotOnRack", "invalidPlacement", "tileOccupied", "noWordsFound"]
        if error_list.include? type
            if type == "invalidWords" || type == "tileOccupied"
                if !data.is_a? Array
                    return nil
                end
            end
        else
            return nil
        end
        
        return {
            error: {
                type => data
            }
        }
    end
end