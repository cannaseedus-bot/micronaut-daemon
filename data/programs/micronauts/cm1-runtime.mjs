// CM-1 runtime: deterministic control-stream decoder and pi-tick processor.
// This module never renders control characters into result payloads.

const CONTROL = Object.freeze({ STX: 2, ETX: 3, EOT: 4, SO: 14, SI: 15, ESC: 27 });
const LGL = Object.freeze({
  '\u2000': 'loop.init', '\u2001': 'loop.alloc', '\u2002': 'loop.iterate',
  '\u2003': 'loop.iterate', '\u2004': 'loop.iterate', '\u2005': 'loop.iterate',
  '\u2006': 'loop.iterate', '\u2007': 'loop.numeric', '\u2008': 'loop.delimiter',
  '\u2009': 'loop.thin.iterate', '\u200A': 'loop.micro.iterate',
  '\u200B': 'loop.invisible.terminus'
});

export class LinearGeometricLoop {
  measure(stream) {
    let iterations = 0;
    let sawInit = false;
    let sawAlloc = false;
    const tokens = [];
    for (const character of stream) {
      const semantic = LGL[character];
      if (!semantic) continue;
      tokens.push({ codePoint: character.codePointAt(0).toString(16).toUpperCase(), semantic });
      if (character === '\u2000') sawInit = true;
      if (character === '\u2001') sawAlloc = true;
      if (semantic.endsWith('iterate')) iterations += 1;
    }
    if (iterations && !sawInit) throw new Error('CM-1 loop requires U+2000 initialization');
    return { iterations, initialized: sawInit, allocated: sawAlloc, tokens };
  }
}

export class PiTickEngine {
  constructor(clock = () => Date.now()) {
    this.pi = Math.PI;
    this.tickBase = 1 / (this.pi * 1000);
    this.clock = clock;
  }

  tick() { return (this.clock() * this.tickBase) % this.pi; }

  extractPiPhase(stream) {
    const marker = String.fromCodePoint(CONTROL.ESC) + 'π' + String.fromCodePoint(CONTROL.ESC);
    return stream.includes(marker) ? this.tick() : null;
  }

  synchronize(stream) { return this.extractPiPhase(stream); }
}

export class PiHarmonicClock {
  constructor(clock = () => Date.now()) { this.clock = clock; this.piSecond = 1000 / Math.PI; }
  now() {
    const unix = this.clock();
    return {
      unix,
      pi_unix: unix * Math.PI,
      pi_ticks: Math.floor((unix * Math.PI) / this.piSecond),
      pi_phase: (unix % this.piSecond) / this.piSecond,
      pi_cycle: Math.sin((unix / this.piSecond) * Math.PI)
    };
  }
  format() { const n = this.now(); return `${n.pi_ticks}.${Math.floor(n.pi_phase * 1000)}π`; }
}

export class PiOptimizedMath {
  add(a, b) { return a + b; }
  subtract(a, b) { return a - b; }
  multiply(a, b) { return a * b; }
  divide(a, b) { if (b === 0) throw new RangeError('CM-1 division by zero'); return a / b; }
  geometric_series(start, ratio, count) {
    if (!Number.isInteger(count) || count < 0) throw new RangeError('count must be non-negative integer');
    const result = []; let value = start;
    for (let i = 0; i < count; i++) { result.push(value); value *= ratio; }
    return result;
  }
  sin_pi(x) { return Math.sin(x * Math.PI); }
  cos_pi(x) { return Math.cos(x * Math.PI); }
  tan_pi(x) { return Math.tan(x * Math.PI); }
}

export class CM1Control {
  extract(stream) {
    const source = String(stream);
    return {
      source,
      starts: source.codePointAt(0) === CONTROL.STX,
      ends: source.codePointAt(source.length - 1) === CONTROL.ETX,
      has_execute: source.includes(String.fromCharCode(CONTROL.EOT)),
      context_depth: [...source].filter(c => c.charCodeAt(0) === CONTROL.SO).length -
        [...source].filter(c => c.charCodeAt(0) === CONTROL.SI).length
    };
  }
}

export class ControlMicronaut1 {
  constructor(clock = () => Date.now()) {
    this.cm1 = new CM1Control();
    this.lgl = new LinearGeometricLoop();
    this.pte = new PiTickEngine(clock);
    this.clock = new PiHarmonicClock(clock);
    this.math = new PiOptimizedMath();
  }

  execute(source, body = ({ iteration, tick }) => ({ iteration, tick })) {
    const control = this.cm1.extract(source);
    const loop = this.lgl.measure(source);
    const synchronized = this.pte.synchronize(source);
    const results = [];
    for (let iteration = 0; iteration < loop.iterations; iteration++) {
      results.push(body({ iteration, tick: synchronized, clock: this.clock.now(), control }));
    }
    return { control, loop, pi_phase: synchronized, results, rendered: this.project(results) };
  }

  project(results) {
    return JSON.parse(JSON.stringify(results, (_key, value) =>
      typeof value === 'string' ? value.replace(/[\u0000-\u001F\u2000-\u200B]/g, '') : value));
  }
}

export { CONTROL, LGL };
