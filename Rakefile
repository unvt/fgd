require 'json'
require './stream.rb'

MINZOOM = 6
MAXZOOM = 16

SRC_DIR = "#{Dir.home}/Downloads/PackDLMap"
LAN_URL = 'http://localhost:9966'
GITHUB_URL = 'https://optgeo.github.io/durana-dev'

desc 'Dump GeoJSON Text Sequence'
task :stream do
  stream
end

desc 'Produce Vector Tiles'
task :produce do
  produce
end

desc 'Run vt-optimizer'
task :optimize do 
  sh "node ../vt-optimizer/index.js -m tiles.mbtiles"
end

def style(site_root)
  if site_root
    sh "SITE_ROOT=#{site_root} parse-hocon hocon/style.conf > docs/style.json"
  else
    sh "parse-hocon hocon/style.conf > docs/style.json"
  end
  center = JSON.parse(File.read('docs/zxy/metadata.json'))['center'].split(',')
  .map{|v| v.to_f }.slice(0, 2)
  style = JSON.parse(File.read('docs/style.json'))
  style['center'] = center
  File.write('docs/style.json', JSON.pretty_generate(style))
  sh "gl-style-validate docs/style.json"
end

desc 'create style'
task :style do
  style(nil)
end

desc 'create style for GitHub pages'
task :pages do
  style(GITHUB_URL)
end

desc 'create style for LAN'
task :lan do
  style(LAN_URL) 
end

desc 'host the site'
task :host do
  sh "budo -d docs --cors"
end
