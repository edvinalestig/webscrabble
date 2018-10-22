class Words
    def initialize()
        # Reads the saved word list
        wordfile = File.readlines("wordlist.txt")

        # Goes through all the words and removes \n-characters and other whitespace
        @words = []
        wordfile.each do |line|
            # Adds the chomped word to the words array
            @words << line.chomp
        end
    end

    def is_word?(word)
        # Checks if a word is in the words array
        return @words.include? word.downcase
    end
end