require_relative("../logic/game.rb")
require 'json'
$game = nil

# The web application
# The core of the game
class App < Sinatra::Base

    set :public_folder, './client'
    set :server, 'thin'
    set :sockets, []

    # Create a new game if no game is in progress
    before() do
        if $game == nil
            $game = Game.new(2)
        end
    end

    # Get the start page
    get("/") do
        return File.read('client/index.html')
    end

    # The route for the game
    get('/play') do
        return File.read('client/game.html')
    end

    # Create a new game for 2 players
    get("/newgame") do
        $game = Game.new(2)
        update_all()
        redirect("/play")
    end

    get("/winner") do
        p $game.winner
        return ($game.winner + 1).to_s
    end

    get("/end_page") do
        p "########## WINNER ###########"
        p $game.winner
        return File.read('client/end_page.html')
    end

    # -- Websocket stuff --
    get("/ws") do
        if !request.websocket?
            redirect '/'
        else
            request.websocket do |ws|
                # Opening the socket
                ws.onopen do |msg|
                    settings.sockets << ws
                    # Return a connection hash telling the client it has successfully connected
                    hash = {
                        action: 'connect',
                        playerNumber: settings.sockets.index(ws)
                    }
                    ws.send(hash.to_json)
                end

                # Closing the socket
                ws.onclose do |msg|
                    p "Connection terminated"
                    settings.sockets.delete(ws)
                    update_all()
                end

                # Message received
                ws.onmessage do |msg|
                    player = settings.sockets.index(ws) # Player number
                    message = JSON.parse(msg, symbolize_names: true)
                    p "Message received from #{player}:"
                    p message

                    if message[:action] == 'connect'
                        p "Connection established"
                        # Send the game status to the client
                        ws.send({
                            action: 'data',
                            playerNumber: player,
                            data: $game.to_hash(player, true) # Sending everything
                        }.to_json)

                    elsif message[:action] == 'data'
                        # Give the data to the game logic
                        game_check = $game.response(message[:data], player)
                        # If true is returned then the turn was successful
                        # Then send the new game state to all players
                        # Otherwise send the error message given
                        if game_check == true
                            update_all()
                        else
                            ws.send({
                                action: "data",
                                playerNumber: player,
                                data: game_check
                            }.to_json)
                        end
                    end
                end
            end
        end
    end

    # Update all the players currently connected including spectators
    def update_all()
        p "Updating all players"
        settings.sockets.each_with_index do |ws, player|
            ws.send({
                action: "data",
                playerNumber: player,
                data: $game.to_hash(player, true) # Change to not send everything once implemented
            }.to_json)
        end
    end
end