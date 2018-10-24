require_relative("player.rb")

pl = Player.new

p pl.rack

pl.add_to_rack(["l", "h"], "j", "7")

p pl.rack