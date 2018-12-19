require_relative("game.rb")

b = false
i = 0

# Loops until at least one addition is valid.
while !b
    puts "\n\n--- NEW GAME ---"
    puts "Game number #{i}"
    $game = Game.new(2)
    arr = []
    puts "Rack: #{$game.players[$game.current_turn].rack}"

    # arr << $game.add_new_letters([{letter: "F", row: 7, col: 7}, {letter: "O", row: 7, col: 8}, {letter: "R", row: 7, col: 9}])
    # arr << $game.add_new_letters([{letter: "O", row: 0, col: 0}, {letter: "F", row: 0, col: 1}])
    # arr << $game.add_new_letters([{letter: "T", row: 7, col: 10}, {letter: "S", row: 8, col: 10}])
    # arr << $game.add_new_letters([{letter: "F", row: 8, col: 10}, {letter: "Q", row: 8, col: 11}, {letter: "T", row: 8, col: 12}])
    # arr << $game.add_new_letters([{letter: {letter: "blank", value: "O"}, row: 9, col: 10}, {letter: "K", row: 9, col: 11}])
    # arr << $game.add_new_letters([{letter: "E", row: 4, col: 4}])
    # arr << $game.add_new_letters([{letter: "E", row: 4, col: 5}])
    arr << $game.add_new_letters([{letter: {letter: "blank", value: "M"}, row: 7, col: 6}, {letter: "E", row: 7, col:7}])

    # arr << $game.add_new_letters([{letter: "S", row: 7, col: 7}, {letter: "O", row: 7, col: 8}])

    if arr.include? true
        b = true
    end
    i += 1
end

d = $game.to_hash(0, true).to_json()
# p d
File.write("test.json", d)
