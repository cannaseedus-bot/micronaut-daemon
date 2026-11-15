/* khanary-chat.js — OpenAI-compatible streaming chat client.
   Wires to the NEXUS-CHAT / ASX kit DOM structure.
   Falls back to generic injection if the kit's elements aren't found. */

(function () {
  'use strict';

  const API =
    localStorage.getItem('khanary_completion_api') ||
    'http://127.0.0.1:17892/v1/chat/completions';
  const MODEL = 'local';
  const history = [];

  // ── DOM selectors — try kit-specific IDs, fall back to role/class heuristics ─
  function findInput() {
    return (
      document.getElementById('chat-input') ||
      document.querySelector('textarea[placeholder*="message" i]') ||
      document.querySelector('textarea') ||
      null
    );
  }

  function findSendBtn() {
    return (
      document.getElementById('send-btn') ||
      document.querySelector('button[type="submit"]') ||
      document.querySelector('button[aria-label*="send" i]') ||
      null
    );
  }

  function findThread() {
    return (
      document.getElementById('chat-thread') ||
      document.getElementById('messages') ||
      document.querySelector('.chat-thread,.messages,.thread') ||
      null
    );
  }

  // ── message renderer ─────────────────────────────────────────────────────────
  function appendMessage(role, text, streaming) {
    const thread = findThread();
    if (!thread) return null;

    const wrap = document.createElement('div');
    wrap.className = `kb-msg kb-msg-${role}`;
    wrap.style.cssText = `
      margin:10px 0;padding:10px 14px;border-radius:8px;max-width:85%;
      ${role === 'user'
        ? 'margin-left:auto;background:var(--accent,#16f2aa);color:#000;'
        : 'margin-right:auto;background:var(--asx-surface,#0f172a);color:var(--asx-color,#e2e8f0);border:1px solid rgba(255,255,255,.08);'}
      font-family:monospace;font-size:13px;line-height:1.5;white-space:pre-wrap;word-break:break-word;`;
    wrap.textContent = text;
    thread.appendChild(wrap);
    thread.scrollTop = thread.scrollHeight;
    return wrap;
  }

  // ── streaming fetch ──────────────────────────────────────────────────────────
  async function sendMessage(userText) {
    if (!userText.trim()) return;

    history.push({ role: 'user', content: userText });
    appendMessage('user', userText);

    const msgEl = appendMessage('assistant', '▋');

    let full = '';
    try {
      const resp = await fetch(API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: MODEL,
          messages: history.slice(-20),
          stream: true,
          max_tokens: 1024,
          temperature: 0.7,
        }),
      });

      if (!resp.ok) {
        const err = await resp.text();
        if (msgEl) msgEl.textContent = `[error ${resp.status}] ${err}`;
        return;
      }

      const ctype = (resp.headers.get('content-type') || '').toLowerCase();
      if (!ctype.includes('text/event-stream')) {
        const payload = await resp.json();
        full = payload?.choices?.[0]?.message?.content || '';
        if (msgEl) msgEl.textContent = full || '[empty completion]';
        history.push({ role: 'assistant', content: full || '' });
        return;
      }

      const reader = resp.body.getReader();
      const dec = new TextDecoder();

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const chunk = dec.decode(value, { stream: true });
        for (const line of chunk.split('\n')) {
          const s = line.trim();
          if (!s.startsWith('data:')) continue;
          const data = s.slice(5).trim();
          if (data === '[DONE]') break;
          try {
            const delta = JSON.parse(data).choices?.[0]?.delta?.content;
            if (delta) {
              full += delta;
              if (msgEl) msgEl.textContent = full + '▋';
            }
          } catch { /* ignore partial JSON */ }
        }
      }

      if (msgEl) msgEl.textContent = full;
      history.push({ role: 'assistant', content: full });

    } catch (err) {
      if (msgEl) msgEl.textContent = `[network error] ${err.message}`;
    }
  }

  // ── inject minimal chat shell if no thread container found ───────────────────
  function injectFallbackShell() {
    if (document.getElementById('kb-chat-shell')) return;

    const shell = document.createElement('div');
    shell.id = 'kb-chat-shell';
    shell.style.cssText = `
      position:fixed;bottom:70px;right:20px;width:380px;height:520px;
      background:var(--asx-surface,#0f172a);
      border:1px solid var(--accent,#16f2aa);border-radius:10px;
      display:flex;flex-direction:column;z-index:9997;
      box-shadow:0 8px 32px rgba(0,0,0,.7);`;

    shell.innerHTML = `
      <div style="padding:10px 14px;border-bottom:1px solid rgba(255,255,255,.1);
        display:flex;justify-content:space-between;align-items:center;">
        <span style="color:var(--accent,#16f2aa);font-family:monospace;font-size:13px;font-weight:bold;">
          KHANARY Chat</span>
        <button id="kb-chat-close" style="background:none;border:none;
          color:var(--asx-color,#e2e8f0);cursor:pointer;font-size:16px;">&times;</button>
      </div>
      <div id="chat-thread" style="flex:1;overflow-y:auto;padding:12px;
        display:flex;flex-direction:column;"></div>
      <div style="padding:10px;border-top:1px solid rgba(255,255,255,.1);display:flex;gap:8px;">
        <textarea id="chat-input" rows="2" placeholder="Ask anything..."
          style="flex:1;background:var(--bg,#020617);border:1px solid rgba(255,255,255,.2);
            color:var(--asx-color,#e2e8f0);border-radius:6px;padding:8px;
            font-family:monospace;font-size:12px;resize:none;"></textarea>
        <button id="send-btn" style="padding:8px 14px;
          background:var(--accent,#16f2aa);color:#000;font-weight:bold;
          border:none;border-radius:6px;cursor:pointer;align-self:flex-end;">&#9658;</button>
      </div>`;

    document.body.appendChild(shell);
    document.getElementById('kb-chat-close')?.addEventListener('click', () => shell.remove());

    // chat button to toggle
    const chatBtn = document.createElement('button');
    chatBtn.style.cssText = `
      position:fixed;bottom:68px;right:70px;width:40px;height:40px;
      border-radius:50%;background:var(--accent,#16f2aa);color:#000;
      font-size:18px;border:none;cursor:pointer;z-index:9998;
      box-shadow:0 2px 12px rgba(0,0,0,.5);`;
    chatBtn.innerHTML = '&#x1F4AC;';
    chatBtn.title = 'Chat with KHANARY';
    chatBtn.addEventListener('click', () => {
      shell.style.display = shell.style.display === 'none' ? 'flex' : 'none';
    });
    document.body.appendChild(chatBtn);
  }

  // ── wire send button + Enter key ─────────────────────────────────────────────
  function wireControls() {
    const input = findInput();
    const btn   = findSendBtn();

    if (btn) {
      btn.addEventListener('click', () => {
        const val = input?.value || '';
        if (input) input.value = '';
        sendMessage(val);
      });
    }

    if (input) {
      input.addEventListener('keydown', e => {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          const val = input.value;
          input.value = '';
          sendMessage(val);
        }
      });
    }
  }

  // ── init ─────────────────────────────────────────────────────────────────────
  function init() {
    const thread = findThread();
    if (!thread) injectFallbackShell();
    wireControls();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
