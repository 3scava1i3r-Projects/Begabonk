import HeroSection from '@/components/HeroSection';
import CustomerLogos from '@/components/CustomerLogos';
import SearchSection from '@/components/SearchSection';
import LiveChannels from '@/components/LiveChannels';
import TrendingProducts from '@/components/TrendingProducts';
import HowItWorks from '@/components/HowItWorks';

export default function Home() {
  return (
    <>
      <HeroSection
        badge={{ text: '✨ Introducing Live Commerce', href: '#new' }}
        title="Discover, Watch, Buy with"
        highlightText="mine.live"
        subtitle="Your favorite creators, now with instant crypto commerce. Discover, watch, and buy in real-time."
        primaryCta={{ text: 'Claim Your Channel', href: '/register' }}
        secondaryCta={{ text: 'Explore Channels', href: '/explore' }}
        screenshotUrl="https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1920&q=80"
      />

      <CustomerLogos />

      <div className="container mx-auto px-4 py-8">
        <SearchSection />

        <LiveChannels />

        <TrendingProducts />

        <HowItWorks />
      </div>
    </>
  );
}