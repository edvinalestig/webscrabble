class Response
    def initialize(success: false, message: nil, error: false, error_type: nil, game_ended: false, winner: nil)
        @success = success
        @message = message
        @error = error
        @error_type = error_type
        @game_ended = game_ended
        @winner = winner
    end

    def to_hash
        if @game_ended
            return {
                winner: @winner,
                ended: true
            }
        elsif @error
            return {
                error: {
                    @error_type => @message
                }
            }
        else
            return "true"
        end
    end

    def ok?
        return @success && !@game_ended
    end
end