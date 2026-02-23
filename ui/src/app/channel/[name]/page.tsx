'use client';

import { useParams } from 'next/navigation';
import Link from 'next/link';

const mockChannelData = {
  name: 'cryptoking.midl',
  owner: '0x1234...5678',
  isLive: true,
  viewers: 234,
  description: 'Crypto enthusiast sharing the latest in blockchain, NFTs, and DeFi. Daily streams at 8PM UTC!',
  avatar: '👑',
  rating: 4.8,
  reviewCount: 156,
  products: [
    { id: 1, name: 'Limited Edition NFT Art', price: '0.05 ETH', stock: 10, image: '🎨', description: 'Exclusive digital artwork with full commercial rights' },
    { id: 2, name: 'Crypto Course Access', price: '0.1 ETH', stock: 50, image: '📚', description: 'Lifetime access to premium crypto trading course' },
    { id: 3, name: '1-on-1 Consultation', price: '0.5 ETH', stock: 5, image: '💬', description: 'Private 1-hour strategy session' },
  ],
  reviews: [
    { id: 1, user: '0xabcd...1234', rating: 5, comment: 'Great product, fast delivery!', date: '2 days ago' },
    { id: 2, user: '0xefgh...5678', rating: 4, comment: 'Good quality, recommend', date: '1 week ago' },
  ]
};

export default function ChannelPage() {
  const params = useParams();
  const channelName = params.name as string;
  const channel = { ...mockChannelData, name: channelName };

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Channel Header */}
      <div className="bg-base-100 rounded-box shadow-lg p-6 mb-6">
        <div className="flex flex-col md:flex-row gap-6">
          {/* Avatar */}
          <div className="w-24 h-24 rounded-full bg-primary/20 flex items-center justify-center text-5xl">
            {channel.avatar}
          </div>
          
          {/* Info */}
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              <h1 className="text-3xl font-bold">{channel.name}</h1>
              {channel.isLive && (
                <span className="badge badge-error animate-pulse">LIVE</span>
              )}
            </div>
            <p className="text-base-content/60 mb-4">{channel.description}</p>
            <div className="flex flex-wrap gap-4 text-sm">
              <span className="flex items-center gap-1">
                <span className="text-primary">●</span> {channel.viewers} viewers
              </span>
              <span>⭐ {channel.rating} ({channel.reviewCount} reviews)</span>
              <span>📦 {channel.products.length} products</span>
            </div>
          </div>
          
          {/* Actions */}
          <div className="flex flex-col gap-2">
            {channel.isLive ? (
              <button className="btn btn-primary">Join Stream</button>
            ) : (
              <button className="btn btn-outline" disabled>Offline</button>
            )}
            <button className="btn btn-outline">Follow</button>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content - Stream & Products */}
        <div className="lg:col-span-2 space-y-6">
          {/* Video Player Placeholder */}
          <div className="bg-base-100 rounded-box shadow-lg overflow-hidden">
            <div className="aspect-video bg-black flex items-center justify-center">
              {channel.isLive ? (
                <div className="text-center">
                  <div className="text-6xl mb-4">📺</div>
                  <p className="text-white text-lg">Live Stream Active</p>
                  <p className="text-white/60">{channel.viewers} watching now</p>
                </div>
              ) : (
                <div className="text-center">
                  <div className="text-6xl mb-4">⏰</div>
                  <p className="text-white text-lg">Stream Offline</p>
                  <p className="text-white/60">Check back later</p>
                </div>
              )}
            </div>
          </div>

          {/* Products Section */}
          <div className="bg-base-100 rounded-box shadow-lg p-6">
            <h2 className="text-xl font-bold mb-4">Available Products</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {channel.products.map((product) => (
                <div key={product.id} className="border border-base-200 rounded-box p-4 hover:border-primary transition-colors">
                  <div className="flex gap-4">
                    <div className="w-20 h-20 bg-base-200 rounded flex items-center justify-center text-3xl">
                      {product.image}
                    </div>
                    <div className="flex-1">
                      <h3 className="font-bold">{product.name}</h3>
                      <p className="text-sm text-base-content/60 line-clamp-2">{product.description}</p>
                      <div className="flex justify-between items-center mt-2">
                        <span className="text-primary font-bold">{product.price}</span>
                        <span className="text-xs text-base-content/50">{product.stock} left</span>
                      </div>
                    </div>
                  </div>
                  <Link href={`/product/${product.id}`}>
                    <button className="btn btn-primary btn-sm w-full mt-3">
                      Buy Now
                    </button>
                  </Link>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Sidebar - Chat & Reviews */}
        <div className="space-y-6">
          {/* Chat Placeholder */}
          <div className="bg-base-100 rounded-box shadow-lg p-4">
            <h3 className="font-bold mb-3">Live Chat</h3>
            <div className="h-64 bg-base-200 rounded-box p-2 overflow-y-auto mb-3">
              <div className="text-sm space-y-2">
                <p><span className="font-bold text-primary">User1:</span> This looks amazing!</p>
                <p><span className="font-bold text-secondary">User2:</span> What's the price?</p>
                <p><span className="font-bold text-accent">User3:</span> Just bought one! 🔥</p>
              </div>
            </div>
            <input 
              type="text" 
              placeholder="Send a message..." 
              className="input input-bordered w-full text-sm" 
            />
          </div>

          {/* Reviews */}
          <div className="bg-base-100 rounded-box shadow-lg p-4">
            <div className="flex justify-between items-center mb-3">
              <h3 className="font-bold">Reviews</h3>
              <span className="text-sm text-primary">⭐ {channel.rating}</span>
            </div>
            <div className="space-y-3">
              {channel.reviews.map((review) => (
                <div key={review.id} className="border-b border-base-200 pb-3 last:border-0">
                  <div className="flex justify-between items-center">
                    <span className="text-sm font-bold">{review.user}</span>
                    <span className="text-xs text-base-content/50">{review.date}</span>
                  </div>
                  <div className="rating rating-sm mt-1">
                    {[1,2,3,4,5].map((star) => (
                      <input 
                        key={star} 
                        type="radio" 
                        className="mask mask-star-2 bg-warning" 
                        checked={star <= review.rating}
                        readOnly 
                      />
                    ))}
                  </div>
                  <p className="text-sm mt-1">{review.comment}</p>
                </div>
              ))}
            </div>
            <Link href={`/channel/${channel.name}/reviews`}>
              <button className="btn btn-ghost btn-sm w-full mt-3">View All Reviews</button>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
