require_relative("../logic/game.rb")
require 'json'
$game = nil
$rooms = {}

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
        # return File.read('client/index.html')
        @rooms = $rooms
        return slim :room
    end

    # Create new room
    post("/room") do
        room_name = Random.rand(100000).floor
        while $rooms.keys.include? room_name
            room_name = Random.rand(100000).floor
        end
        $rooms[room_name] = {
            game: Game.new(params[:players].to_i),
            players: []
        }
        redirect("/")
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

    get("/new3") do
        $game = Game.new(3)
        update_all()
        redirect("/play")
    end

    get("/new4") do
        $game = Game.new(4)
        update_all()
        redirect("/play")
    end

    get("/winner") do
        p $game.winner
        winner = $game.winner
        if winner
            winner = ($game.winner + 1).to_s
        else
            winner = "_"
        end

        scores = []
        $game.players.each do |pl|
            scores << pl.points
        end
        score_string = ""
        scores.each do |s|
            if score_string != ""
                score_string += " - "
            end
            score_string += s.to_s
        end

        t = {
            winner: winner,
            scores: score_string
        }
        return t.to_json
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
                        action: 'connect'
                    }
                    ws.send(hash.to_json)
                end

                # Closing the socket
                ws.onclose do |msg|
                    p "Connection terminated"
                    
                    $rooms.each do |key, value|
                        if value[:players].include? ws
                            # Remove the player from the games
                            $rooms[key][:players].slice!($rooms[key][:players].index(ws))
                        end
                    end
                    settings.sockets.delete(ws)
                    update_all()
                end

                # Message received
                ws.onmessage do |msg|
                    player = settings.sockets.index(ws) # Player number
                    message = JSON.parse(msg, symbolize_names: true)
                    spectator = player >= $game.players.length

                    if message[:action] == 'connect'
                        p "Connection established"
                        p message
                        if !$rooms.keys.include? message[:room].to_i
                            ws.send({
                                action: 'data',
                                data: {
                                    error: {
                                        Error: "Room does not exist"
                                    }
                                }
                            }.to_json)
                        end

                        # Add the player to the room
                        $rooms[message[:room].to_i][:players] << ws

                        # Send the game status to the client
                        ws.send({
                            action: 'data',
                            playerNumber: player,
                            spectator: spectator,
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
                                spectator: spectator,
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