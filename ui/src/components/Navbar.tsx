'use client';

import Link from 'next/link';
import { useState } from 'react';

export default function Navbar() {
  const [connected, setConnected] = useState(false);
  const [address, setAddress] = useState('');

  const connectWallet = async () => {
    // Mock wallet connection for demo
    setConnected(true);
    setAddress('0x1234...5678');
  };

  return (
    <div className="navbar bg-base-100 shadow-sm border-b border-base-200">
      <div className="flex-1">
        <Link href="/" className="btn btn-ghost text-xl">
          <span className="text-primary font-bold">mina</span>
          <span className="text-secondary">.live</span>
        </Link>
      </div>
      <div className="flex-none gap-2">
        <div className="form-control">
          <input 
            type="text" 
            placeholder="Search channels..." 
            className="input input-bordered w-48 md:w-64" 
          />
        </div>
        <div className="dropdown dropdown-end">
          <div tabIndex={0} role="button" className="btn btn-ghost btn-circle avatar placeholder">
            <div className="bg-neutral text-neutral-content rounded-full w-10">
              <span className="text-xs">?</span>
            </div>
          </div>
          <ul tabIndex={0} className="mt-3 z-[1] p-2 shadow menu menu-sm dropdown-content bg-base-100 rounded-box w-52">
            {!connected ? (
              <li><button onClick={connectWallet}>Connect Wallet</button></li>
            ) : (
              <>
                <li><Link href="/dashboard">Dashboard</Link></li>
                <li><Link href="/orders">My Orders</Link></li>
                <li><button onClick={() => setConnected(false)}>Disconnect</button></li>
              </>
            )}
          </ul>
        </div>
      </div>
    </div>
  );
}
