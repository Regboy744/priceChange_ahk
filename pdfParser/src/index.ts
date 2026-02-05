import fs from 'node:fs'
import path from 'node:path'
import { parsePdf } from './parser/parsePdf'

type CliOptions = {
  input: string
  output: string
}

function resolveCliOptions(): CliOptions {
  const args = process.argv.slice(2)
  const inputArg = args[0]
  const outputArg = args[1]

  const input = inputArg
    ? path.resolve(process.cwd(), inputArg)
    : path.resolve(process.cwd(), 'pdfParser', 'pricechange.pdf')
  const output = outputArg
    ? path.resolve(process.cwd(), outputArg)
    : path.resolve(process.cwd(), 'pdfParser', 'output.json')

  return { input, output }
}

async function main() {
  const { input, output } = resolveCliOptions()

  if (!fs.existsSync(input)) {
    console.error(`Input PDF not found: ${input}`)
    process.exitCode = 1
    return
  }

  const labels = await parsePdf(input)
  const payload = {
    source: path.basename(input),
    count: labels.length,
    labels,
  }

  fs.mkdirSync(path.dirname(output), { recursive: true })
  fs.writeFileSync(output, JSON.stringify(payload, null, 2), 'utf8')
  console.log(`Parsed ${labels.length} labels -> ${output}`)
}

main().catch((error) => {
  console.error('Parsing failed:', error)
  process.exitCode = 1
})
