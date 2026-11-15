interface Props { dark: boolean; onToggle: () => void }

export default function DarkModeToggle({ dark, onToggle }: Props) {
  return (
    <button
      onClick={onToggle}
      className="rounded-full w-10 h-6 flex items-center transition-colors duration-300"
      style={{ backgroundColor: dark ? '{{brand_color}}' : '#d1d5db' }}
      aria-label="Toggle dark mode"
    >
      <span
        className="inline-block w-4 h-4 rounded-full bg-white shadow transform transition-transform duration-300"
        style={{ transform: dark ? 'translateX(20px)' : 'translateX(2px)' }}
      />
    </button>
  )
}
