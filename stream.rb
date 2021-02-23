require 'find'
require 'zip'
require './filter.rb'

def entries
  Find.find(SRC_DIR) {|path|
    next unless /zip$/.match path
    Zip::File.open(path) {|zip_file|
      zip_file.each {|entry|
        next unless /^FG-GML/.match entry.name
        yield path, entry.name
      }
    }
  }
end

def stream
  entries {|path, name|
    cmd = "ogr2ogr -f GeoJSONSeq /vsistdout/ /vsizip/#{path}/#{name}"
    sh cmd
  }
end

def produce
  cmd = []
  entries {|path, name|
    cmd << "ogr2ogr -lco RS=YES -f GeoJSONSeq /vsistdout/ /vsizip/#{path}/#{name} | FGD_LAYER=#{name.split('-')[3]} node filter.js"
  }
  cmd = "(#{cmd.join('; ')}) | tippecanoe --no-progress-indicator --no-feature-limit --no-tile-size-limit --simplification=2 --hilbert --minimum-zoom=#{MINZOOM} --maximum-zoom=#{MAXZOOM} --force -o tiles.mbtiles"
  sh cmd
  sh "tile-join --force --no-tile-compression --output-to-directory=docs/zxy --no-tile-size-limit tiles.mbtiles"
end
