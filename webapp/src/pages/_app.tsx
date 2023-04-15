import { ConnectKitProvider } from 'connectkit'
import type { AppProps } from 'next/app'
import NextHead from 'next/head'
import * as React from 'react'
import { WagmiConfig } from 'wagmi'
import "../styles/globals.css"

import { client } from '../wagmi'

function App({ Component, pageProps }: AppProps) {
  const [mounted, setMounted] = React.useState(false)
  React.useEffect(() => setMounted(true), [])
  return (
    <WagmiConfig client={client}>
      <ConnectKitProvider>
        <NextHead>
          <title>Tanuki</title>
        </NextHead>

        {mounted && <Component {...pageProps} />}
      </ConnectKitProvider>
    </WagmiConfig>
  )
}

export default App
