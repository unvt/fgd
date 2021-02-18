const Parser = require('json-text-sequence').parser
const area = require('@turf/area')

const modify = f => {
  return f
}

const parser = new Parser()
  .on('data', f => {
    process.stdout.write(`\x1e${JSON.stringify(modify(f))}\n`)
  })
  .on('invalid', f => {
    process.stdout.write(`\x1e${JSON.stringify(modify(f))}\n`)
  })

process.stdin.pipe(parser)
