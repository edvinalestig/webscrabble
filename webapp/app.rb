require_relative("../logic/game.rb")
require 'json'
$rooms = {}

# The web application
# The core of the game
class App < Sinatra::Base

    set :public_folder, './client'
    set :server, 'thin'
    set :sockets, []


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

    # Delete finished game
    post("/delete") do
        room = params["room"].to_i
        $rooms.delete(room)
        redirect("/")
    end

    # The route for the game
    get('/play') do
        return File.read('client/game.html')
    end

    get("/winner") do
        if $rooms.keys.include? params["room"].to_i
            game = $rooms[params["room"].to_i][:game]
            winner = game.winner
            
            if winner
                winner = (game.winner + 1).to_s
            else
                winner = "_"
            end

            # Get the scores
            scores = []
            game.players.each do |pl|
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
        else
            return {
                winner: nil,
                scores: "Room does not exist"
            }.to_json
        end
    end

    get("/end_page") do
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
                            update_all(value)
                        end
                    end
                    settings.sockets.delete(ws)
                    
                end

                # Message received
                ws.onmessage do |msg|
                    # player = settings.sockets.index(ws) # Player number
                    message = JSON.parse(msg, symbolize_names: true)
                    # spectator = player >= $game.players.length

                    if message[:action] == 'connect'
                        room_id = message[:room].to_i
                        p "Connection established"
                        p message
                        if !$rooms.keys.include? room_id
                            ws.send({
                                action: 'data',
                                data: {
                                    error: {
                                        Error: "Room does not exist"
                                    }
                                }
                            }.to_json)
                        else
                            # Add the player to the room
                            $rooms[room_id][:players] << ws

                            player = $rooms[room_id][:players].index(ws)
                            spectator = player >= $rooms[room_id][:game].players.length

                            # Send the game status to the client
                            ws.send({
                                action: 'data',
                                playerNumber: player,
                                spectator: spectator,
                                data: $rooms[room_id][:game].to_hash(player, true) # Sending everything
                            }.to_json)
                        end

                    elsif message[:action] == 'data'
                        # Give the data to the game logic
                        game_check = nil
                        $rooms.each do |key, value|
                            p key
                            # Find the game which the player is connected to
                            if value[:players].include? ws
                                player = value[:players].index(ws)
                                spectator = player >= value[:game].players.length

                                game_check = value[:game].response(message[:data], player)

                                # If true is returned then the turn was successful
                                # Then send the new game state to all players
                                # Otherwise send the error message given
                                if game_check.ok?
                                    update_all(value)
                                else
                                    ws.send({
                                        action: "data",
                                        playerNumber: player,
                                        spectator: spectator,
                                        data: game_check.to_hash
                                    }.to_json)
                                end

                                break
                            end
                        end
                    end
                end
            end
        end
    end

    # Update all the players currently connected including spectators
    def update_all(room)
        p "Updating all players"
        room[:players].each_with_index do |ws, player|
            ws.send({
                action: "data",
                playerNumber: player,
                data: room[:game].to_hash(player, true) # Change to not send everything once implemented
            }.to_json)
        end
    end
end