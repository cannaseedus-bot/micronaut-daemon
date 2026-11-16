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

// ── Manifest data — asx-mini-app.key-grammar.jsonl ────────────────────────────

interface AsxComponent {
  id: string;
  role: string;
  type: string;
  phase: string;
  program?: string;
  event?: string;
  source?: string;
}

interface AsxApp {
  key: string;
  type: string;
  domain: string;
  components: AsxComponent[];
}

const ASX_APPS: Record<string, AsxApp> = {
  'SOCIALSPHERE':          { key: '⟁APP:SOCIALSPHERE',          type: 'app',                  domain: 'Social & Forum',    components: [{ id: 'HEADER', role: 'widget', type: 'toolbar', phase: 'Pop' }, { id: 'INPUT:SEARCH', role: 'input', type: 'search', phase: 'Wo', program: 'socialsphere.search', event: 'search.input' }, { id: 'FEED', role: 'widget', type: 'feed', phase: 'Pop' }, { id: 'POST', role: 'action', type: 'post-card', phase: 'Sek', program: 'socialsphere.like', event: 'post.like' }, { id: 'AUTH_MODAL', role: 'widget', type: 'modal', phase: 'Wo', program: 'socialsphere.auth_submit', event: 'auth.submit' }, { id: 'COMPOSE_MODAL', role: 'widget', type: 'modal', phase: 'Wo', program: 'socialsphere.post_submit', event: 'post.submit' }] },
  'SELF_HOSTED_FORUM':     { key: '⟁APP:SELF_HOSTED_FORUM',     type: 'app',                  domain: 'Social & Forum',    components: [{ id: 'HEADER', role: 'widget', type: 'toolbar', phase: 'Pop' }, { id: 'INPUT:SEARCH', role: 'input', type: 'search', phase: 'Wo', program: 'forum.search', event: 'search.input' }, { id: 'POSTS', role: 'widget', type: 'table', phase: 'Pop' }, { id: 'AUTH_MODAL', role: 'widget', type: 'modal', phase: 'Wo', program: 'forum.auth_submit', event: 'auth.submit' }, { id: 'POST_MODAL', role: 'widget', type: 'modal', phase: 'Wo', program: 'forum.post_submit', event: 'post.submit' }] },
  'SELF_HOSTED_FORUM_V2':  { key: '⟁APP:SELF_HOSTED_FORUM_V2',  type: 'self-hosted-forum',    domain: 'Social & Forum',    components: [{ id: 'SHF_TABLE', role: 'widget', type: 'forum-table', phase: 'Sek', program: 'forum.rows', event: 'rows.refresh' }, { id: 'SHF_AUTH', role: 'form', type: 'auth-modal', phase: 'Xul', program: 'forum.auth', event: 'auth.submit' }] },
  'COMMUNITY_FORUM':       { key: '⟁APP:COMMUNITY_FORUM',       type: 'feed-community',       domain: 'Social & Forum',    components: [{ id: 'FW_POST_GROUPS', role: 'widget', type: 'post-groups', phase: 'Sek' }, { id: 'FW_CREATE', role: 'form', type: 'topic-form', phase: 'Xul', program: 'forum.create_topic', event: 'topic.submit' }] },

  'SEED_STORE':            { key: '⟁APP:SEED_STORE',            type: 'commerce-app',         domain: 'Seed & Commerce',   components: [{ id: 'PRODUCT_GRID', role: 'widget', type: 'product-grid', phase: 'Pop', program: 'store.add_to_cart', event: 'product.add' }, { id: 'CART', role: 'widget', type: 'cart', phase: 'Wo', program: 'store.set_quantity', event: 'cart.quantity' }, { id: 'CHECKOUT', role: 'form', type: 'checkout-form', phase: 'Xul', program: 'store.submit_order', event: 'checkout.submit' }] },
  'SEEDBOT_HERO':          { key: '⟁APP:SEEDBOT_HERO',          type: 'hero-guide',           domain: 'Seed & Commerce',   components: [{ id: 'NAV:CAPABILITIES', role: 'navigation', type: 'tab-list', phase: 'Wo', program: 'seedbot.select_capability', event: 'capability.select' }, { id: 'DETAIL', role: 'widget', type: 'capability-card', phase: 'Pop' }] },
  'SEED_CHECKOUT':         { key: '⟁APP:SEED_CHECKOUT',         type: 'checkout',             domain: 'Seed & Commerce',   components: [{ id: 'CHECKOUT_FORM', role: 'form', type: 'checkout-form', phase: 'Xul', program: 'checkout.submit_order', event: 'checkout.submit' }] },
  'SEED_LANDING':          { key: '⟁APP:SEED_LANDING',          type: 'landing-page',         domain: 'Seed & Commerce',   components: [{ id: 'LANDING_GRID', role: 'widget', type: 'card-grid', phase: 'Pop' }] },
  'PLANT_GROWERS_BIBLE':   { key: '⟁APP:PLANT_GROWERS_BIBLE',   type: 'guide',                domain: 'Seed & Commerce',   components: [{ id: 'PLANT_CONTENT', role: 'widget', type: 'knowledge-panel', phase: 'Pop' }, { id: 'INPUT:PLANT_SEARCH', role: 'input', type: 'search', phase: 'Wo', program: 'plant.search', event: 'search.input' }, { id: 'plant.select_section', role: 'program', type: 'section', phase: 'Wo', event: 'section.select' }, { id: 'plant.toggle_panel', role: 'program', type: 'toggle', phase: 'Sek', event: 'panel.toggle' }] },
  'DAEMON_BOT':            { key: '⟁APP:DAEMON_BOT',            type: 'prompt-launcher',      domain: 'Seed & Commerce',   components: [{ id: 'DB_FORM', role: 'form', type: 'search-form', phase: 'Wo', program: 'daemon.submit', event: 'form.submit' }] },
  'MINI_SEEDBOT':          { key: '⟁APP:MINI_SEEDBOT',          type: 'prompt-launcher',      domain: 'Seed & Commerce',   components: [{ id: 'MSB_FORM', role: 'form', type: 'search-form', phase: 'Wo', program: 'mini.submit', event: 'form.submit' }] },

  'CLOUD_MODEL_CHAT':      { key: '⟁APP:CLOUD_MODEL_CHAT',      type: 'app',                  domain: 'Chat & AI',         components: [{ id: 'HEADER', role: 'widget', type: 'toolbar', phase: 'Pop' }, { id: 'SELECT:MODEL', role: 'input', type: 'select', phase: 'Wo', program: 'cloud.select_model', event: 'model.change' }, { id: 'MESSAGES', role: 'widget', type: 'chat-feed', phase: 'Pop' }, { id: 'INPUT', role: 'action', type: 'chat-input', phase: 'Sek', program: 'cloud.send', event: 'chat.send' }, { id: 'cloud.receive', role: 'program', type: 'receive', phase: "Ch'en", event: 'chat.receive' }] },
  'AI_UI_KIT':             { key: '⟁APP:AI_UI_KIT',             type: 'pattern-library',      domain: 'Chat & AI',         components: [{ id: 'AI_PATTERNS', role: 'widget', type: 'pattern-editor', phase: 'Wo', program: 'ai.select_pattern', event: 'pattern.select' }] },
  'BUY_YOUR_OWN_BOT':      { key: '⟁APP:BUY_YOUR_OWN_BOT',      type: 'configurator',         domain: 'Chat & AI',         components: [{ id: 'BOT_CONFIG', role: 'widget', type: 'pricing-configurator', phase: 'Wo' }, { id: 'BOT_CHECKOUT', role: 'form', type: 'checkout-form', phase: 'Xul', program: 'bot.submit_order', event: 'checkout.submit' }] },
  'TOKENS_VS_BOTS':        { key: '⟁APP:TOKENS_VS_BOTS',        type: 'cost-comparison',      domain: 'Chat & AI',         components: [{ id: 'TV_INPUTS', role: 'widget', type: 'usage-profile', phase: 'Wo' }, { id: 'TV_CHART', role: 'widget', type: 'line-chart', phase: 'Sek' }] },

  'GOOGLE_OAUTH_ADMIN':    { key: '⟁APP:GOOGLE_OAUTH_ADMIN',    type: 'oauth-admin-console',  domain: 'Admin & Integrations', components: [{ id: 'OAUTH_SETTINGS', role: 'form', type: 'settings-panel', phase: 'Xul', program: 'oauth.save_settings', event: 'settings.save' }] },
  'GOOGLE_OAUTH_CALLBACK': { key: '⟁APP:GOOGLE_OAUTH_CALLBACK', type: 'oauth-callback',       domain: 'Admin & Integrations', components: [{ id: 'OAUTH_RESULT', role: 'widget', type: 'callback-status', phase: 'Xul', program: 'oauth.exchange', event: 'callback.load' }] },
  'STRIPE_PAYMENTS_ADMIN': { key: '⟁APP:STRIPE_PAYMENTS_ADMIN', type: 'payments-admin-console', domain: 'Admin & Integrations', components: [{ id: 'STRIPE_SETTINGS', role: 'form', type: 'settings-panel', phase: 'Xul', program: 'stripe.save_settings', event: 'settings.save' }] },
  'STRIPE_PAYMENT_RETURN': { key: '⟁APP:STRIPE_PAYMENT_RETURN', type: 'payment-return',       domain: 'Admin & Integrations', components: [{ id: 'STRIPE_RESULT', role: 'widget', type: 'payment-status', phase: 'Xul', program: 'stripe.verify_return', event: 'return.load' }] },
  'GITHUB_CICD':           { key: '⟁APP:GITHUB_CICD',           type: 'cicd-console',         domain: 'Admin & Integrations', components: [{ id: 'GH_SETTINGS', role: 'form', type: 'repository-settings', phase: 'Xul', program: 'github.save_settings', event: 'settings.save' }, { id: 'ACTION:GH_DISPATCH', role: 'action', type: 'workflow-dispatch', phase: 'Sek', program: 'github.dispatch', event: 'dispatch.click' }] },
  'MAINTENANCE':           { key: '⟁APP:MAINTENANCE',           type: 'service-pricing',      domain: 'Admin & Integrations', components: [{ id: 'MW_PLANS', role: 'widget', type: 'plan-picker', phase: 'Wo', program: 'maintenance.select_plan', event: 'plan.select' }] },
  'MICRONAUT_GALLERY':     { key: '⟁APP:MICRONAUT_GALLERY',     type: 'catalog-cart',         domain: 'Admin & Integrations', components: [{ id: 'MG_GALLERY', role: 'widget', type: 'product-gallery', phase: 'Wo', program: 'gallery.add', event: 'gallery.add' }, { id: 'MG_CHECKOUT', role: 'form', type: 'checkout-form', phase: 'Xul', program: 'gallery.submit_order', event: 'checkout.submit' }] },
  'CDATA_MODAL':           { key: '⟁APP:CDATA_MODAL',           type: 'schema-modal',         domain: 'Admin & Integrations', components: [{ id: 'CDM_FORM', role: 'form', type: 'dynamic-form', phase: 'Xul', program: 'cdata.submit', event: 'form.submit' }] },
  'CDATA_DB':              { key: '⟁APP:CDATA_DB',              type: 'local-data-store',     domain: 'Admin & Integrations', components: [{ id: 'CDATA_ROWS', role: 'widget', type: 'row-list', phase: 'Sek', program: 'cdata.get_all', event: 'rows.refresh' }] },
  'CDATA_LOCAL_MODAL':     { key: '⟁APP:CDATA_LOCAL_MODAL',     type: 'local-schema-modal',   domain: 'Admin & Integrations', components: [{ id: 'CDLM_FORM', role: 'form', type: 'dynamic-form', phase: 'Xul', program: 'cdlm.save', event: 'form.submit' }] },

  'SATURN_SYSTEM_EXPLORER': { key: '⟁APP:SATURN_SYSTEM_EXPLORER', type: 'astronomy-infographic', domain: 'Visual & Science',   components: [{ id: 'BRAND_MARK', role: 'widget', type: 'svg-logo', phase: 'Pop', source: 'data/apps/saturn-system-mark.svg' }, { id: 'SYSTEM_MAP', role: 'widget', type: 'svg-system-map', phase: 'Yax', source: 'data/apps/saturn-system-infographic.svg' }, { id: 'MOON_DETAILS', role: 'widget', type: 'object-inspector', phase: 'Wo' }, { id: 'ATMOSPHERE_KEY', role: 'widget', type: 'filter-legend', phase: 'Wo' }, { id: 'ACTION:SELECT_OBJECT', role: 'action', type: 'selection', phase: 'Sek', program: 'saturn.select_object', event: 'object.select' }, { id: 'ACTION:ATMOSPHERE_FILTER', role: 'action', type: 'filter', phase: 'Sek', program: 'saturn.filter_atmosphere', event: 'atmosphere.filter' }] },
  'KUHUL_EXPLORER':        { key: '⟁APP:KUHUL_EXPLORER',        type: 'runtime-infographic',  domain: 'Visual & Science',   components: [{ id: 'PHASE_MAP', role: 'widget', type: 'svg-runtime-map', phase: 'Yax', source: 'data/apps/kuhul-infographic.svg' }, { id: 'ADMISSION_BOUNDARY', role: 'widget', type: 'execution-boundary', phase: "Ch'en" }, { id: 'TRACKS', role: 'widget', type: 'semantic-track-index', phase: 'Wo', source: 'data/tracks/' }] },
  'SCENE_CUBE':            { key: '⟁APP:SCENE_CUBE',            type: 'render-surface',       domain: 'Visual & Science',   components: [{ id: 'CUBE_CANVAS', role: 'widget', type: 'canvas-3d', phase: 'Pop', program: 'scene.render', event: 'scene.render' }] },

  'QUEST':                 { key: '⟁APP:QUEST',                 type: 'app',                  domain: 'Games',             components: [] },
  'ANIMAL_FARM':           { key: '⟁APP:ANIMAL_FARM',           type: 'app',                  domain: 'Games',             components: [{ id: 'WIDGET:ALGORITHM', role: 'widget', type: 'svg', phase: 'Yax', program: 'svg.field' }, { id: 'WIDGET:CHOICES', role: 'action', type: 'choice-list', phase: 'Sek', program: 'social.choose', event: 'choice.select' }] },
  'PIG_KINGDOM':           { key: '⟁APP:PIG_KINGDOM',           type: 'app',                  domain: 'Games',             components: [{ id: 'WIDGET:WITNESS', role: 'widget', type: 'companion-addon', phase: "Ch'en" }, { id: 'WIDGET:CHOICES', role: 'action', type: 'choice-list', phase: 'Sek', program: 'kingdom.choose', event: 'choice.select' }] },
  'WAR_PIGS':              { key: '⟁APP:WAR_PIGS',              type: 'app',                  domain: 'Games',             components: [{ id: 'WIDGET:WAR_MAP', role: 'widget', type: 'map', phase: 'Yax' }, { id: 'WIDGET:TRIBUNAL', role: 'action', type: 'choice-list', phase: 'Sek', program: 'war.choose', event: 'choice.select' }, { id: 'war.trace_contract', role: 'program', type: 'trace', phase: 'Yax' }, { id: 'war.verify_evidence', role: 'program', type: 'verify', phase: "Ch'en" }, { id: 'war.protect_civilians', role: 'program', type: 'protect', phase: 'Sek' }] },
};

const APP_DOMAINS = ['Social & Forum', 'Seed & Commerce', 'Chat & AI', 'Visual & Science', 'Admin & Integrations', 'Games'] as const;

const PHASE_COLOR: Record<string, string> = {
  'Pop': '#38bdf8', 'Wo': '#22f2b3', 'Yax': '#a855f7',
  "Sek": '#facc15', "Ch'en": '#fb7185', 'Xul': '#4ade80',
};

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

function parseMarker(text: string, tag: string): string | null {
  const m = text.match(new RegExp(`\\[kuhul:${tag}\\s+([^\\]]+)\\]`));
  if (!m) return null;
  const srcM = m[1].match(/src="([^"]+)"/);
  return srcM ? srcM[1] : null;
}

function cleanKuhul(text: string): string {
  return text.replace(/\[kuhul:[^\]]*\]|\[\/kuhul:[^\]]*\]/g, '').replace(/\s{3,}/g, '\n\n').trim();
}

function IdentityDashboard({ runtimePort = '9879' }: Props) {
  const [tab, setTab] = React.useState<Tab>('apps');
  const [runtimeStatus, setRuntimeStatus] = React.useState<'connecting' | 'live' | 'offline'>('connecting');
  const [identityText, setIdentityText] = React.useState<string>('');
  const [identityInfographic, setIdentityInfographic] = React.useState<string | null>(null);
  const [lightboxSrc, setLightboxSrc] = React.useState<string | null>(null);
  const [bubbleDismissed, setBubbleDismissed] = React.useState(false);

  React.useEffect(() => {
    if (!runtimePort) { setRuntimeStatus('offline'); return; }
    // Use same-origin proxy to avoid CORS (page served on 9882, proxy forwards to runtimePort)
    fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: 'WHO ARE YOU' }),
    })
      .then(r => r.json())
      .then((data: any) => {
        const text: string = data.response ?? data.text ?? JSON.stringify(data);
        // Parse [kuhul:powernaut infographic="..."] marker
        const pMatch = text.match(/\[kuhul:powernaut infographic="([^"]+)"\]/);
        if (pMatch) setIdentityInfographic(`/infographics/${pMatch[1]}.svg`);
        if (text.includes('[kuhul:dispatch')) setTab('apps');
        setIdentityText(text);
        setRuntimeStatus('live');
      })
      .catch(() => setRuntimeStatus('offline'));
  }, [runtimePort]);

  const statusColor = runtimeStatus === 'live' ? '#22f2b3' : runtimeStatus === 'offline' ? '#fb7185' : '#facc15';
  const statusLabel = runtimeStatus === 'live' ? `runtime live · port ${runtimePort}` : runtimeStatus === 'offline' ? 'runtime offline' : 'connecting…';

  const showBubble = !bubbleDismissed && identityInfographic && identityText;

  return (
    <div style={S.root}>
      <div style={S.header}>
        <div>
          <div style={S.brand}>AI-µ</div>
          <div style={S.subtitle}>Not who I am — what I can do.</div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          {identityInfographic && (
            <img src={identityInfographic} alt="AI-µ"
                 style={{ width: 36, height: 44, cursor: 'pointer', borderRadius: 4 }}
                 title="Click to view full identity"
                 onClick={() => setLightboxSrc(identityInfographic!)} />
          )}
          <div style={{ ...S.badge, color: statusColor, borderColor: statusColor }}>
            {statusLabel}
          </div>
        </div>
      </div>

      {showBubble && (
        <IdentityBubble
          src={identityInfographic!}
          text={cleanKuhul(identityText)}
          onEnlarge={() => setLightboxSrc(identityInfographic!)}
          onDashboard={() => setTab('apps')}
          onDismiss={() => setBubbleDismissed(true)}
        />
      )}

      <div style={S.tabs}>
        {TABS.map(t => (
          <button key={t.id} style={{ ...S.tab, ...(tab === t.id ? S.tabActive : {}) }}
            onClick={() => setTab(t.id)}>
            {t.label}
          </button>
        ))}
      </div>

      <div style={S.body}>
        {tab === 'apps'     && <AppsTab onEnlarge={setLightboxSrc} />}
        {tab === 'tools'    && <ToolsTab />}
        {tab === 'programs' && <ProgramsTab />}
        {tab === 'grammar'  && <GrammarTab />}
        {tab === 'traces'   && <TracesTab identityText={identityText} />}
        {tab === 'hosting'  && <HostingTab />}
      </div>

      {lightboxSrc && <Lightbox src={lightboxSrc} onClose={() => setLightboxSrc(null)} />}
    </div>
  );
}

// ── IdentityBubble — WHO ARE YOU response with animated character ─────────────

function IdentityBubble({ src, text, onEnlarge, onDashboard, onDismiss }: {
  src: string;
  text: string;
  onEnlarge: () => void;
  onDashboard: () => void;
  onDismiss: () => void;
}) {
  const [expanded, setExpanded] = React.useState(false);
  const preview = text.length > 320 ? text.substring(0, 320) + '…' : text;

  return (
    <div style={S.bubbleBar}>
      <img src={src} alt="AI-µ" style={S.bubbleChar}
           onClick={onEnlarge} title="Click to enlarge"/>
      <div style={S.bubbleSpeech}>
        <div style={S.bubbleText}>{expanded ? text : preview}</div>
        <div style={{ display: 'flex', gap: 7, marginTop: 10, flexWrap: 'wrap' as const }}>
          <button style={S.bubbleBtn} onClick={onEnlarge}>⤢ Enlarge</button>
          <button style={S.bubbleBtn} onClick={onDashboard}>Dashboard</button>
          {text.length > 320 && (
            <button style={S.bubbleBtn} onClick={() => setExpanded(!expanded)}>
              {expanded ? 'Collapse' : 'Full Response'}
            </button>
          )}
          <button style={{ ...S.bubbleBtn, marginLeft: 'auto' }} onClick={onDismiss}>✕</button>
        </div>
      </div>
    </div>
  );
}

// ── Lightbox ──────────────────────────────────────────────────────────────────

function Lightbox({ src, onClose }: { src: string; onClose: () => void }) {
  return (
    <div style={S.lightboxOverlay} onClick={onClose}>
      <div style={S.lightboxInner} onClick={(e: any) => e.stopPropagation()}>
        <button style={S.lightboxClose} onClick={onClose}>✕</button>
        <img src={src} alt="infographic" style={S.lightboxImg}/>
      </div>
    </div>
  );
}

// ── Apps tab ──────────────────────────────────────────────────────────────────

function AppsTab({ onEnlarge }: { onEnlarge: (src: string) => void }) {
  const [selectedDomain, setSelectedDomain] = React.useState<string>(APP_DOMAINS[0]);
  const [selectedId, setSelectedId] = React.useState<string | null>(null);
  const app = selectedId ? ASX_APPS[selectedId] : null;

  const domainApps = Object.entries(ASX_APPS).filter(([, v]) => v.domain === selectedDomain);

  return (
    <div style={S.appsLayout}>
      {/* Left: domain tabs + app list */}
      <div style={{ ...S.appList, width: 240 }}>
        <div style={S.sectionHead}>source: asx-mini-app.key-grammar.jsonl</div>
        <div style={{ display: 'flex', flexWrap: 'wrap' as const, gap: 4, marginBottom: 10, marginTop: 6 }}>
          {APP_DOMAINS.map(d => (
            <button key={d}
              style={{ ...S.appItem, padding: '3px 8px', fontSize: '0.72rem',
                       ...(selectedDomain === d ? { background: 'rgba(56,189,248,0.12)', color: '#38bdf8' } : {}) }}
              onClick={() => { setSelectedDomain(d); setSelectedId(null); }}>
              {d}
            </button>
          ))}
        </div>
        {domainApps.map(([id, a]) => (
          <button key={id}
            style={{ ...S.appItem, ...(selectedId === id ? S.appItemActive : {}) }}
            onClick={() => setSelectedId(id === selectedId ? null : id)}>
            <span style={{ color: '#38bdf8', fontSize: '0.78rem', fontFamily: 'ui-monospace,monospace' }}>{a.key}</span>
            <span style={{ color: '#6b7280', fontSize: '0.7rem', display: 'block', marginTop: 1 }}>{a.type}</span>
          </button>
        ))}
      </div>

      {/* Right: app detail */}
      <div style={S.appDetail}>
        {!app && (
          <div style={S.appPlaceholder}>
            <div style={{ color: '#22f2b3', fontSize: '1rem', fontWeight: 700 }}>key-app-builder</div>
            <div style={{ color: '#9ca3af', marginTop: 8 }}>
              Select a ⟁APP to see its component map.
            </div>
            <div style={{ color: '#6b7280', marginTop: 12, fontSize: '0.78rem', lineHeight: 1.6 }}>
              {Object.keys(ASX_APPS).length} apps registered<br/>
              source: asx-mini-app.key-grammar.jsonl<br/>
              authority: projection_only · executor: mx.run
            </div>
          </div>
        )}
        {app && (() => {
          const svgComp = app.components.find(c => c.source?.endsWith('.svg'));
          const svgUrl  = svgComp ? `/infographics/${svgComp.source!.split('/').pop()}` : null;
          return (
            <div>
              <div style={{ color: '#f9fafb', fontWeight: 700, fontFamily: 'ui-monospace,monospace', marginBottom: 4 }}>{app.key}</div>
              <div style={{ color: '#9ca3af', fontSize: '0.78rem', marginBottom: 12 }}>
                type: <span style={{ color: '#38bdf8' }}>{app.type}</span>
                {' · '}domain: <span style={{ color: '#a855f7' }}>{app.domain}</span>
                {' · '}phase: <span style={{ color: '#22f2b3' }}>Pop</span>
              </div>

              {/* SVG infographic panel (Saturn, Kuhul, etc.) */}
              {svgUrl && (
                <div style={S.infographicPanel}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                    <span style={S.sectionHead}>infographic</span>
                    <button style={S.bubbleBtn} onClick={() => onEnlarge(svgUrl)}>⤢ Enlarge</button>
                  </div>
                  <img
                    src={svgUrl} alt={`${app.key} infographic`}
                    style={{ width: '100%', maxHeight: 180, objectFit: 'contain', borderRadius: '0.5rem', cursor: 'pointer', display: 'block' }}
                    onClick={() => onEnlarge(svgUrl)}
                  />
                  {svgComp?.source && (
                    <div style={{ color: '#6b7280', fontSize: '0.7rem', marginTop: 4, fontFamily: 'ui-monospace,monospace' }}>
                      src: {svgComp.source}
                    </div>
                  )}
                </div>
              )}

              {app.components.length > 0 && (
                <>
                  <div style={S.sectionHead}>components ({app.components.length})</div>
                  <div style={{ marginTop: 6, display: 'flex', flexDirection: 'column' as const, gap: 6 }}>
                    {app.components.map(c => (
                      <div key={c.id} style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' as const }}>
                        <span style={{ color: PHASE_COLOR[c.phase] ?? '#9ca3af', fontFamily: 'ui-monospace,monospace', fontSize: '0.72rem', minWidth: 50 }}>{c.phase}</span>
                        <span style={{ color: '#38bdf8', fontFamily: 'ui-monospace,monospace', fontSize: '0.76rem' }}>{c.id}</span>
                        <span style={S.chip}>{c.type}</span>
                        <span style={{ color: '#6b7280', fontSize: '0.7rem' }}>{c.role}</span>
                        {c.program && <span style={{ color: '#6b7280', fontSize: '0.7rem', fontFamily: 'ui-monospace,monospace' }}>→ {c.program}</span>}
                        {c.source && <span style={{ color: '#6b7280', fontSize: '0.7rem', fontFamily: 'ui-monospace,monospace' }}>src: {c.source.split('/').pop()}</span>}
                      </div>
                    ))}
                  </div>
                </>
              )}

              <div style={{ marginTop: 14, color: '#6b7280', fontSize: '0.72rem', borderTop: '1px solid rgba(148,163,184,0.1)', paddingTop: 10 }}>
                authority: projection_only · semantic_authority: false · executor: mx.run · candidate_only: true
              </div>
            </div>
          );
        })()}
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
    color: '#22f2b3',
    border: '1px solid rgba(56,189,248,0.9)',
    borderRadius: '0.75rem',
    padding: '8px 14px',
    fontWeight: 600,
    fontFamily: 'Inter,system-ui,sans-serif',
    cursor: 'pointer',
  },
  // ── identity bubble bar ──
  bubbleBar: {
    display: 'flex',
    gap: 14,
    alignItems: 'flex-start',
    background: '#020b12',
    borderBottom: '1px solid rgba(34,242,179,0.18)',
    padding: '12px 20px',
  },
  bubbleChar: {
    width: 72,
    height: 92,
    flexShrink: 0,
    borderRadius: 6,
    cursor: 'pointer',
    border: '1px solid rgba(34,242,179,0.3)',
  },
  bubbleSpeech: {
    flex: 1,
    background: '#010b18',
    border: '1px solid rgba(34,242,179,0.25)',
    borderRadius: '0 0.75rem 0.75rem 0.75rem',
    padding: '10px 14px',
    position: 'relative' as const,
  },
  bubbleText: {
    color: '#c8dce8',
    fontSize: '0.82rem',
    lineHeight: 1.65,
    whiteSpace: 'pre-wrap' as const,
    fontFamily: 'ui-monospace,monospace',
  },
  bubbleBtn: {
    background: 'rgba(34,242,179,0.07)',
    color: '#22f2b3',
    border: '1px solid rgba(34,242,179,0.3)',
    borderRadius: '0.375rem',
    padding: '3px 10px',
    fontSize: '0.76rem',
    fontWeight: 600,
    cursor: 'pointer',
    fontFamily: 'Inter,system-ui,sans-serif',
  },
  // ── infographic panel in app detail ──
  infographicPanel: {
    background: '#010b14',
    border: '1px solid rgba(56,189,248,0.2)',
    borderRadius: '0.75rem',
    padding: 10,
    marginBottom: 14,
  },
  // ── lightbox ──
  lightboxOverlay: {
    position: 'fixed' as const,
    inset: 0,
    background: 'rgba(0,0,0,0.88)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 9999,
    backdropFilter: 'blur(4px)',
  },
  lightboxInner: {
    position: 'relative' as const,
    background: '#020b12',
    border: '1px solid rgba(34,242,179,0.35)',
    borderRadius: '1rem',
    padding: 20,
    maxWidth: '90vw',
    maxHeight: '90vh',
    overflow: 'auto',
    display: 'flex',
    flexDirection: 'column' as const,
    alignItems: 'center',
  },
  lightboxClose: {
    alignSelf: 'flex-end',
    background: 'rgba(34,242,179,0.07)',
    color: '#22f2b3',
    border: '1px solid rgba(34,242,179,0.3)',
    borderRadius: '50%',
    width: 30,
    height: 30,
    cursor: 'pointer',
    fontWeight: 700,
    fontSize: '1rem',
    marginBottom: 12,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  lightboxImg: {
    maxWidth: '80vw',
    maxHeight: '80vh',
    objectFit: 'contain' as const,
    borderRadius: '0.5rem',
  },
};

// Export for browser CDN mode
// @ts-ignore
if (typeof window !== 'undefined') window.IdentityDashboard = IdentityDashboard;
