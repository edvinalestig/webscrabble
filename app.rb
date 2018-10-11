require("sinatra")

get("/") do
    return "<h1>Hello world!</h1>"
end


get("/p1") do
    return "<h1>You are now player 1</h1>"
end


get("/p2") do
    return "<h1>You are now player 2</h1>"
end