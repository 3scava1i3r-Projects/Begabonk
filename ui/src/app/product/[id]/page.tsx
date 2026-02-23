'use client';

import { useParams } from 'next/navigation';
import { useState } from 'react';
import Link from 'next/link';

const mockProduct = {
  id: 1,
  name: 'Limited Edition NFT Art',
  price: '0.05 ETH',
  priceWei: '50000000000000000',
  description: 'Exclusive digital artwork with full commercial rights. This unique piece is part of a limited collection of 10.',
  image: '🎨',
  stock: 10,
  channel: 'cryptoking.midl',
  seller: '0x1234...5678',
};

export default function ProductPage() {
  const params = useParams();
  const [quantity, setQuantity] = useState(1);
  const [showCheckout, setShowCheckout] = useState(false);
  const [walletConnected, setWalletConnected] = useState(false);

  const totalPrice = mockProduct.priceWei;

  const handleConnectWallet = () => {
    setWalletConnected(true);
  };

  const handleBuy = () => {
    if (!walletConnected) {
      setShowCheckout(true);
    } else {
      // In real app, this would trigger wallet transaction
      alert('Please confirm transaction in your wallet');
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Product Image */}
        <div className="bg-base-100 rounded-box shadow-lg p-8 flex items-center justify-center">
          <div className="text-9xl">{mockProduct.image}</div>
        </div>

        {/* Product Details */}
        <div className="space-y-6">
          {/* Breadcrumb */}
          <nav className="text-sm">
            <Link href="/" className="text-primary hover:underline">Home</Link>
            <span className="mx-2">/</span>
            <Link href={`/channel/${mockProduct.channel}`} className="text-primary hover:underline">
              {mockProduct.channel}
            </Link>
            <span className="mx-2">/</span>
            <span className="text-base-content/60">{mockProduct.name}</span>
          </nav>

          {/* Title & Price */}
          <div>
            <h1 className="text-3xl font-bold mb-2">{mockProduct.name}</h1>
            <p className="text-2xl text-primary font-bold">{mockProduct.price}</p>
          </div>

          {/* Seller Info */}
          <div className="flex items-center gap-2 p-4 bg-base-200 rounded-box">
            <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center">
              👤
            </div>
            <div>
              <p className="text-sm font-bold">Seller: {mockProduct.seller}</p>
              <Link href={`/channel/${mockProduct.channel}`} className="text-sm text-primary hover:underline">
                View Channel →
              </Link>
            </div>
          </div>

          {/* Description */}
          <div>
            <h3 className="font-bold mb-2">Description</h3>
            <p className="text-base-content/70">{mockProduct.description}</p>
          </div>

          {/* Stock */}
          <div className="flex items-center gap-2">
            <span className="text-sm">Stock:</span>
            <span className="badge badge-success">{mockProduct.stock} available</span>
          </div>

          {/* Quantity */}
          <div className="flex items-center gap-4">
            <span className="text-sm font-bold">Quantity:</span>
            <div className="join">
              <button 
                className="btn join-item"
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
              >
                -
              </button>
              <input 
                type="number" 
                value={quantity}
                onChange={(e) => setQuantity(Math.max(1, parseInt(e.target.value) || 1))}
                className="input input-bordered join-item w-16 text-center" 
              />
              <button 
                className="btn join-item"
                onClick={() => setQuantity(Math.min(mockProduct.stock, quantity + 1))}
              >
                +
              </button>
            </div>
          </div>

          {/* Buy Button */}
          <button 
            onClick={handleBuy}
            className="btn btn-primary btn-lg w-full"
          >
            Buy Now - {(parseFloat(mockProduct.price) * quantity).toFixed(3)} ETH
          </button>

          {/* Trust Badges */}
          <div className="flex justify-center gap-4 text-sm text-base-content/60">
            <span className="flex items-center gap-1">🛡️ Secure Escrow</span>
            <span className="flex items-center gap-1">✓ Verified Seller</span>
            <span className="flex items-center gap-1">↩️ Buyer Protection</span>
          </div>
        </div>
      </div>

      {/* Checkout Modal */}
      {showCheckout && (
        <div className="modal modal-open">
          <div className="modal-box">
            <h3 className="font-bold text-lg">Complete Purchase</h3>
            
            {!walletConnected ? (
              <div className="py-4">
                <p className="mb-4">Connect your wallet to complete the purchase</p>
                <div className="space-y-2">
                  <button 
                    onClick={handleConnectWallet}
                    className="btn btn-outline w-full"
                  >
                    🔗 Connect MetaMask
                  </button>
                  <button className="btn btn-outline w-full">
                    🦊 Connect WalletConnect
                  </button>
                </div>
              </div>
            ) : (
              <div className="py-4 space-y-4">
                {/* Order Summary */}
                <div className="bg-base-200 p-4 rounded-box">
                  <h4 className="font-bold mb-2">Order Summary</h4>
                  <div className="flex justify-between">
                    <span>{mockProduct.name} x{quantity}</span>
                    <span className="font-bold">{mockProduct.price}</span>
                  </div>
                  <div className="divider"></div>
                  <div className="flex justify-between font-bold">
                    <span>Total</span>
                    <span className="text-primary">{(parseFloat(mockProduct.price) * quantity).toFixed(3)} ETH</span>
                  </div>
                </div>

                {/* Shipping */}
                <div>
                  <label className="label">
                    <span className="label-text font-bold">Shipping Address</span>
                  </label>
                  <textarea 
                    className="textarea textarea-bordered w-full" 
                    placeholder="Enter your shipping address"
                    rows={3}
                  ></textarea>
                </div>

                {/* Buy Button */}
                <button 
                  onClick={() => {
                    alert('Transaction submitted! Check your wallet.');
                    setShowCheckout(false);
                  }}
                  className="btn btn-primary w-full"
                >
                  Confirm & Pay
                </button>
              </div>
            )}

            <div className="modal-action">
              <button 
                onClick={() => setShowCheckout(false)}
                className="btn"
              >
                Close
              </button>
            </div>
          </div>
          <div className="modal-backdrop" onClick={() => setShowCheckout(false)}></div>
        </div>
      )}
    </div>
  );
}
