require_relative("../logic/game.rb")
require_relative("db-comm")
require 'json'

$rooms = {} # Change to only have rooms, not the games
# The games should be run from the database

# The web application
# The core of the game
class App < Sinatra::Base

    set :public_folder, './client'
    set :server, 'thin'
    set :sockets, []


    # Get the start page
    get("/") do
        @games = Database.all_games
        @rooms = $rooms
        return slim :room
    end

    # Create new room
    post("/room") do
        room_name = Random.rand(100000).floor
        while Database.get_game room_name
            room_name = Random.rand(100000).floor
        end
        $rooms[room_name] = []
        Database.create_game(room_name, nil, Game.new(params[:players].to_i).stringify)
        redirect("/")
    end

    # Delete finished game
    post("/delete") do
        room = params["room"].to_i
        $rooms.delete(room)
        Database.delete_game room
        redirect("/")
    end

    # The route for the game
    get('/play') do
        return File.read('client/game.html')
    end

    get("/winner") do
        result = Database.get_game params["room"].to_i
        if result
        # if $rooms.keys.include? params["room"].to_i
            game = Game.parse(result["game_data"])
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

                    $rooms.each do |room, players|
                        if players.include? ws
                            # Remove the player from the games
                            $rooms[room].slice!($rooms[room].index(ws))
                            update_all(room, Database.get_game(room)["game_data"])
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
                        
                        if Database.get_game(room_id) == nil
                            ws.send({
                                action: 'data',
                                data: {
                                    error: {
                                        Error: "Room does not exist"
                                    }
                                }
                            }.to_json)
                        else
                            if !$rooms.keys.include? room_id
                                $rooms[room_id] = []
                            end

                            # Add the player to the room
                            $rooms[room_id] << ws

                            player = $rooms[room_id].index(ws)

                            game = Game.parse(Database.get_game(room_id)["game_data"])
                            spectator = player >= game.players.length

                            # Send the game status to the client
                            ws.send({
                                action: 'data',
                                playerNumber: player,
                                spectator: spectator,
                                data: game.to_hash(player, true) # Sending everything
                            }.to_json)
                        end

                    elsif message[:action] == 'data'
                        # Give the data to the game logic
                        game_check = nil
                        $rooms.each do |room, players|
                            # Find the game which the player is connected to
                            if players.include? ws
                                player = players.index(ws)

                                game = Game.parse(Database.get_game(room)["game_data"])
                                spectator = player >= game.players.length

                                game_check = game.response(message[:data], player)

                                # If true is returned then the turn was successful
                                # Then send the new game state to all players
                                # Otherwise send the error message given
                                if game_check.ok?
                                    update_all(room, game.stringify)
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
                    elsif message[:action] == 'save'
                        $rooms.each do |room, players|
                            # Find the game which the player is connected to
                            if players.include? ws
                                game = Game.parse(Database.get_game(room)["game_data"])
                                File.write("game.json", game.stringify)
                            end
                        end
                    end
                end
            end
        end
    end

    # Update all the players currently connected including spectators
    def update_all(room, data)
        game = Game.parse(Database.update_game(room, data)["game_data"])
        
        p "Updating all players"
        $rooms[room].each_with_index do |ws, player|
            ws.send({
                action: "data",
                playerNumber: player,
                data: game.to_hash(player)
            }.to_json)
        end
    end
end