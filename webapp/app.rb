require("sinatra")
require("json")
require_relative("../logic/game.rb")
game = nil

set :public_folder, '../client'

before() do
    if game == nil
        game = Game.new(2)
    end
end

get("/") do
    # game = Game.new(2)
    return "<h1>Creating new game!</h1><p><a href='/p1'>Player 1</a><br><a href='/p2'>Player 2</a></p>"
end


get("/p1") do
    # return "<h1>You are now player 1</h1><p><a href='/getp1'>Get data</a></p><script>#{File.read('post.js')}</script>"
    return File.read('../client/game.html')
end


get("/p2") do
    return "<h1>You are now player 2</h1><p><a href='/getp2'>Get data</a></p><script>#{File.read('post.js')}</script>"
end


get("/getp1") do
    j = game.to_hash(0).to_json
    p j
    return j
end


get("/getp2") do
    return game.to_hash(1).to_json
end


post("/p1") do
    p params
    game.response(params)
    redirect("/p1")
end


post("/p2") do
    p params
    game.response(params)
    redirect("/p2")
end


post("/testpost") do
    request.body.rewind
    p JSON.parse(request.body.read, symbolize_names: true)
    request.body.rewind
    game.response(JSON.parse(request.body.read, symbolize_names: true))
    redirect("/p1")
end


get("/testpost") do
    return "<script>#{File.read('post.js')}; sendpost('/testpost', #{File.read('testjson.json')});</script>"
end