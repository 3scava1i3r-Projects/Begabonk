'use client';

import { useState } from 'react';
import Link from 'next/link';

// Mock data
const mockStats = {
  totalSales: '2.5 ETH',
  totalOrders: 45,
  totalProducts: 8,
  averageRating: 4.8,
};

const mockOrders = [
  { id: 1, product: 'Limited Edition NFT', buyer: '0xabcd...1234', price: '0.05 ETH', status: 'paid', date: '2 hours ago' },
  { id: 2, product: 'Crypto Course', buyer: '0xefgh...5678', price: '0.1 ETH', status: 'shipped', date: '1 day ago' },
  { id: 3, product: 'Consultation', buyer: '0xijkl...9012', price: '0.5 ETH', status: 'pending', date: '2 days ago' },
];

const mockProducts = [
  { id: 1, name: 'Limited Edition NFT', price: '0.05 ETH', stock: 10, sales: 15 },
  { id: 2, name: 'Crypto Course', price: '0.1 ETH', stock: 50, sales: 28 },
  { id: 3, name: 'Consultation', price: '0.5 ETH', stock: 5, sales: 2 },
];

type Tab = 'overview' | 'orders' | 'products' | 'settings';

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState<Tab>('overview');

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Seller Dashboard</h1>

      {/* Tabs */}
      <div className="tabs tabs-boxed mb-6">
        <button 
          className={`tab ${activeTab === 'overview' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button 
          className={`tab ${activeTab === 'orders' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('orders')}
        >
          Orders
        </button>
        <button 
          className={`tab ${activeTab === 'products' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('products')}
        >
          Products
        </button>
        <button 
          className={`tab ${activeTab === 'settings' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('settings')}
        >
          Settings
        </button>
      </div>

      {/* Overview Tab */}
      {activeTab === 'overview' && (
        <div className="space-y-6">
          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="stat bg-base-100 rounded-box shadow">
              <div className="stat-title">Total Sales</div>
              <div className="stat-value text-primary">{mockStats.totalSales}</div>
              <div className="stat-desc">All time</div>
            </div>
            <div className="stat bg-base-100 rounded-box shadow">
              <div className="stat-title">Orders</div>
              <div className="stat-value">{mockStats.totalOrders}</div>
              <div className="stat-desc">Pending: 3</div>
            </div>
            <div className="stat bg-base-100 rounded-box shadow">
              <div className="stat-title">Products</div>
              <div className="stat-value">{mockStats.totalProducts}</div>
              <div className="stat-desc">Active listings</div>
            </div>
            <div className="stat bg-base-100 rounded-box shadow">
              <div className="stat-title">Rating</div>
              <div className="stat-value">⭐ {mockStats.averageRating}</div>
              <div className="stat-desc">45 reviews</div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="flex gap-4">
            <Link href="/dashboard/products/new" className="btn btn-primary">
              + Add Product
            </Link>
            <Link href="/dashboard/stream" className="btn btn-secondary">
              Go Live
            </Link>
          </div>

          {/* Recent Orders */}
          <div className="bg-base-100 rounded-box shadow-lg p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">Recent Orders</h2>
              <button 
                onClick={() => setActiveTab('orders')}
                className="btn btn-ghost btn-sm"
              >
                View All →
              </button>
            </div>
            <div className="overflow-x-auto">
              <table className="table">
                <thead>
                  <tr>
                    <th>Order</th>
                    <th>Buyer</th>
                    <th>Price</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {mockOrders.slice(0, 3).map((order) => (
                    <tr key={order.id}>
                      <td>{order.product}</td>
                      <td className="text-sm font-mono">{order.buyer}</td>
                      <td className="text-primary font-bold">{order.price}</td>
                      <td>
                        <span className={`badge ${
                          order.status === 'paid' ? 'badge-success' :
                          order.status === 'shipped' ? 'badge-info' :
                          'badge-warning'
                        }`}>
                          {order.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Orders Tab */}
      {activeTab === 'orders' && (
        <div className="bg-base-100 rounded-box shadow-lg p-6">
          <h2 className="text-xl font-bold mb-4">All Orders</h2>
          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Product</th>
                  <th>Buyer</th>
                  <th>Price</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {mockOrders.map((order) => (
                  <tr key={order.id}>
                    <td>#{order.id}</td>
                    <td>{order.product}</td>
                    <td className="text-sm font-mono">{order.buyer}</td>
                    <td className="text-primary font-bold">{order.price}</td>
                    <td>
                      <span className={`badge ${
                        order.status === 'paid' ? 'badge-success' :
                        order.status === 'shipped' ? 'badge-info' :
                        'badge-warning'
                      }`}>
                        {order.status}
                      </span>
                    </td>
                    <td>
                      {order.status === 'paid' && (
                        <button className="btn btn-xs btn-primary">Ship</button>
                      )}
                      {order.status === 'shipped' && (
                        <span className="text-sm text-base-content/50">Awaiting delivery</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Products Tab */}
      {activeTab === 'products' && (
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold">Your Products</h2>
            <Link href="/dashboard/products/new" className="btn btn-primary">
              + Add Product
            </Link>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {mockProducts.map((product) => (
              <div key={product.id} className="bg-base-100 rounded-box shadow-lg p-4">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="font-bold">{product.name}</h3>
                  <div className="dropdown dropdown-end">
                    <button tabIndex={0} className="btn btn-ghost btn-xs">⋮</button>
                    <ul tabIndex={0} className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-32">
                      <li><a>Edit</a></li>
                      <li><a>Delete</a></li>
                    </ul>
                  </div>
                </div>
                <p className="text-primary font-bold">{product.price}</p>
                <div className="flex justify-between text-sm text-base-content/60 mt-2">
                  <span>Stock: {product.stock}</span>
                  <span>Sales: {product.sales}</span>
                </div>
                <div className="w-full bg-base-200 rounded-full h-2 mt-2">
                  <div 
                    className="bg-primary h-2 rounded-full" 
                    style={{ width: `${(product.sales / (product.stock + product.sales)) * 100}%` }}
                  ></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Settings Tab */}
      {activeTab === 'settings' && (
        <div className="bg-base-100 rounded-box shadow-lg p-6 max-w-2xl">
          <h2 className="text-xl font-bold mb-6">Channel Settings</h2>
          
          <form className="space-y-4">
            <div className="form-control">
              <label className="label">
                <span className="label-text font-bold">Channel Name</span>
              </label>
              <input 
                type="text" 
                defaultValue="cryptoking.midl" 
                className="input input-bordered" 
                disabled
              />
            </div>

            <div className="form-control">
              <label className="label">
                <span className="label-text font-bold">Display Name</span>
              </label>
              <input 
                type="text" 
                defaultValue="CryptoKing" 
                className="input input-bordered" 
              />
            </div>

            <div className="form-control">
              <label className="label">
                <span className="label-text font-bold">Description</span>
              </label>
              <textarea 
                className="textarea textarea-bordered" 
                defaultValue="Crypto enthusiast sharing the latest in blockchain, NFTs, and DeFi."
                rows={3}
              ></textarea>
            </div>

            <div className="form-control">
              <label className="label">
                <span className="label-text font-bold">Stream Key</span>
              </label>
              <input 
                type="password" 
                defaultValue="sk_live_xxxxx" 
                className="input input-bordered" 
              />
              <label className="label">
                <span className="label-text-alt">Keep this secret!</span>
              </label>
            </div>

            <button type="submit" className="btn btn-primary">
              Save Changes
            </button>
          </form>
        </div>
      )}
    </div>
  );
}
