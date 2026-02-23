'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';
import Logo from './Logo';

interface MenuItem {
  name: string;
  href: string;
}

interface HeaderProps {
  menuItems?: MenuItem[];
}

const defaultMenuItems: MenuItem[] = [
  { name: 'Features', href: '#features' },
  { name: 'Solution', href: '#solution' },
  { name: 'Pricing', href: '#pricing' },
  { name: 'About', href: '#about' },
];

export default function Header({ menuItems = defaultMenuItems }: HeaderProps) {
  const [menuState, setMenuState] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 50);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className="fixed top-0 z-50 w-full">
      <div className={`mx-auto mt-2 max-w-6xl px-6 transition-all duration-300 lg:px-12 ${isScrolled ? 'max-w-4xl rounded-2xl border border-base-300 bg-base-100/80 backdrop-blur-lg lg:px-5' : ''}`}>
        <div className="flex flex-wrap items-center justify-between gap-4 py-3 lg:gap-0 lg:py-4">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2">
            <Logo />
          </Link>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setMenuState(!menuState)}
            className="btn btn-ghost btn-square lg:hidden"
            aria-label={menuState ? 'Close Menu' : 'Open Menu'}>
            {menuState ? (
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            ) : (
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            )}
          </button>

          {/* Desktop Menu */}
          <div className="hidden lg:flex">
            <ul className="menu menu-horizontal px-1">
              {menuItems.map((item, index) => (
                <li key={index}>
                  <Link href={item.href} className="hover:text-primary">
                    {item.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Auth Buttons */}
          <div className={`flex gap-3 ${menuState ? 'flex' : 'hidden'} lg:flex`}>
            <button className={`btn btn-ghost btn-sm ${isScrolled ? 'hidden lg:inline-flex' : ''}`}>
              Get Started
            </button>
            <button className="btn btn-primary btn-sm">
              Sign Up
            </button>
          </div>
        </div>

        {/* Mobile Menu Dropdown */}
        {menuState && (
          <div className="lg:hidden pb-4">
            <ul className="menu bg-base-200 rounded-box p-4">
              {menuItems.map((item, index) => (
                <li key={index}>
                  <Link href={item.href}>{item.name}</Link>
                </li>
              ))}
              <li className="mt-4">
                <button className="btn btn-primary btn-block">Sign Up</button>
              </li>
            </ul>
          </div>
        )}
      </div>
    </header>
  );
}