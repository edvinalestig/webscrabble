require("sinatra")
require("json")
require_relative("../logic/game.rb")
game = nil

get("/") do
    game = Game.new(2)
    return "<h1>Creating new game!</h1><p><a href='/p1'>Player 1</a><br><a href='/p2'>Player 2</a></p>"
end


get("/p1") do
    return "<h1>You are now player 1</h1><p><a href='/getp1'>Get data</a></p>"
end


get("/p2") do
    return "<h1>You are now player 2</h1><p><a href='/getp2'>Get data</a></p>"
end


get("/getp1") do
    return game.dictify(0).to_json
end


get("/getp2") do
    return game.dictify(1).to_json
end