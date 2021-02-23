const Parser = require('json-text-sequence').parser
const area = require('@mapbox/geojson-area')

const MINZOOM = 6
const MAXZOOM = 16

const commonFilter = f => {
  delete f.properties.gml_id
  delete f.properties.fid
  delete f.properties.lfSpanFr
  delete f.properties.devDate
  f.properties.orgGILvl = parseInt(f.properties.orgGILvl)
  f.tippecanoe = {
    layer: process.env.FGD_LAYER,
    minzoom: MINZOOM,
    maxzoom: MAXZOOM
  }
  if (f.properties.vis == '非表示') {
    return null
  } else {
    delete f.properties.vis
  }
  return f
}

const flap = (f, z) => {
  let mz = Math.floor(
    19 - Math.log2(area.geometry(f.geometry)) / 2
  )
  if (z) return z < mz ? z : mz
  if (mz > MAXZOOM) { mz = MAXZOOM }
  if (mz < MINZOOM) { mz = MINZOOM }
  return mz
}

const modify = {
  AdmArea: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  AdmBdry: f => {
    f.tippecanoe.minzoom = 6
    if(f.properties.orgGILvl == 25000) {
      return f
    }
  },
  AdmPt: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  BldA: f => {
    f.tippecanoe.minzoom = flap(f)
    return f
  },
  BldL: f => {
    f.tippecanoe.minzoom = flap(f)
    return f
  },
  Cntr: f => {
    if (f.properties.alti % 50 == 0) {
      f.tippecanoe.minzoom = 12
    } else {
      f.tippecanoe.minzoom = 14
    }
    return f
  },
  CommBdry: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  CommPt: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  Cstline: f => {
    f.tippecanoe.minzoom = 6
    return f
  },
  ElevPt: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  GCP: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  RailCL: f => {
    if (f.properties.type == '索道') {
      f.tippecanoe.minzoom = MAXZOOM
    } else {
      f.tippecanoe.minzoom = 12
    }
    return f
  },
  RdCompt: f => {
    f.tippecanoe.minzoom = 15
    return f
  },
  RdEdg: f => {
    if (['真幅道路', '徒歩道'].includes(f.properties.type)) {
      f.tippecanoe.minzoom = 14
    } else {
      f.tippecanoe.minzoom = 15
    }
    return f
  },
  WA: f => {
    f.tippecanoe.minzoom = 14
    //f.tippecanoe.minzoom = flap(z, 14)
    return f
  },
  WL: f => {
    if (['水涯線（河川）', '水涯線（湖池）'].includes(f.properties.type)) {
      return null
    }
    f.tippecanoe.minzoom = 14
    return f
  },
  WStrA: f => {
    f.tippecanoe.minzoom = 14
    return f
  },
  WStrL: f => {
    f.tippecanoe.minzoom = 14
    return f
  },
  SBAPt: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  },
  SBBdry: f => {
    f.tippecanoe.minzoom = MAXZOOM
    return f
  }
}[process.env.FGD_LAYER]

if (modify) {
  const startTime = Date.now()
  console.error(`Procesing ${process.env.FGD_LAYER}.`)
  const parser = new Parser()
    .on('data', f => {
      f = commonFilter(f)
      if (!f) return
      f = modify(f)
      if (f) {
        process.stdout.write(`\x1e${JSON.stringify(f)}\n`)
      }
    })
    .on('finish', () => {
      console.error(`  Took ${Date.now() - startTime}ms.`)
    })
  process.stdin.pipe(parser)
} else {
  console.error(`${process.env.FGD_LAYER} is not there.`)
}