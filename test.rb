require_relative './ugougo.rb'

MOVE_FILE = './input.mp4'

ugougo = Ugougo.new(MOVE_FILE)
p ugougo.convert
