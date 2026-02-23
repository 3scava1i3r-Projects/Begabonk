import Link from 'next/link';

export interface Channel {
  name: string;
  owner: string;
  live: boolean;
  viewers: number;
  products: number;
}

interface LiveChannelsProps {
  channels?: Channel[];
  title?: string;
  viewAllHref?: string;
}

const defaultChannels: Channel[] = [
  { name: 'cryptoking.midl', owner: '0x1234...5678', live: true, viewers: 234, products: 5 },
  { name: 'techdeals.midl', owner: '0xabcd...efgh', live: true, viewers: 156, products: 12 },
  { name: 'artforge.midl', owner: '0x9876...5432', live: false, viewers: 0, products: 8 },
  { name: 'gadgetzone.midl', owner: '0xdef0...1234', live: true, viewers: 89, products: 20 },
];

export default function LiveChannels({
  channels = defaultChannels,
  title = 'Live Now',
  viewAllHref = '/live',
}: LiveChannelsProps) {
  const liveChannels = channels.filter(c => c.live);

  return (
    <section className="mb-12">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold flex items-center gap-2">
          <span className="relative flex h-3 w-3">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
          </span>
          {title}
        </h2>
        <Link href={viewAllHref} className="text-primary hover:underline">
          View All →
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {liveChannels.map((channel) => (
          <Link href={`/channel/${channel.name}`} key={channel.name}>
            <div className="card bg-base-100 shadow-md hover:shadow-xl transition-shadow">
              <div className="card-body">
                <div className="badge badge-primary badge-outline">LIVE</div>
                <h3 className="card-title text-lg mt-2">{channel.name}</h3>
                <p className="text-sm text-base-content/60">{channel.viewers} viewers</p>
                <div className="card-actions justify-end mt-4">
                  <button className="btn btn-sm btn-primary">Watch</button>
                </div>
              </div>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}