require_relative("game.rb")

game = Game.new(2)


d = game.dictify(0).to_json()
p d
File.write("test.json", d)