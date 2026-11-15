/* khanary-brand.js — floating settings panel for any ASX kit.
   Injects a gear button that opens a drawer to customize brand tokens,
   title, logo, and template. Persists to localStorage.
   Works on all ASX kits because they share the same CSS var naming convention. */

(function () {
  'use strict';

  const STORE_KEY = 'khanary_brand';
  const REGISTRY_URL = '/khanary-registry.json'; // served alongside the WebUI

  // ── defaults ────────────────────────────────────────────────────────────────
  const DEFAULTS = {
    app_name:        document.title || 'KHANARY',
    logo_url:        '',
    brand_accent:    '#16f2aa',
    brand_secondary: '#38bdf8',
    brand_bg:        '#020617',
    brand_surface:   '#0f172a',
    brand_text:      '#e2e8f0',
    template:        '',
  };

  // ── storage ──────────────────────────────────────────────────────────────────
  function load() {
    try { return Object.assign({}, DEFAULTS, JSON.parse(localStorage.getItem(STORE_KEY) || '{}')); }
    catch { return Object.assign({}, DEFAULTS); }
  }
  function save(brand) {
    localStorage.setItem(STORE_KEY, JSON.stringify(brand));
  }

  // ── apply CSS vars ───────────────────────────────────────────────────────────
  function applyBrand(brand) {
    const r = document.documentElement.style;
    const set = (vars, val) => vars.forEach(v => r.setProperty(v, val));

    set(['--accent','--asx-primary','--atomic-border','--kuhul-color','--accent-teal','--alpha-green'], brand.brand_accent);
    set(['--asx-secondary','--accent-blue'], brand.brand_secondary);
    set(['--bg','--bg-primary','--asx-bg','--dark-pool'], brand.brand_bg);
    set(['--asx-surface'], brand.brand_surface);
    set(['--asx-color'], brand.brand_text);

    if (brand.app_name) {
      document.title = brand.app_name;
      document.querySelectorAll('h1,h2,[data-brand-title]').forEach((el, i) => {
        if (i === 0) el.textContent = brand.app_name;
      });
    }
    if (brand.logo_url) {
      let logo = document.getElementById('khanary-logo');
      if (!logo) {
        logo = document.createElement('img');
        logo.id = 'khanary-logo';
        logo.style.cssText = 'height:28px;object-fit:contain;position:fixed;top:10px;left:14px;z-index:9999;pointer-events:none;';
        document.body.appendChild(logo);
      }
      logo.src = brand.logo_url;
      logo.style.display = brand.logo_url ? '' : 'none';
    }
  }

  // ── template switcher ────────────────────────────────────────────────────────
  async function loadRegistry() {
    try {
      const r = await fetch(REGISTRY_URL);
      if (!r.ok) return [];
      const data = await r.json();
      return (data.kits || []).filter(k => k.source_type === 'html');
    } catch { return []; }
  }

  function switchTemplate(kitId) {
    window.location.href = '/khanary-kit-' + kitId + '.html';
  }

  // ── panel HTML ───────────────────────────────────────────────────────────────
  function buildPanel(brand, kits) {
    const opts = kits.map(k =>
      `<option value="${k.id}" ${k.id === brand.template ? 'selected' : ''}>${k.name}</option>`
    ).join('');

    return `
<div id="kb-panel" style="
  position:fixed;top:0;right:0;bottom:0;width:300px;
  background:var(--asx-surface,#0f172a);
  border-left:1px solid var(--accent,#16f2aa);
  display:flex;flex-direction:column;gap:0;
  font-family:monospace;font-size:13px;color:var(--asx-color,#e2e8f0);
  z-index:10000;box-shadow:-4px 0 24px rgba(0,0,0,.6);
  transform:translateX(0);transition:transform .2s;">
  <div style="padding:14px 16px;border-bottom:1px solid var(--accent,#16f2aa);
    display:flex;align-items:center;justify-content:space-between;">
    <span style="color:var(--accent,#16f2aa);font-weight:bold;">Brand Settings</span>
    <button id="kb-close" style="background:none;border:none;color:var(--asx-color,#e2e8f0);
      cursor:pointer;font-size:18px;line-height:1;">&times;</button>
  </div>
  <div style="padding:14px 16px;overflow-y:auto;flex:1;display:flex;flex-direction:column;gap:12px;">
    <label style="display:flex;flex-direction:column;gap:4px;">
      <span style="opacity:.7;">App title</span>
      <input id="kb-name" value="${brand.app_name}" style="
        background:var(--bg,#020617);border:1px solid var(--accent,#16f2aa);
        color:var(--asx-color,#e2e8f0);padding:6px 8px;border-radius:4px;font:inherit;">
    </label>
    <label style="display:flex;flex-direction:column;gap:4px;">
      <span style="opacity:.7;">Logo URL</span>
      <input id="kb-logo" value="${brand.logo_url}" placeholder="https://..." style="
        background:var(--bg,#020617);border:1px solid rgba(255,255,255,.15);
        color:var(--asx-color,#e2e8f0);padding:6px 8px;border-radius:4px;font:inherit;">
    </label>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
      <label style="display:flex;flex-direction:column;gap:4px;">
        <span style="opacity:.7;">Accent</span>
        <div style="display:flex;align-items:center;gap:6px;">
          <input type="color" id="kb-accent" value="${brand.brand_accent}" style="width:32px;height:28px;border:none;background:none;cursor:pointer;">
          <input id="kb-accent-hex" value="${brand.brand_accent}" style="flex:1;
            background:var(--bg,#020617);border:1px solid rgba(255,255,255,.15);
            color:var(--asx-color,#e2e8f0);padding:4px 6px;border-radius:4px;font:inherit;font-size:11px;">
        </div>
      </label>
      <label style="display:flex;flex-direction:column;gap:4px;">
        <span style="opacity:.7;">Secondary</span>
        <div style="display:flex;align-items:center;gap:6px;">
          <input type="color" id="kb-secondary" value="${brand.brand_secondary}" style="width:32px;height:28px;border:none;background:none;cursor:pointer;">
          <input id="kb-secondary-hex" value="${brand.brand_secondary}" style="flex:1;
            background:var(--bg,#020617);border:1px solid rgba(255,255,255,.15);
            color:var(--asx-color,#e2e8f0);padding:4px 6px;border-radius:4px;font:inherit;font-size:11px;">
        </div>
      </label>
    </div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
      <label style="display:flex;flex-direction:column;gap:4px;">
        <span style="opacity:.7;">Background</span>
        <div style="display:flex;align-items:center;gap:6px;">
          <input type="color" id="kb-bg" value="${brand.brand_bg}" style="width:32px;height:28px;border:none;background:none;cursor:pointer;">
          <input id="kb-bg-hex" value="${brand.brand_bg}" style="flex:1;
            background:var(--bg,#020617);border:1px solid rgba(255,255,255,.15);
            color:var(--asx-color,#e2e8f0);padding:4px 6px;border-radius:4px;font:inherit;font-size:11px;">
        </div>
      </label>
      <label style="display:flex;flex-direction:column;gap:4px;">
        <span style="opacity:.7;">Surface</span>
        <div style="display:flex;align-items:center;gap:6px;">
          <input type="color" id="kb-surface" value="${brand.brand_surface}" style="width:32px;height:28px;border:none;background:none;cursor:pointer;">
          <input id="kb-surface-hex" value="${brand.brand_surface}" style="flex:1;
            background:var(--bg,#020617);border:1px solid rgba(255,255,255,.15);
            color:var(--asx-color,#e2e8f0);padding:4px 6px;border-radius:4px;font:inherit;font-size:11px;">
        </div>
      </label>
    </div>
    ${kits.length ? `
    <label style="display:flex;flex-direction:column;gap:4px;">
      <span style="opacity:.7;">Switch template</span>
      <select id="kb-template" style="
        background:var(--bg,#020617);border:1px solid rgba(255,255,255,.15);
        color:var(--asx-color,#e2e8f0);padding:6px 8px;border-radius:4px;font:inherit;">
        <option value="">— keep current —</option>
        ${opts}
      </select>
    </label>` : ''}
  </div>
  <div style="padding:12px 16px;border-top:1px solid rgba(255,255,255,.1);display:flex;gap:8px;">
    <button id="kb-apply" style="flex:1;padding:8px;
      background:var(--accent,#16f2aa);color:#000;font-weight:bold;border:none;
      border-radius:4px;cursor:pointer;font:inherit;">Apply</button>
    <button id="kb-reset" style="padding:8px 14px;
      background:none;border:1px solid rgba(255,255,255,.2);
      color:var(--asx-color,#e2e8f0);border-radius:4px;cursor:pointer;font:inherit;">Reset</button>
  </div>
</div>`;
  }

  // ── gear button ──────────────────────────────────────────────────────────────
  function injectGear() {
    const btn = document.createElement('button');
    btn.id = 'kb-gear';
    btn.innerHTML = '&#9881;';
    btn.title = 'Brand settings';
    btn.style.cssText = `
      position:fixed;bottom:20px;right:20px;z-index:9998;
      width:40px;height:40px;border-radius:50%;
      background:var(--accent,#16f2aa);color:#000;
      font-size:18px;border:none;cursor:pointer;
      display:flex;align-items:center;justify-content:center;
      box-shadow:0 2px 12px rgba(0,0,0,.5);`;
    document.body.appendChild(btn);
    return btn;
  }

  // ── sync color picker ↔ hex input ────────────────────────────────────────────
  function syncPair(pickerId, hexId, onchange) {
    const picker = document.getElementById(pickerId);
    const hex    = document.getElementById(hexId);
    if (!picker || !hex) return;
    picker.addEventListener('input', () => { hex.value = picker.value; onchange(); });
    hex.addEventListener('input', () => {
      if (/^#[0-9a-fA-F]{6}$/.test(hex.value)) { picker.value = hex.value; onchange(); }
    });
  }

  // ── read current values from panel ──────────────────────────────────────────
  function readPanel() {
    return {
      app_name:        document.getElementById('kb-name')?.value        || '',
      logo_url:        document.getElementById('kb-logo')?.value        || '',
      brand_accent:    document.getElementById('kb-accent-hex')?.value  || '#16f2aa',
      brand_secondary: document.getElementById('kb-secondary-hex')?.value || '#38bdf8',
      brand_bg:        document.getElementById('kb-bg-hex')?.value      || '#020617',
      brand_surface:   document.getElementById('kb-surface-hex')?.value || '#0f172a',
      brand_text:      DEFAULTS.brand_text,
      template:        document.getElementById('kb-template')?.value    || '',
    };
  }

  // ── init ─────────────────────────────────────────────────────────────────────
  async function init() {
    const brand = load();
    applyBrand(brand);

    const gear  = injectGear();
    const kits  = await loadRegistry();
    let panel   = null;

    gear.addEventListener('click', () => {
      if (panel) { panel.remove(); panel = null; return; }
      const div = document.createElement('div');
      div.innerHTML = buildPanel(brand, kits);
      panel = div.firstElementChild;
      document.body.appendChild(panel);

      document.getElementById('kb-close')?.addEventListener('click', () => {
        panel.remove(); panel = null;
      });

      const preview = () => applyBrand(readPanel());
      syncPair('kb-accent',    'kb-accent-hex',    preview);
      syncPair('kb-secondary', 'kb-secondary-hex', preview);
      syncPair('kb-bg',        'kb-bg-hex',        preview);
      syncPair('kb-surface',   'kb-surface-hex',   preview);
      document.getElementById('kb-name')?.addEventListener('input', preview);
      document.getElementById('kb-logo')?.addEventListener('input', preview);

      document.getElementById('kb-apply')?.addEventListener('click', () => {
        const b = readPanel();
        save(b);
        applyBrand(b);
        if (b.template && b.template !== brand.template) switchTemplate(b.template);
        panel.remove(); panel = null;
      });

      document.getElementById('kb-reset')?.addEventListener('click', () => {
        localStorage.removeItem(STORE_KEY);
        location.reload();
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
