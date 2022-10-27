#!/usr/bin/env -S deno run --allow-net=www.tf1.fr

async function main() {
  const resp = await fetch(
    'https://www.tf1.fr/tmc/quotidien-avec-yann-barthes/videos/replay'
  )
  const body = await resp.text()
  const data = JSON.parse(
    body.match(/<script type="application\/ld\+json">(.+)<\/script>/)![1]
  )
  const urls = data['itemListElement'].map((e: { url: string }) => e['url'])
  urls.slice(0, 10).forEach((url: string) => console.log(url))
}

await main()
