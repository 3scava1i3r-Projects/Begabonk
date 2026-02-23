'use client';

import Link from 'next/link';
import { ChevronRight } from 'lucide-react';

interface HeroSectionProps {
  badge?: {
    text: string;
    href: string;
  };
  title?: string;
  highlightText?: string;
  subtitle?: string;
  primaryCta?: {
    text: string;
    href?: string;
  };
  secondaryCta?: {
    text: string;
    href?: string;
  };
  screenshotUrl?: string;
}

export default function HeroSection({
  badge = { text: '✨ Introducing AI Support', href: '#new' },
  title = 'Modern Solutions for',
  highlightText = 'Customer Engagement',
  subtitle = 'Highly customizable components for building modern websites and applications that look and feel the way you mean it.',
  primaryCta = { text: 'Start Building', href: '#' },
  secondaryCta = { text: 'Request Demo', href: '#' },
  screenshotUrl = 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1920&q=80',
}: HeroSectionProps) {
  return (
    <section className="relative overflow-hidden pt-24 lg:pt-32">
      {/* Background Effects */}
      <div aria-hidden className="pointer-events-none absolute inset-0 z-0 hidden lg:block">
        <div className="absolute -left-40 top-0 h-[80rem] w-56 -rotate-45 rounded-full bg-[radial-gradient(ellipse_at_center,hsla(0,0%,85%,0.08)_0,transparent_70%)]" />
      </div>

      {/* Hero Content */}
      <div className="relative mx-auto max-w-7xl px-6">
        <div className="text-center sm:mx-auto lg:mr-auto lg:mt-0">
          {/* Animated Badge */}
          <div className="animate-fade-in-up">
            <Link
              href={badge.href}
              className="badge badge-lg gap-2 bg-base-200 hover:bg-base-300 cursor-pointer transition-all duration-300">
              <span className="text-sm">{badge.text}</span>
              <ChevronRight className="w-4 h-4" />
            </Link>
          </div>

          {/* Headline */}
          <h1 className="mt-8 text-5xl md:text-6xl lg:text-7xl xl:text-8xl font-bold text-base-content leading-tight">
            {title}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">
              {' '}{highlightText}
            </span>
          </h1>

          {/* Subtitle */}
          <p className="mx-auto mt-6 max-w-2xl text-lg text-base-content/70">
            {subtitle}
          </p>

          {/* CTA Buttons */}
          <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
            {primaryCta.href ? (
              <Link href={primaryCta.href} className="btn btn-primary btn-lg gap-2">
                {primaryCta.text}
                <ChevronRight className="w-5 h-5" />
              </Link>
            ) : (
              <button className="btn btn-primary btn-lg gap-2">
                {primaryCta.text}
                <ChevronRight className="w-5 h-5" />
              </button>
            )}
            {secondaryCta.href ? (
              <Link href={secondaryCta.href} className="btn btn-ghost btn-lg">
                {secondaryCta.text}
              </Link>
            ) : (
              <button className="btn btn-ghost btn-lg">
                {secondaryCta.text}
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Product Screenshot */}
      <div className="relative mt-16 overflow-hidden px-2 sm:mt-20">
        <div className="absolute inset-0 bg-gradient-to-t from-base-100 via-transparent to-transparent z-10" />
        <div className="mx-auto max-w-6xl rounded-3xl border border-base-300 bg-base-200/50 p-2 shadow-2xl">
          <div className="rounded-2xl overflow-hidden bg-base-100">
            <img
              src={screenshotUrl}
              alt="App Dashboard"
              className="w-full h-auto"
            />
          </div>
        </div>
      </div>
    </section>
  );
}