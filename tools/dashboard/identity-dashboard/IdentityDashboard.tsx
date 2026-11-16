// IdentityDashboard.tsx
// Browser/CDN mode: loaded via <script type="text/babel"> — React from window.React (UMD)
// Bundled mode: add `import React, { useState, useEffect } from 'react';` and remove window assignment.
//
// Styling uses css.manifest.json tokens directly:
//   ⟁BGterm=#01040a  ⟁BGpanel=#020b12  ⟁BGalt=#050b1c
//   ⟁Pprimary=#22f2b3  ⟁Psecondary=#38bdf8  ⟁Paccent=#a855f7
//   ⟁TEXT=#e5f2ff  ⟁TEXTsoft=#9ca3af  ⟁TEXTstrong=#f9fafb
//   ⟁BORDER=rgba(148,163,184,0.5)  ⟁BORDERglow=rgba(56,189,248,0.9)
//   ⟁BRsm=0.375rem  ⟁BRmd=0.75rem  ⟁BRlg=1.25rem

// ── Manifest data ─────────────────────────────────────────────────────────────

type SyntaxKind = 'atom' | 'snippet' | 'block' | 'component' | 'layout' | 'application';

interface CssApp {
  kind: SyntaxKind;
  lang: string;
  keys: string[];
}

const CSS_APPS: Record<string, CssApp> = {
  '⟁TYPE:BGPANEL':    { kind: 'snippet',     lang: 'css',      keys: ['⟁BGpanel'] },
  '⟁TYPE:BTNPRIMARY': { kind: 'snippet',     lang: 'css',      keys: ['⟁BTNPRIMARY', '⟁BTNBASE'] },
  '⟁TYPE:PANEL':      { kind: 'block',       lang: 'css',      keys: ['⟁PANEL', '⟁BGpanel', '⟁BRlg', '⟁BORDER'] },
  '⟁TYPE:CARD':       { kind: 'block',       lang: 'css',      keys: ['⟁CARD', '⟁PANEL'] },
  '⟁TYPE:WIDGETCARD': { kind: 'component',   lang: 'html+css', keys: ['⟁WIDGETCARD', '⟁CARD', '⟁FLEXCOL', '⟁GAP'] },
  '⟁TYPE:WIDGET':     { kind: 'component',   lang: 'html+css', keys: ['⟁WIDGET', '⟁WIDGETHEADER', '⟁WIDGETBODY', '⟁WIDGETFOOTER', '⟁WIDGETBTN'] },
  '⟁TYPE:HTMLPAGE':   { kind: 'layout',      lang: 'html+css', keys: ['⟁HTMLPAGE', '⟁HTMLSHELL', '⟁GRID'] },
  '⟁TYPE:BLOGLAYOUT': { kind: 'layout',      lang: 'html+css', keys: ['⟁BLOGLAYOUT', '⟁BLOG', '⟁BLOGEDITOR', '⟁BLOGTOOLBAR'] },
  '⟁TYPE:CHAT':       { kind: 'component',   lang: 'html+css', keys: ['⟁CHAT', '⟁CHAT:STYLE', '⟁CHAT:STRUCTURE', '⟁CHAT:MICRONAUT'] },
  '⟁TYPE:DOGWALKAPP': { kind: 'application', lang: 'html+css', keys: ['⟁DOGWALKAPP', '⟁DOGWALKCARD', '⟁DOGWALKROUTE', '⟁DOGWALKSCHED'] },
};

const KIND_ORDER: SyntaxKind[] = ['snippet', 'block', 'component', 'layout', 'application'];

const TOOLS: Record<string, string[]> = {
  MATH:  ['ADD', 'SUB', 'MUL', 'DIV', 'CLAMP', 'LERP', 'NORM', 'MOD'],
  FN:    ['COMPOSE', 'PIPE', 'CURRY', 'MEMO'],
  GRAPH: ['NODE', 'EDGE', 'BFS', 'DFS', 'DIJKSTRA', 'TOPO', 'CYCLE', 'LAYOUT2D'],
  SHEET: ['CSS', 'AIML', 'MATH', 'GRAPH', 'DB'],
  EVAL:  ['CALL', 'PIPELINE', 'TRACE'],
};

interface KgfLane {
  id: string;
  programs: string[];
  phases: string;
  authority: string;
  candidateOnly: boolean;
}

const KGF_LANES: KgfLane[] = [
  { id: 'kgf:key-app-builder', programs: ['BUILD', 'EDIT_CANDIDATE', 'VALIDATE', 'INSPECT'],  phases: 'all',                       authority: 'proposal_only',   candidateOnly: true  },
  { id: 'kgf:question-engine', programs: ['GENERATE', 'RANK', 'FILTER'],                       phases: 'Pop/Wo/Yax/Sek/Ch\'en/Xul', authority: 'read_only',       candidateOnly: false },
  { id: 'kgf:learning-lane',   programs: ['PROPOSE', 'ACCUMULATE', 'VERIFY', 'CLOSE'],         phases: 'Yax/Sek/Ch\'en/Xul',        authority: 'proposal_only',   candidateOnly: true  },
  { id: 'kgf:gradient-lane',   programs: ['DERIVE', 'SELECT', 'VERIFY', 'CLOSE'],              phases: 'Yax/Sek/Ch\'en/Xul',        authority: 'proposal_only',   candidateOnly: true  },
  { id: 'kgf:autocomplete-lane', programs: ['SUGGEST', 'FILTER', 'RANK'],                      phases: 'Yax/Sek',                   authority: 'read_only',       candidateOnly: false },
  { id: 'kgf:tool-control',    programs: ['GET', 'POST', 'READ', 'WRITE', 'INSPECT', 'RUN'],   phases: 'Wo/Yax',                    authority: 'candidate_only',  candidateOnly: true  },
  { id: 'kgf:geometric-coder', programs: ['ANALYZE', 'GENERATE'],                              phases: 'Yax/Sek',                   authority: 'projection_only', candidateOnly: false },
];

const PROGRAMS = [
  { name: 'ELIZA-REASON-µ', file: 'reasoning-board.aiml', desc: 'Reasoning operators → XCFE envelopes', status: 'running' as const },
  { name: 'AIML-µ',         file: 'aiml.manifest.json',   desc: 'Pattern match, SRAI dispatch',         status: 'running' as const },
  { name: 'ELIZA-µ',        file: 'eliza.manifest.json',  desc: 'Rogerian fallback, operator pack',     status: 'running' as const },
  { name: 'ADVISOR-µ',      file: 'advisor.aiml',          desc: 'Expert routing, card view',           status: 'running' as const },
  { name: 'PARITY',         file: 'build/Release/',        desc: 'C++ kernel vs reference validator',   status: 'idle'    as const },
];

const PORT_MAP = [
  { name: 'kuhul_engine', port: 17474, role: 'phase runtime' },
  { name: 'BOSS',         port: 8764,  role: 'orchestrator' },
  { name: 'eliza-http',   port: 9879,  role: 'chat API, /api/chat, /v1/chat/completions' },
  { name: 'bus',          port: 9880,  role: 'micronaut bus' },
  { name: 'dashboard',    port: 9882,  role: 'identity dashboard (this window)' },
];

const TRACE_STEPS = [
  { micronaut: 'AIML-µ',         arrow: '→', output: 'match: WHO ARE YOU → IDENTITY CARD'  },
  { micronaut: 'SRAI-µ',         arrow: '→', output: 'redirect: IDENTITY CARD'              },
  { micronaut: 'ELIZA-REASON-µ', arrow: '→', output: 'signal: ⟁IDENTITY  conf: DECLARED'   },
  { micronaut: 'XCFE-µ',         arrow: '→', output: 'admit: guard open  candidate only'    },
  { micronaut: 'XUL-µ',         arrow: '→', output: 'close: identity text emitted'          },
];

// ── Tab type ──────────────────────────────────────────────────────────────────

type Tab = 'apps' | 'tools' | 'programs' | 'grammar' | 'traces' | 'hosting';

const TABS: { id: Tab; label: string }[] = [
  { id: 'apps',     label: 'Apps'     },
  { id: 'tools',    label: 'Tools'    },
  { id: 'programs', label: 'Programs' },
  { id: 'grammar',  label: 'Grammar'  },
  { id: 'traces',   label: 'Traces'   },
  { id: 'hosting',  label: 'Hosting'  },
];

// ── Root component ────────────────────────────────────────────────────────────

interface Props {
  runtimePort?: string;
}

function IdentityDashboard({ runtimePort = '9879' }: Props) {
  const [tab, setTab] = React.useState<Tab>('apps');
  const [runtimeStatus, setRuntimeStatus] = React.useState<'connecting' | 'live' | 'offline'>('connecting');
  const [identityText, setIdentityText] = React.useState<string>('');

  React.useEffect(() => {
    if (!runtimePort) { setRuntimeStatus('offline'); return; }
    fetch(`http://127.0.0.1:${runtimePort}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: 'WHO ARE YOU' }),
    })
      .then(r => r.json())
      .then((data: any) => {
        const text: string = data.response ?? data.text ?? JSON.stringify(data);
        // If runtime returns a dispatch marker, switch to dashboard view
        if (text.includes('[kuhul:dispatch')) setTab('apps');
        setIdentityText(text);
        setRuntimeStatus('live');
      })
      .catch(() => setRuntimeStatus('offline'));
  }, [runtimePort]);

  const statusColor = runtimeStatus === 'live' ? '#22f2b3' : runtimeStatus === 'offline' ? '#fb7185' : '#facc15';
  const statusLabel = runtimeStatus === 'live' ? 'runtime live' : runtimeStatus === 'offline' ? 'runtime offline' : 'connecting…';

  return (
    <div style={S.root}>
      <div style={S.header}>
        <div>
          <div style={S.brand}>AI-µ</div>
          <div style={S.subtitle}>Not who I am — what I can do.</div>
        </div>
        <div style={{ ...S.badge, color: statusColor, borderColor: statusColor }}>
          {statusLabel}
        </div>
      </div>

      <div style={S.tabs}>
        {TABS.map(t => (
          <button key={t.id} style={{ ...S.tab, ...(tab === t.id ? S.tabActive : {}) }}
            onClick={() => setTab(t.id)}>
            {t.label}
          </button>
        ))}
      </div>

      <div style={S.body}>
        {tab === 'apps'     && <AppsTab />}
        {tab === 'tools'    && <ToolsTab />}
        {tab === 'programs' && <ProgramsTab />}
        {tab === 'grammar'  && <GrammarTab />}
        {tab === 'traces'   && <TracesTab identityText={identityText} />}
        {tab === 'hosting'  && <HostingTab />}
      </div>
    </div>
  );
}

// ── Apps tab ──────────────────────────────────────────────────────────────────

function AppsTab() {
  const [selected, setSelected] = React.useState<string | null>(null);
  const app = selected ? CSS_APPS[selected] : null;

  return (
    <div style={S.appsLayout}>
      <div style={S.appList}>
        <div style={S.sectionHead}>⟁SYNTAXUNITKINDS</div>
        {KIND_ORDER.map(kind => (
          <div key={kind}>
            <div style={S.kindLabel}>{kind}</div>
            {Object.entries(CSS_APPS).filter(([, v]) => v.kind === kind).map(([name]) => (
              <button key={name} style={{ ...S.appItem, ...(selected === name ? S.appItemActive : {}) }}
                onClick={() => setSelected(name === selected ? null : name)}>
                <span style={{ color: '#38bdf8' }}>{name}</span>
              </button>
            ))}
          </div>
        ))}
      </div>

      <div style={S.appDetail}>
        {!app && (
          <div style={S.appPlaceholder}>
            <div style={{ color: '#22f2b3', fontSize: '1.1rem', fontWeight: 700 }}>key-app-builder</div>
            <div style={{ color: '#9ca3af', marginTop: 8 }}>Select a ⟁TYPE to see its key grammar.</div>
            <div style={{ color: '#6b7280', marginTop: 12, fontSize: '0.8rem' }}>
              source: css.manifest.json · authority: proposal_only · output: asx.mini-app.v1 + html-preview
            </div>
          </div>
        )}
        {app && (
          <div>
            <div style={{ color: '#f9fafb', fontWeight: 700, marginBottom: 6 }}>{selected}</div>
            <div style={{ color: '#9ca3af', fontSize: '0.8rem', marginBottom: 12 }}>
              kind: <span style={{ color: '#38bdf8' }}>{app.kind}</span>
              {' · '}lang: <span style={{ color: '#38bdf8' }}>{app.lang}</span>
            </div>
            <div style={S.sectionHead}>key grammar</div>
            <div style={{ display: 'flex', flexWrap: 'wrap' as const, gap: 6, marginTop: 6 }}>
              {app.keys.map(k => (
                <span key={k} style={S.chip}>{k}</span>
              ))}
            </div>
            <div style={{ marginTop: 16, color: '#6b7280', fontSize: '0.75rem' }}>
              authority: proposal_only · candidate_only: true · xcfe_required: true
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ── Tools tab ─────────────────────────────────────────────────────────────────

function ToolsTab() {
  return (
    <div>
      <div style={{ color: '#9ca3af', fontSize: '0.8rem', marginBottom: 12 }}>
        source: css.manifest.json · ⟁CAPABILITY:CONSOLE · authority: candidate_handoff
      </div>
      {Object.entries(TOOLS).map(([domain, ops]) => (
        <div key={domain} style={S.toolGroup}>
          <div style={S.sectionHead}>⟁{domain}</div>
          <div style={{ display: 'flex', flexWrap: 'wrap' as const, gap: 6, marginTop: 6 }}>
            {ops.map(op => (
              <span key={op} style={S.chip}>⟁{domain}:{op}</span>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

// ── Programs tab ──────────────────────────────────────────────────────────────

function ProgramsTab() {
  return (
    <div>
      {PROGRAMS.map(p => (
        <div key={p.name} style={S.programCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <span style={{ color: '#a855f7', fontFamily: 'ui-monospace,monospace', fontWeight: 700 }}>{p.name}</span>
              <span style={{ color: '#6b7280', fontSize: '0.75rem', marginLeft: 10 }}>{p.file}</span>
            </div>
            <span style={{ ...S.statusBadge, background: p.status === 'running' ? 'rgba(34,242,179,0.1)' : 'rgba(107,114,128,0.15)', color: p.status === 'running' ? '#22f2b3' : '#6b7280' }}>
              {p.status}
            </span>
          </div>
          <div style={{ color: '#9ca3af', fontSize: '0.85rem', marginTop: 6 }}>{p.desc}</div>
        </div>
      ))}
    </div>
  );
}

// ── Grammar tab ───────────────────────────────────────────────────────────────

function GrammarTab() {
  return (
    <div>
      <div style={{ color: '#9ca3af', fontSize: '0.8rem', marginBottom: 12 }}>
        source: kgf.manifest.json · 2d-key-graph-execution-field.runtime-grammar.v2 · boundary: InvocationValidationBoundary
      </div>
      {KGF_LANES.map(lane => (
        <div key={lane.id} style={S.grammarCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap' as const, gap: 6 }}>
            <span style={{ color: '#38bdf8', fontFamily: 'ui-monospace,monospace', fontWeight: 600 }}>{lane.id}</span>
            <div style={{ display: 'flex', gap: 6 }}>
              <span style={{ ...S.statusBadge, background: 'rgba(56,189,248,0.1)', color: '#38bdf8' }}>{lane.authority}</span>
              {lane.candidateOnly && <span style={{ ...S.statusBadge, background: 'rgba(250,204,21,0.1)', color: '#facc15' }}>candidate_only</span>}
            </div>
          </div>
          <div style={{ marginTop: 8, display: 'flex', flexWrap: 'wrap' as const, gap: 6 }}>
            {lane.programs.map(p => (
              <span key={p} style={{ ...S.chip, background: 'rgba(168,85,247,0.1)', color: '#c4b5fd', borderRadius: '0.375rem' }}>{p}</span>
            ))}
          </div>
          <div style={{ color: '#6b7280', fontSize: '0.75rem', marginTop: 6 }}>phases: {lane.phases}</div>
        </div>
      ))}
    </div>
  );
}

// ── Traces tab ────────────────────────────────────────────────────────────────

function TracesTab({ identityText }: { identityText: string }) {
  return (
    <div>
      <div style={S.traceBox}>
        <div style={{ color: '#6b7280', fontSize: '0.75rem', marginBottom: 10 }}>WHO ARE YOU → reasoning tick</div>
        {TRACE_STEPS.map((s, i) => (
          <div key={i} style={S.traceRow}>
            <span style={{ color: '#a855f7', fontFamily: 'ui-monospace,monospace', minWidth: 160 }}>{s.micronaut}</span>
            <span style={{ color: '#6b7280', margin: '0 8px' }}>→</span>
            <span style={{ color: '#e5f2ff', fontSize: '0.85rem' }}>{s.output}</span>
          </div>
        ))}
      </div>

      {identityText && (
        <div style={{ marginTop: 16 }}>
          <div style={S.sectionHead}>runtime response</div>
          <pre style={{ ...S.traceBox, whiteSpace: 'pre-wrap' as const, wordBreak: 'break-word' as const, marginTop: 6, fontSize: '0.8rem', color: '#22f2b3', maxHeight: 220, overflow: 'auto' }}>
            {identityText}
          </pre>
        </div>
      )}
    </div>
  );
}

// ── Hosting tab ───────────────────────────────────────────────────────────────

function HostingTab() {
  const [logs, setLogs] = React.useState<string[]>([]);
  const [deploying, setDeploying] = React.useState(false);

  const deploy = () => {
    setDeploying(true);
    setLogs([]);
    const steps = [
      '[kuhul] phase engine check → port 17474',
      '[BOSS]  orchestrator check → port 8764',
      '[eliza] http server       → port 9879',
      '[bus]   micronaut bus     → port 9880',
      '[dash]  identity dashboard → port 9882',
      '[⟁XUL]  all ports attested — ecosystem live',
    ];
    let i = 0;
    const id = setInterval(() => {
      setLogs(prev => [...prev, steps[i]]);
      i++;
      if (i >= steps.length) { clearInterval(id); setDeploying(false); }
    }, 500);
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
        <div style={{ color: '#f9fafb', fontWeight: 700 }}>Port Map</div>
        <button style={S.btnPrimary} onClick={deploy} disabled={deploying}>
          {deploying ? 'deploying…' : 'deploy ecosystem'}
        </button>
      </div>
      <div style={{ marginBottom: 16 }}>
        {PORT_MAP.map(p => (
          <div key={p.port} style={{ display: 'flex', gap: 12, padding: '6px 0', borderBottom: '1px solid rgba(148,163,184,0.1)', alignItems: 'center' }}>
            <span style={{ color: '#22f2b3', fontFamily: 'ui-monospace,monospace', minWidth: 60 }}>{p.port}</span>
            <span style={{ color: '#38bdf8', minWidth: 120 }}>{p.name}</span>
            <span style={{ color: '#6b7280', fontSize: '0.8rem' }}>{p.role}</span>
          </div>
        ))}
      </div>
      <div style={S.traceBox}>
        {logs.length === 0 ? <span style={{ color: '#6b7280' }}>ready to deploy</span> : logs.map((l, i) => <div key={i}>{l}</div>)}
      </div>
    </div>
  );
}

// ── Styles (manifest token values inlined) ────────────────────────────────────

const S: Record<string, React.CSSProperties> = {
  root: {
    fontFamily: 'Inter,system-ui,sans-serif',
    background: '#01040a',          // ⟁BGterm
    color: '#e5f2ff',               // ⟁TEXT
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
  },
  header: {
    background: '#020b12',          // ⟁BGpanel
    borderBottom: '1px solid rgba(148,163,184,0.5)',  // ⟁BORDER
    padding: '14px 20px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  brand: {
    fontWeight: 800,
    fontSize: '1.2rem',
    color: '#a855f7',               // ⟁Paccent
    letterSpacing: '0.03em',
  },
  subtitle: {
    fontSize: '0.82rem',
    color: '#9ca3af',               // ⟁TEXTsoft
    marginTop: 3,
  },
  badge: {
    fontSize: '0.75rem',
    fontFamily: 'ui-monospace,monospace',
    padding: '3px 10px',
    borderRadius: '999px',
    border: '1px solid',
    background: 'transparent',
  },
  tabs: {
    display: 'flex',
    background: '#020b12',          // ⟁BGpanel
    borderBottom: '1px solid rgba(56,189,248,0.2)',
    padding: '0 16px',
    gap: 2,
  },
  tab: {
    background: 'transparent',
    border: 'none',
    color: '#9ca3af',               // ⟁TEXTsoft
    fontFamily: 'Inter,system-ui,sans-serif',
    fontWeight: 600,
    fontSize: '0.875rem',
    padding: '10px 14px',
    cursor: 'pointer',
    borderBottom: '2px solid transparent',
    transition: 'color .1s',
  },
  tabActive: {
    color: '#38bdf8',               // ⟁Psecondary
    borderBottomColor: '#38bdf8',
  },
  body: {
    flex: 1,
    padding: 20,
    overflowY: 'auto',
  },
  sectionHead: {
    color: '#6b7280',               // ⟁TEXTfaint
    fontSize: '0.72rem',
    fontWeight: 700,
    textTransform: 'uppercase',
    letterSpacing: '0.07em',
    marginBottom: 4,
  },
  chip: {
    display: 'inline-block',
    background: 'rgba(56,189,248,0.1)',
    color: '#38bdf8',               // ⟁Psecondary
    padding: '3px 9px',
    borderRadius: '0.375rem',       // ⟁BRsm
    fontFamily: 'ui-monospace,monospace',
    fontSize: '0.76rem',
  },
  appsLayout: {
    display: 'flex',
    gap: 20,
  },
  appList: {
    width: 220,
    flexShrink: 0,
  },
  kindLabel: {
    color: '#6b7280',
    fontSize: '0.7rem',
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    padding: '8px 0 2px 0',
  },
  appItem: {
    display: 'block',
    width: '100%',
    textAlign: 'left',
    background: 'transparent',
    border: 'none',
    padding: '5px 8px',
    borderRadius: '0.375rem',       // ⟁BRsm
    cursor: 'pointer',
    fontFamily: 'ui-monospace,monospace',
    fontSize: '0.78rem',
    color: '#9ca3af',
  },
  appItemActive: {
    background: 'rgba(56,189,248,0.1)',
  },
  appDetail: {
    flex: 1,
    background: '#020b12',          // ⟁BGpanel
    border: '1px solid rgba(148,163,184,0.5)',  // ⟁BORDER
    borderRadius: '0.75rem',        // ⟁BRmd
    padding: 16,
    minHeight: 180,
  },
  appPlaceholder: {
    color: '#6b7280',
    fontSize: '0.85rem',
  },
  toolGroup: {
    marginBottom: 16,
    background: '#020b12',          // ⟁BGpanel
    border: '1px solid rgba(148,163,184,0.5)',
    borderRadius: '0.75rem',
    padding: '12px 14px',
  },
  programCard: {
    background: '#020b12',          // ⟁BGpanel
    border: '1px solid rgba(148,163,184,0.5)',
    borderRadius: '0.75rem',
    padding: 12,
    marginBottom: 10,
  },
  statusBadge: {
    fontSize: '0.7rem',
    padding: '2px 8px',
    borderRadius: '999px',
    textTransform: 'uppercase',
    letterSpacing: '0.04em',
  },
  grammarCard: {
    background: '#020b12',
    border: '1px solid rgba(56,189,248,0.3)',  // ⟁BORDERglow toned
    borderRadius: '0.75rem',
    padding: 12,
    marginBottom: 10,
  },
  traceBox: {
    background: '#000',
    border: '1px solid rgba(148,163,184,0.5)',
    borderRadius: '0.75rem',
    padding: 14,
    fontFamily: 'ui-monospace,monospace',
    fontSize: '0.82rem',
    color: '#22f2b3',               // ⟁Pprimary
  },
  traceRow: {
    display: 'flex',
    alignItems: 'center',
    padding: '3px 0',
  },
  btnPrimary: {
    background: '#02281e',
    color: '#22f2b3',               // ⟁BTNPRIMARY tokens
    border: '1px solid rgba(56,189,248,0.9)',  // ⟁BORDERglow
    borderRadius: '0.75rem',
    padding: '8px 14px',
    fontWeight: 600,
    fontFamily: 'Inter,system-ui,sans-serif',
    cursor: 'pointer',
  },
};

// Export for browser CDN mode
// @ts-ignore
if (typeof window !== 'undefined') window.IdentityDashboard = IdentityDashboard;
