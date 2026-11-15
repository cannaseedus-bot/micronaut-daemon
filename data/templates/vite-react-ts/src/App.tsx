import { useState } from 'react'
import DarkModeToggle from './components/DarkModeToggle'

// {{lfm:expand — add feature components here based on features: {{features}} }}

export default function App() {
  const [dark, setDark] = useState(false)

  return (
    <div className={dark ? 'dark' : ''}>
      <div className="min-h-screen transition-colors bg-white dark:bg-[{{brand_dark}}] text-gray-900 dark:text-gray-100">
        <header className="flex items-center justify-between px-6 py-4 border-b border-gray-200 dark:border-gray-700">
          <h1 className="text-xl font-bold" style={{ color: 'var(--brand)' }}>{{app_name}}</h1>
          <DarkModeToggle dark={dark} onToggle={() => setDark(d => !d)} />
        </header>
        <main className="p-6">
          {/* {{lfm:content — main app content for {{app_name}} */}
          <p className="text-gray-500 dark:text-gray-400">{{description}}</p>
        </main>
      </div>
    </div>
  )
}
