require 'find'
require 'zip'
require 'fileutils'

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
  list = []
  entries {|path, name|
    list << "/vsizip/#{path}/#{name}"
  }
  cmd = "parallel 'ogr2ogr -f GeoJSONSeq /vsistdout/ {}' ::: #{list.join(' ')}"
  sh cmd
end

def produce
  w1 = File.open('w1.txt', 'w')
  w2 = File.open('w2.txt', 'w')
  entries {|path, name|
    w1 << "/vsizip/#{path}/#{name}\n"
    w2 << "#{name.split('-')[3]}\n"
  }
  w1.close
  w2.close
  cmd = "parallel --line-buffer 'ogr2ogr -lco RS=YES -f GeoJSONSeq /vsistdout/ {1} | FGD_LAYER={2} node filter.js' :::: w1.txt ::::+ w2.txt"
  cmd += " | tippecanoe --no-progress-indicator --no-feature-limit --no-tile-size-limit --simplification=2 --hilbert --minimum-zoom=#{MINZOOM} --maximum-zoom=#{MAXZOOM} --force -o tiles.mbtiles"
  sh cmd
  sh "tile-join --force --no-tile-compression --output-to-directory=docs/zxy --no-tile-size-limit tiles.mbtiles"
  FileUtils.rm('w1.txt')
  FileUtils.rm('w2.txt')
end

def produce_no_parallel
  cmd = []
  entries {|path, name|
    cmd << "ogr2ogr -lco RS=YES -f GeoJSONSeq /vsistdout/ /vsizip/#{path}/#{name} | FGD_LAYER=#{name.split('-')[3]} node filter.js"
  }
  cmd = "(#{cmd.join('; ')}) | tippecanoe --no-progress-indicator --no-feature-limit --no-tile-size-limit --simplification=2 --hilbert --minimum-zoom=#{MINZOOM} --maximum-zoom=#{MAXZOOM} --force -o tiles.mbtiles"
  sh cmd
  sh "tile-join --force --no-tile-compression --output-to-directory=docs/zxy --no-tile-size-limit tiles.mbtiles"
end

