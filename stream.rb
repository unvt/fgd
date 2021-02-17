require 'find'
require 'zip'

def read(path, name)
  cmd = "ogr2ogr -f GeoJSONSeq /vsistdout/ /vsizip/#{path}/#{name}"
  sh cmd
end

def stream
  Find.find(SRC_DIR) {|path|
    next unless /zip$/.match path
    Zip::File.open(path) {|zip_file|
      zip_file.each {|entry|
        next unless /^FG-GML/.match entry.name
        read(path, entry.name)
      }
    }
  }
end

