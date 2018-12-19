class Error
    def self.create(type, data)
        # Does some error checking and returns a hash for the error
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
        
        return {type => data} 
    end
end