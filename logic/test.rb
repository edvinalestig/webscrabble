require_relative("game.rb")

game = Game.new(2)

game.add_new_letters([{letter: "F", row: 7, col: 7}, {letter: "O", row: 7, col: 8}, {letter: "R", row: 7, col: 9}])
game.add_new_letters([{letter: "O", row: 8, col: 7}, {letter: "F", row: 8, col: 8}])
game.add_new_letters([{letter: "T", row: 7, col: 10}, {letter: "S", row: 7, col: 11}])


d = game.dictify(0).to_json()
# p d
File.write("test.json", d)