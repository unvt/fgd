require 'find'
require 'zip'
require 'fileutils'

def entries
  Find.find(SRC_DIR) {|path|
    next unless /zip$/.match path
    Zip::File.open(path) {|zip_file|
      zip_file.each {|entry|
        next unless /^FG-GML/.match entry.name
#next unless /(Cstline|AdmArea|AdmPt|AdmBdry)/.match entry.name
next unless /(Cstline|AdmPt|AdmBdry)/.match entry.name
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
  w3 = File.open('w3.txt', 'w')
  entries {|path, name|
    w1 << "/vsizip/#{path}/#{name}\n"
    w2 << "#{name.split('-')[3]}\n"
    w3 << "#{MBTILES_DIR}/#{name.sub(/xml$/, 'mbtiles')}\n"
  }
  w1.close
  w2.close
  w3.close
  #cmd = [
  #  "parallel",
  #  "'",
  #    "ogr2ogr -lco RS=YES -f GeoJSONSeq /vsistdout/ {1} |",
  #    "FGD_LAYER={2} node filter.js |",
  #    "tippecanoe",
  #      "--no-progress-indicator",
  #      "--no-feature-limit",
  #      "--no-tile-size-limit",
  #      "--simplification=2",
  #      "--hilbert",
  #      "--minimum-zoom=#{MINZOOM}",
  #      "--maximum-zoom=#{MAXZOOM}",
  #      "--force",
  #      "--layer=default",
  #      "--quiet",
  #      "-o {3};",
  #    "true",
  #  "'",
  #  ":::: w1.txt ::::+ w2.txt ::::+ w3.txt"
  #].join(' ')
  cmd = [
    "parallel --line-buffer",
    "'",
      "ogr2ogr -lco RS=YES -f GeoJSONSeq /vsistdout/ {1} |",
      "FGD_LAYER={2} node filter.js;",
    "'",
    ":::: w1.txt ::::+ w2.txt |"
  ].join(' ') + 
  [
    "tippecanoe",
      "--no-progress-indicator",
      "--no-feature-limit",
      "--no-tile-size-limit",
      "--simplification=2",
      "--hilbert",
      "--minimum-zoom=#{MINZOOM}",
      "--maximum-zoom=#{MAXZOOM}",
      "--force",
      "--layer=default",
      "--quiet",
      "--output=#{MBTILES_PATH}"
  ].join(' ')

  sh cmd

  #LAYERS.each {|layer|
  #  g = Dir.glob("#{MBTILES_DIR}/*#{layer}*.mbtiles").join(' ')
  #  sh "tile-join --force -o #{MBTILES_DIR}/00#{layer}.mbtiles #{g}" 
  #}
  #g = LAYERS.map{|layer| "#{MBTILES_DIR}/00#{layer}.mbtiles"}.join(' ')
  #sh "tile-join --force -o #{MBTILES_PATH} #{g}"
  sh "tile-join --force --no-tile-compression --output-to-directory=docs/zxy --no-tile-size-limit #{MBTILES_PATH}"
 
  #g = Dir.glob("#{MBTILES_DIR}/FG*.mbtiles").join(' ')
  #sh "tile-join --force --no-tile-compression --output-to-directory=docs/zxy --no-tile-size-limit #{g}"
  
  FileUtils.rm('w1.txt')
  FileUtils.rm('w2.txt')
  FileUtils.rm('w3.txt')
end

def produce_no_parallel
  cmd = []
  entries {|path, name|
    cmd << "ogr2ogr -lco RS=YES -f GeoJSONSeq /vsistdout/ /vsizip/#{path}/#{name} | FGD_LAYER=#{name.split('-')[3]} node filter.js"
  }
  cmd = "(#{cmd.join('; ')}) | tippecanoe --no-progress-indicator --no-feature-limit --no-tile-size-limit --simplification=2 --hilbert --minimum-zoom=#{MINZOOM} --maximum-zoom=#{MAXZOOM} --force -o #{MBTILES_PATH}"
  sh cmd
  sh "tile-join --force --no-tile-compression --output-to-directory=docs/zxy --no-tile-size-limit #{MBTILES_PATH}"
end

