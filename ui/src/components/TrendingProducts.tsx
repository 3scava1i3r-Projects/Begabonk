import Link from 'next/link';

export interface Product {
  name: string;
  price: string;
  channel: string;
  image: string;
}

interface TrendingProductsProps {
  products?: Product[];
  title?: string;
  viewAllHref?: string;
}

const defaultProducts: Product[] = [
  { name: 'Limited Edition NFT', price: '0.05 ETH', channel: 'cryptoking.midl', image: '🎨' },
  { name: 'Smart Watch Pro', price: '0.1 ETH', channel: 'gadgetzone.midl', image: '⌚' },
  { name: 'Digital Art Piece', price: '0.02 ETH', channel: 'artforge.midl', image: '🖼️' },
];

export default function TrendingProducts({
  products = defaultProducts,
  title = 'Trending Products',
  viewAllHref = '/products',
}: TrendingProductsProps) {
  return (
    <section className="mb-12">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">{title}</h2>
        <Link href={viewAllHref} className="text-primary hover:underline">
          View All →
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {products.map((product, idx) => (
          <div key={idx} className="card bg-base-100 shadow-md">
            <figure className="h-40 flex items-center justify-center text-6xl bg-base-200">
              {product.image}
            </figure>
            <div className="card-body">
              <h3 className="card-title text-lg">{product.name}</h3>
              <p className="text-primary font-bold">{product.price}</p>
              <p className="text-sm text-base-content/60">{product.channel}</p>
              <div className="card-actions justify-end mt-2">
                <Link href={`/channel/${product.channel}`} className="btn btn-sm btn-outline">
                  View
                </Link>
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}