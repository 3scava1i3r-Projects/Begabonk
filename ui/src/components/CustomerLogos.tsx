interface Company {
  name: string;
  img: string;
}

interface CustomerLogosProps {
  title?: string;
  companies?: Company[];
}

const defaultCompanies: Company[] = [
  { name: 'NVIDIA', img: 'https://upload.wikimedia.org/wikipedia/commons/2/2b/NVIDIA_logo.svg' },
  { name: 'GitHub', img: 'https://upload.wikimedia.org/wikipedia/commons/2/2c/GitHub_Logo.svg' },
  { name: 'Nike', img: 'https://upload.wikimedia.org/wikipedia/commons/3/3e/Just_%27It%21_Nike_logo.svg' },
  { name: 'OpenAI', img: 'https://upload.wikimedia.org/wikipedia/commons/4/4d/OpenAI_Logo.svg' },
  { name: 'Stripe', img: 'https://upload.wikimedia.org/wikipedia/commons/b/ba/Stripe_Logo%2C_revised_2016.svg' },
  { name: 'Vercel', img: 'https://assets.vercel.com/image/upload/v1588805858/repositories/vercel/logo.png' },
];

export default function CustomerLogos({
  title = 'Trusted by innovative companies worldwide',
  companies = defaultCompanies,
}: CustomerLogosProps) {
  return (
    <section className="bg-base-100 py-16 md:py-32">
      <div className="mx-auto max-w-5xl px-6">
        <p className="text-center text-sm text-base-content/60 mb-12">
          {title}
        </p>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-8 items-center opacity-70">
          {companies.map((company, index) => (
            <div key={index} className="flex justify-center">
              <img
                src={company.img}
                alt={company.name}
                className="h-8 w-auto grayscale hover:grayscale-0 transition-all duration-300"
              />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}