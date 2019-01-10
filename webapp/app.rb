require_relative("../logic/game.rb")
require 'json'
$game = nil

# The web application
# The core of the game
class App < Sinatra::Base


    set :public_folder, 'client'

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
      return $game.winner
    end

    get("/end_page") do
        p "########## WINNER ###########"
        p $game.winner
        return File.read('client/end_page.html')
    end

    post("/winner/:id") do
        $game.winner = params["id"]
        redirect("/end_page")
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
