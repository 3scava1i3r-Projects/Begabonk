import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import Header from '@/components/Header'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'mina.live - Live Commerce Platform',
  description: 'Buy and sell products during live streams with crypto',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" data-theme="coffee">
      <body className={inter.className}>
        <Header />
        <main className="min-h-screen bg-base-200">
          {children}
        </main>
      </body>
    </html>
  )
}