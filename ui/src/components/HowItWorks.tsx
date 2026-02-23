interface Step {
  icon: string;
  title: string;
  description: string;
  bgColor?: string;
}

interface HowItWorksProps {
  title?: string;
  steps?: Step[];
}

const defaultSteps: Step[] = [
  {
    icon: '🔍',
    title: '1. Find a Channel',
    description: 'Search for your favorite creator by their .midl name',
    bgColor: 'bg-primary/20',
  },
  {
    icon: '📺',
    title: '2. Watch Live',
    description: 'Join the live stream and see products in action',
    bgColor: 'bg-secondary/20',
  },
  {
    icon: '💳',
    title: '3. Buy Instantly',
    description: 'Purchase with crypto, no checkout needed',
    bgColor: 'bg-accent/20',
  },
];

export default function HowItWorks({
  title = 'How It Works',
  steps = defaultSteps,
}: HowItWorksProps) {
  return (
    <section>
      <h2 className="text-2xl font-bold text-center mb-8">{title}</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {steps.map((step, index) => (
          <div key={index} className="text-center">
            <div className={`w-16 h-16 rounded-full ${step.bgColor} flex items-center justify-center mx-auto mb-4`}>
              <span className="text-2xl">{step.icon}</span>
            </div>
            <h3 className="font-bold mb-2">{step.title}</h3>
            <p className="text-base-content/70">{step.description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}