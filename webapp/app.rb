require_relative("../logic/game.rb")
require 'json'
$game = nil
$socket_counter = 0 # Not a good way of doing it, can create an enormous array

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

    # Get the board for player 1
    get("/p1") do
        return File.read('client/game.html')
    end

    # Get the board for player 2
    get("/p2") do
        return File.read('client/game.html')
    end

    # Get the game information for player 1
    # Does not include the board
    get("/getp1") do
        return $game.to_hash(0).to_json
    end

    # Get the game information for player 1
    # Includes the board
    get("/getp1/all") do
        return $game.to_hash(0, true).to_json
    end

    # Get the game information for player 2
    # Does not include the board
    get("/getp2") do
        return $game.to_hash(1).to_json
    end

    # Get the game information for player 2
    # Includes the board
    get("/getp2/all") do
        return $game.to_hash(1, true).to_json
    end

    # Get a test json file
    get("/logic/test.json") do
        headers "Content-Type" => "text/html; charset=utf8"
        return File.read('logic/test.json')
    end

    # Create a new game for 2 players
    get("/newgame") do
        $game = Game.new(2)
        redirect("/p1")
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
                    # Return a hash with an id and the action performed
                    hash = {
                        action: 'connect',
                        id: $socket_counter
                    }
                    ws.send(hash.to_json)
                    # Keep track of the socket
                    settings.sockets[$socket_counter] = ws
                    # This can create an enormous array.
                    # Should be done differently.
                    # This does prevent multiple connections having the same id though.
                    $socket_counter += 1
                end

                # Closing the socket
                ws.onclose do |msg|
                    # settings.sockets.delete(ws)
                    settings.sockets[settings.sockets.index(ws)] = nil
                end

                # Message received
                we.onmessage do |msg|
                    message = JSON.parse(msg, symbolize_names: true)

                    if message[:action] == 'connect'
                        p "Connection established"
                    elsif message[:action] == 'data'
                        # Give the data to the game logic
                        game_check = $game.response(message[:data])
                        # If true is returned then the turn was successful
                        # Then send the new game state
                        # Otherwise send the error message given
                        if game_check == true
                            # The update should be sent to everyone...
                            data = $game.to_hash(message[:data][:player], true) # Send everything for now, change to false when implemented
                        else
                            data = game_check
                        end

                        response = {
                            action: "response",
                            data: data
                        }
                        settings.sockets[message[:id]].send(response.to_json)
                    end
                end
            end
        end
    end

    # Player 1 has ended their turn and should be checked against the game logic
    post("/p1") do
        p params
        $game.response(params)
        redirect("/p1")
    end

    # Player 2 has ended their turn and should be checked against the game logic
    post("/p2") do
        p params
        $game.response(params)
        redirect("/p2")
    end

    # Routes for testing laying letters
    post("/testpost") do
        request.body.rewind
        p JSON.parse(request.body.read, symbolize_names: true)
        request.body.rewind
        p $game.response(JSON.parse(request.body.read, symbolize_names: true))
        redirect("/p1")
    end

    # Send a js file which automatically sends a post request for adding the tiles found in testjson.json
    get("/testpost") do
        return "<script>#{File.read('webapp/post.js')}; sendpost('/testpost', #{File.read('webapp/testjson.json')});</script>"
    end
end
