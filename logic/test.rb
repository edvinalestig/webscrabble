require_relative("game.rb")

b = false

# Loops until at least one addition is valid.
while !b
    puts "\n\n--- NEW GAME ---"
    game = Game.new(2)
    arr = []

    arr << game.add_new_letters([{letter: "F", row: 7, col: 7}, {letter: "O", row: 7, col: 8}, {letter: "R", row: 7, col: 9}])
    arr << game.add_new_letters([{letter: "O", row: 8, col: 7}, {letter: "F", row: 8, col: 8}])
    arr << game.add_new_letters([{letter: "T", row: 7, col: 10}, {letter: "S", row: 7, col: 11}])
    arr << game.add_new_letters([{letter: "F", row: 8, col: 10}, {letter: "Q", row: 8, col: 11}, {letter: "T", row: 8, col: 12}])
    arr << game.add_new_letters([{letter: {letter: "blank", value: "O"}, row: 9, col: 10}, {letter: "K", row: 9, col: 11}])
    arr << game.add_new_letters([{letter: "E", row: 4, col: 7}, {letter: "E", row: 4, col: 8}])

    if arr.include? true
        b = true
    end
end

d = game.dictify(0).to_json()
# p d
File.write("test.json", d)
