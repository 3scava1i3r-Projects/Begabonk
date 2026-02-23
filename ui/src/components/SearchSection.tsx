'use client';

import { useState } from 'react';

interface SearchSectionProps {
  placeholder?: string;
  buttonText?: string;
  onSearch?: (query: string) => void;
}

export default function SearchSection({
  placeholder = 'Search channels (e.g., cryptoking.midl)',
  buttonText = 'Search',
  onSearch,
}: SearchSectionProps) {
  const [query, setQuery] = useState('');

  const handleSearch = () => {
    if (onSearch) {
      onSearch(query);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  return (
    <section className="mb-12">
      <div className="join w-full max-w-2xl mx-auto">
        <input
          className="input input-bordered join-item flex-1"
          placeholder={placeholder}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyPress={handleKeyPress}
        />
        <button className="btn btn-primary join-item" onClick={handleSearch}>
          {buttonText}
        </button>
      </div>
    </section>
  );
}