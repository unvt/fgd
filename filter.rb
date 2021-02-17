require 'json'

MINZOOM = 6
MAXZOOM = 16

FILTERS = {
  'AdmArea' => -> (f) {
    f['properties']['vis'] = f['properties']['vis'] == "表示" ? true : false
    f
  },
  'AdmBdry' => -> (f) {
    f['properties']['vis'] = f['properties']['vis'] == "表示" ? true : false
    f
  },
  'AdmPt' => -> (f) {
    f['properties']['vis'] = f['properties']['vis'] == "表示" ? true : false
    f
  },
  'BldA' => -> (f) {
    f
  },
  'BldL' => -> (f) {
    f
  },
  'Cntr' => -> (f) {
    f
  },
  'CommBdry' => -> (f) {
    f
  },
  'CommPt' => -> (f) {
    f
  },
  'ElevPt' => -> (f) {
    f
  },
  'GCP' => -> (f) {
    f
  },
  'RailCL' => -> (f) {
    f
  },
  'RdCompt' => -> (f) {
    f
  },
  'RdEdg' => -> (f) {
    f
  },
  'WA' => -> (f) {
    f
  },
  'WL' => -> (f) {
    f
  },
  'WStrA' => -> (f) {
    f
  },
  'WStrL' => -> (f) {
    f
  },
  'SBAPt' => -> (f) {
    f
  },
  'SBBdry' => -> (f) {
    f
  }
}

def common_filter(f)
  f['properties'].delete('gml_id')
  f['properties'].delete('fid')
  f['properties'].delete('lfSpanFr')
  f['properties'].delete('devDate')
  f['properties']['orgGILvl'] = f['properties']['orgGILvl'].to_i
  f['tippecanoe'] = {
    layer: ENV['FGD_LAYER'],
    minzoom: MINZOOM,
    maxzoom: MAXZOOM
  }
  f
end

if $0 == __FILE__
  while gets
    f = common_filter(JSON.parse($_))
    f = FILTERS[ENV['FGD_LAYER']].call(f)
    print "\x1e#{JSON.dump(f)}\n"
  end
end

