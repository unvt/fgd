require './stream.rb'

SRC_DIR = "#{Dir.home}/Downloads/PackDLMap"

task :stream do
  stream
end

task :produce do
  produce
end

task :optimize do 
  sh "node ../vt-optimizer/index.js -m tiles.mbtiles"
end

