"""
gemma-distill.py — distill AIML patterns, daemon question templates, and MML contracts via Gemma

Queries the local model at http://127.0.0.1:1236 (or --endpoint) to generate:
  - AIML pattern/template pairs       → data/alice/khanary-distilled.aiml
  - Daemon discussion questions       → data/gram/codegen-distill.jsonl
  - Phase-tagged prompt templates     → data/micronaut/distilled-questions.json
  - Per-daemon/micronaut MML contracts → data/grammar/daemon-<name>.mml
                                         data/grammar/micronaut-<name>.mml

MML contracts follow the metric_graph.mml / vectors.mml pattern:
  content dictionary urn:kuhul:<name>:v1 with presentation + content MathML
  + text/plain annotations encoding the authority boundary for each daemon.

Usage:
    py -3 tools\\gemma-distill.py
    py -3 tools\\gemma-distill.py --mml-only
    py -3 tools\\gemma-distill.py --mml --mml-out-dir data\\grammar
    py -3 tools\\gemma-distill.py --count 5 --aiml-only
    py -3 tools\\gemma-distill.py --dry-run
    py -3 tools\\gemma-distill.py --endpoint http://127.0.0.1:1236
"""

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Iterator

if sys.platform == "win32":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

# ── Default Gemma endpoint ─────────────────────────────────────────────────────

DEFAULT_ENDPOINT = "http://127.0.0.1:17882"

# ── Topic seeds ───────────────────────────────────────────────────────────────

# Each topic drives a batch of Gemma queries.  The prompt templates below
# reference these names directly, so keep them short and lower-case.
DEFAULT_TOPICS = [
    "fold",
    "unfold",
    "phase",
    "xcfe",
    "micronaut",
    "daemon",
    "gravity",
    "kuhul",
    "pop",
    "wo",
    "yax",
    "sek",
    "chen",
    "xul",
    "track",
    "book",
    "gram",
    "entropy",
    "commit",
    "verify",
]

# K'UHUL phase → canonical epistemic character (used to bias question style)
PHASE_CHARACTER: dict[str, str] = {
    "pop":   "observational, seeding, long-context",
    "wo":    "planning, binding, state-assignment",
    "yax":   "exploratory, branching, candidate-expansion",
    "sek":   "decisive, execution, deterministic",
    "chen":  "verification, proof, structured comparison",
    "xul":   "collapse, commit, final emission",
}

# ── Daemon / micronaut registry ──────────────────────────────────────────────
# Each entry: name, phase, temperature, role (one-line), capabilities (CAN),
# and boundary (CANNOT).  These drive the MML contract generation.

DAEMON_REGISTRY: list[dict] = [
    # Phase fold drivers
    {"name": "pop",        "kind": "phase-driver",  "phase": "Pop",    "temp": 0.35, "role": "Observe, seed, long-context intake"},
    {"name": "wo",         "kind": "phase-driver",  "phase": "Wo",     "temp": 0.55, "role": "Plan, bind, assign state"},
    {"name": "yax",        "kind": "phase-driver",  "phase": "Yax",    "temp": 0.85, "role": "Explore, branch, expand candidates"},
    {"name": "sek",        "kind": "phase-driver",  "phase": "Sek",    "temp": 0.20, "role": "Execute, dispatch, deterministic"},
    {"name": "chen",       "kind": "phase-driver",  "phase": "Ch'en",  "temp": 0.45, "role": "Verify, prove, structured comparison"},
    {"name": "xul",        "kind": "phase-driver",  "phase": "Xul",    "temp": 0.65, "role": "Collapse, emit, commit result"},
    # Specialist LLM daemons
    {"name": "eliza",      "kind": "daemon",        "phase": "Pop",    "temp": 0.35, "role": "Reasoning operator daemon — 16 Pop+Sek operator pairs (CAUSE/CONTRAST/ANALOGY/DEDUCTION/INDUCTION/ABDUCTION/SYNTHESIS/DECOMPOSITION/REFRAME/CHALLENGE/SUPPORT/REDIRECT/QUESTION/COMPARE/PLAN/DIRECT); Rogerian reflection; intent elicitation"},
    {"name": "alice",      "kind": "daemon",        "phase": "Yax",    "temp": 0.70, "role": "Topic-domain knowledge daemon — AIML 1.0 corpus Q&A across 65 topic files (history, science, geography, humor, movies, music, food, sports, politics, religion, etc.); AIML_PATTERN_MATCH, CORPUS_EXPAND, DOMAIN_ROUTE"},
    {"name": "think",      "kind": "daemon",        "phase": "Wo",     "temp": 0.55, "role": "9-branch thinker: greeting/howto/explain/compare/command/reflect/debug/hypothesize/summarise"},
    {"name": "reason",     "kind": "daemon",        "phase": "Yax",    "temp": 0.70, "role": "Multi-step reasoning chain with contradiction check"},
    {"name": "expand",     "kind": "daemon",        "phase": "Yax",    "temp": 0.80, "role": "6-mode expansion: extrapolate/hypothesize/synthesize/elaborate/metaphor/analogy"},
    {"name": "coder",      "kind": "daemon",        "phase": "Sek",    "temp": 0.15, "role": "Code generation, low temperature"},
    {"name": "ts_coder",   "kind": "daemon",        "phase": "Sek",    "temp": 0.15, "role": "TypeScript/JS specialist"},
    {"name": "ast",        "kind": "daemon",        "phase": "Sek",    "temp": 0.00, "role": "Deterministic grammar → KastNode parse"},
    {"name": "tool",       "kind": "daemon",        "phase": "Sek",    "temp": 0.20, "role": "Tool selection and dispatch"},
    {"name": "memory",     "kind": "daemon",        "phase": "Pop",    "temp": 0.30, "role": "Long-context memory retrieval"},
    {"name": "librarian",  "kind": "daemon",        "phase": "Yax",    "temp": 0.60, "role": "Knowledge library across fiction/science/theory/tech/politics"},
    {"name": "sheogorath", "kind": "daemon",        "phase": "Xul",    "temp": 0.97, "role": "Entropy maximiser — generates high-divergence candidate states"},
    {"name": "jyggalag",   "kind": "daemon",        "phase": "Ch'en",  "temp": 0.00, "role": "Order enforcer — collapses candidates to a single surviving state"},
    {"name": "factory",    "kind": "daemon",        "phase": "Pop",    "temp": 0.70, "role": "Auto-factory — spawns and evolves new micronauts from capability gaps"},
    {"name": "evolution",  "kind": "daemon",        "phase": "Yax",    "temp": 1.00, "role": "High-entropy pattern discovery; produces candidate micronaut definitions"},
    {"name": "atomic",     "kind": "daemon",        "phase": "Sek",    "temp": 0.45, "role": "Event-sourced orchestrator: Fisher-Rao trust, BLAKE2b log, SLERP geodesic"},
]

MICRONAUT_REGISTRY: list[dict] = [
    {"name": "CODEGEN-KUHUL",   "kind": "micronaut", "domain": "kuhul",  "phase": "Sek", "temp": 0.15, "role": "K'UHUL phase/fold/XCFE operator code generation"},
    {"name": "CODEGEN-CPP",     "kind": "micronaut", "domain": "cpp",    "phase": "Sek", "temp": 0.15, "role": "C++/HLSL code generation for KHANARY native targets"},
    {"name": "CODEGEN-PY",      "kind": "micronaut", "domain": "py",     "phase": "Sek", "temp": 0.20, "role": "Python tooling and test harness generation"},
    {"name": "CODEGEN-JS",      "kind": "micronaut", "domain": "js",     "phase": "Sek", "temp": 0.25, "role": "JavaScript/TypeScript generation"},
    {"name": "CODEGEN-CSHARP",  "kind": "micronaut", "domain": "cs",     "phase": "Sek", "temp": 0.15, "role": "C# / .NET interop generation"},
    {"name": "CODEGEN-HTML",    "kind": "micronaut", "domain": "html",   "phase": "Xul", "temp": 0.30, "role": "HTML/template emission"},
    {"name": "CODEGEN-CSS",     "kind": "micronaut", "domain": "css",    "phase": "Xul", "temp": 0.25, "role": "CSS property and selector generation"},
    {"name": "CODEGEN-JSON",    "kind": "micronaut", "domain": "json",   "phase": "Wo",  "temp": 0.10, "role": "JSON manifest/contract/schema generation"},
    {"name": "CODEGEN-KHL",     "kind": "micronaut", "domain": "khl",    "phase": "Sek", "temp": 0.15, "role": "KHL host-language generation"},
    {"name": "CODEGEN-KLSL",    "kind": "micronaut", "domain": "klsl",   "phase": "Sek", "temp": 0.15, "role": "KLSL compiler/shader generation"},
]

# ── Prompt templates ──────────────────────────────────────────────────────────

def aiml_prompt(topic: str) -> str:
    return (
        f"You are helping build an AIML chatbot for the KHANARY K'UHUL runtime.\n"
        f"Topic: {topic}\n\n"
        f"Write exactly 3 AIML pattern/template pairs about '{topic}' in the K'UHUL "
        f"fold/phase/micronaut system.  Use short, natural English patterns a developer "
        f"might type.  Templates should be 1-2 sentences, technically accurate, and "
        f"never fabricate — prefer 'I can look that up' over a guess.\n\n"
        f"Format strictly as:\n"
        f"PATTERN: <text>\n"
        f"TEMPLATE: <text>\n\n"
        f"Output only the 3 pairs, nothing else."
    )


def question_prompt(topic: str, phase: str) -> str:
    char = PHASE_CHARACTER.get(phase, "neutral")
    return (
        f"You are the '{phase}' phase daemon in the KHANARY K'UHUL runtime "
        f"({char} posture).\n"
        f"Topic: {topic}\n\n"
        f"Generate 3 short questions you would ask another daemon about '{topic}' "
        f"from your phase's perspective.  Questions should drive the fold/unfold cycle "
        f"forward and reflect your phase's epistemic role.\n\n"
        f"Format strictly as:\n"
        f"Q: <question>\n\n"
        f"Output only the 3 questions, nothing else."
    )


def discussion_prompt(topic: str) -> str:
    return (
        f"You are the ELIZA metacognitive daemon in KHANARY.\n"
        f"Topic: {topic}\n\n"
        f"Write a 5-line structured daemon discussion template about '{topic}'.  "
        f"Each line must be one of: OBSERVE, COMPARE, QUESTION, PLAN, or VERIFY.  "
        f"Keep each line to ≤12 words.  Use K'UHUL vocabulary where natural.\n\n"
        f"Format strictly as:\n"
        f"OBSERVE: <text>\n"
        f"COMPARE: <text>\n"
        f"QUESTION: <text>\n"
        f"PLAN: <text>\n"
        f"VERIFY: <text>\n\n"
        f"Output only the 5 lines, nothing else."
    )


# ── Gemma client ──────────────────────────────────────────────────────────────

def _chat(endpoint: str, prompt: str, max_tokens: int = 256, temperature: float = 0.55) -> str:
    """POST to an OpenAI-compatible /v1/chat/completions endpoint."""
    import urllib.request
    payload = json.dumps({
        "model": "gemma",
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "temperature": temperature,
        "stream": False,
    }).encode("utf-8")
    url = endpoint.rstrip("/") + "/v1/chat/completions"
    req = urllib.request.Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read())
            return data["choices"][0]["message"]["content"].strip()
    except Exception as exc:
        return f"ERROR: {exc}"


# ── Parsers ───────────────────────────────────────────────────────────────────

def parse_aiml_pairs(text: str) -> list[tuple[str, str]]:
    pairs: list[tuple[str, str]] = []
    pat_re = re.compile(r"PATTERN:\s*(.+)", re.I)
    tpl_re = re.compile(r"TEMPLATE:\s*(.+)", re.I)
    pats  = pat_re.findall(text)
    tmpls = tpl_re.findall(text)
    for p, t in zip(pats, tmpls):
        p = p.strip().rstrip(".")
        t = t.strip()
        if p and t:
            pairs.append((p.upper(), t))
    return pairs


def parse_questions(text: str, topic: str, phase: str) -> list[dict]:
    entries: list[dict] = []
    for line in text.splitlines():
        m = re.match(r"Q:\s*(.+)", line.strip(), re.I)
        if m:
            q = m.group(1).strip()
            if q:
                entries.append({
                    "key":      f"q_{phase}_{topic}_{len(entries)}",
                    "text":     q,
                    "surfaces": [q, topic, phase],
                    "phase":    phase.capitalize() if phase not in ("chen",) else "Ch'en",
                    "domain":   "daemon-question",
                    "micronaut": "ELIZA",
                    "source":   "gemma-distill",
                })
    return entries


def parse_discussion(text: str, topic: str) -> dict | None:
    roles = ["OBSERVE", "COMPARE", "QUESTION", "PLAN", "VERIFY"]
    result: dict[str, str] = {"topic": topic}
    for role in roles:
        m = re.search(rf"{role}:\s*(.+)", text, re.I)
        if m:
            result[role.lower()] = m.group(1).strip()
    if len(result) >= 4:
        return result
    return None


# ── AIML writer ───────────────────────────────────────────────────────────────

_AIML_HEADER = """\
<?xml version="1.0" encoding="UTF-8"?>
<aiml version="1.0.1"
      xmlns="http://alicebot.org/2001/AIML-1.0.1"
      xmlns:aiml="http://alicebot.org/2001/AIML-1.0.1">
<!-- Generated by tools/gemma-distill.py — K'UHUL daemon discussion patterns -->
"""

_AIML_FOOTER = "</aiml>\n"


def write_aiml(pairs: list[tuple[str, str]], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(_AIML_HEADER)
        seen: set[str] = set()
        for pattern, template in pairs:
            if pattern in seen:
                continue
            seen.add(pattern)
            # Escape XML special chars
            p = pattern.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            t = template.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            fh.write(f"\n  <category>\n    <pattern>{p}</pattern>\n    <template>{t}</template>\n  </category>\n")
        fh.write(_AIML_FOOTER)


# ── MML contract generation ───────────────────────────────────────────────────

def mml_contract_prompt(entry: dict) -> str:
    kind = entry["kind"]
    name = entry["name"]
    phase = entry["phase"]
    temp = entry["temp"]
    role = entry["role"]
    return (
        f"You are writing a MathML contract annotation for a K'UHUL {kind} named '{name}'.\n"
        f"Phase: {phase}  Temperature: {temp}  Role: {role}\n\n"
        f"Write exactly 4 short contract statements (1-2 sentences each) using this structure:\n"
        f"CAN: <what this daemon CAN do — its granted capability>\n"
        f"CANNOT: <hard boundary — what it must never do>\n"
        f"SUPPLIES: <what it outputs/provides to other daemons or XCFE>\n"
        f"BOUNDARY: <the authority it does NOT have — topology, commit, Ch'en verdict>\n\n"
        f"Use K'UHUL vocabulary (fold, phase, WCR, XCFE, Xul, Ch'en, track, gram) where natural.\n"
        f"Output only the 4 lines, nothing else."
    )


def _xml_escape(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def _phase_angle(phase: str) -> str:
    angles = {"Pop": "0", "Wo": "&#x03C0;/3", "Yax": "2&#x03C0;/3",
              "Sek": "&#x03C0;", "Ch'en": "4&#x03C0;/3", "Xul": "5&#x03C0;/3"}
    return angles.get(phase, "?")


def parse_contract(text: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for key in ["CAN", "CANNOT", "SUPPLIES", "BOUNDARY"]:
        m = re.search(rf"^{key}:\s*(.+)", text, re.I | re.M)
        if m:
            result[key.lower()] = m.group(1).strip()
    return result


def build_mml(entry: dict, contract: dict[str, str]) -> str:
    name = entry["name"]
    kind = entry["kind"]
    phase = entry["phase"]
    temp = entry["temp"]
    role = _xml_escape(entry["role"])
    cd = f"urn:kuhul:{kind}-{name}:v1"
    angle = _phase_angle(phase)

    can      = _xml_escape(contract.get("can",      "Operates within admitted track compartment."))
    cannot   = _xml_escape(contract.get("cannot",   "Cannot commit topology or claim Ch'en verdict."))
    supplies = _xml_escape(contract.get("supplies", "Provides output to XCFE routing layer."))
    boundary = _xml_escape(contract.get("boundary", "No topology mutation; no Xul commit authority."))

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<math xmlns="http://www.w3.org/1998/Math/MathML" display="block">

  <!--
    {kind}-{name}.mml

    {name.upper()}-µ contract:
      {can}
      {cannot}

    Content dictionary used here: {cd}
  -->

  <!-- ── Identity ──────────────────────────────────────────────────────────── -->
  <semantics>
    <mrow>
      <mi>{_xml_escape(name)}</mi>
      <mo>_</mo>
      <mi>&#x03BC;</mi>
      <mo>=</mo>
      <mo>&#x27E8;</mo>
      <mi>phase</mi><mo>,</mo>
      <mi>T</mi><mo>,</mo>
      <mi>role</mi>
      <mo>&#x27E9;</mo>
    </mrow>
    <annotation-xml encoding="MathML-Content">
      <apply>
        <eq/>
        <apply><csymbol cd="{cd}">Identity</csymbol><ci>{_xml_escape(name)}</ci></apply>
        <list>
          <cn>{phase}</cn>
          <cn>{temp}</cn>
          <ci>role</ci>
        </list>
      </apply>
    </annotation-xml>
    <annotation encoding="text/plain">
{name}_mu = &lt;phase={phase}, T={temp}, role&gt;
Role: {role}
Phase angle: theta = {angle}
    </annotation>
  </semantics>

  <mspace linebreak="newline" indentalign="center"/>

  <!-- ── Capability ────────────────────────────────────────────────────────── -->
  <semantics>
    <mrow>
      <mi>Cap</mi>
      <mo>(</mo><mi>{_xml_escape(name)}</mi><mo>)</mo>
      <mo>=</mo>
      <mi>GRANTED</mi>
    </mrow>
    <annotation-xml encoding="MathML-Content">
      <apply>
        <csymbol cd="{cd}">Capability</csymbol>
        <ci>{_xml_escape(name)}</ci>
        <ci>granted</ci>
      </apply>
    </annotation-xml>
    <annotation encoding="text/plain">
CAN: {can}
SUPPLIES: {supplies}
    </annotation>
  </semantics>

  <mspace linebreak="newline" indentalign="center"/>

  <!-- ── Authority boundary ────────────────────────────────────────────────── -->
  <semantics>
    <mrow>
      <mi>&#x0394;B</mi>
      <mo>&#x2209;</mo>
      <mi>Auth</mi>
      <mo>(</mo><mi>{_xml_escape(name)}</mi><mo>)</mo>
    </mrow>
    <annotation-xml encoding="MathML-Content">
      <apply>
        <csymbol cd="{cd}">AuthorityBoundary</csymbol>
        <apply><notin/><ci>DeltaTopology</ci><ci>Auth_{_xml_escape(name)}</ci></apply>
      </apply>
    </annotation-xml>
    <annotation encoding="text/plain">
CANNOT: {cannot}
BOUNDARY: {boundary}
Delta_B not-in Auth({name}): topology commits require Proposal -&gt; Ch'en -&gt; XCFE -&gt; Xul.
    </annotation>
  </semantics>

  <mspace linebreak="newline" indentalign="center"/>

  <!-- ── WCR scoring position ───────────────────────────────────────────────── -->
  <semantics>
    <mrow>
      <mi>S</mi>
      <mo>=</mo>
      <msub><mi>W</mi><mi>&#x03BC;</mi></msub>
      <mo>&#x22C5;</mo>
      <msub><mi>C</mi><mi>&#x03BC;</mi></msub>
      <mo>&#x22C5;</mo>
      <msub><mi>R</mi><mi>&#x03BC;</mi></msub>
      <mo>(</mo><mi>Q</mi><mo>)</mo>
    </mrow>
    <annotation-xml encoding="MathML-Content">
      <apply>
        <eq/>
        <ci>S</ci>
        <apply>
          <times/>
          <apply><selector/><ci>W</ci><ci>mu</ci></apply>
          <apply><selector/><ci>C</ci><ci>mu</ci></apply>
          <apply>
            <csymbol cd="{cd}">Relevance</csymbol>
            <ci>Q</ci>
          </apply>
        </apply>
      </apply>
    </annotation-xml>
    <annotation encoding="text/plain">
S = W_mu * C_mu * R_mu(Q)
W_mu: static weight for {name} in its capability family.
C_mu: confidence earned through Ch'en-verified outcomes.
R_mu(Q): query-relevance score at phase {phase} (T={temp}).
Eligibility: {name} is admitted to the candidate set only when requires(op) subset-of capabilities({name}).
    </annotation>
  </semantics>

</math>
"""


def write_mml(entry: dict, contract: dict[str, str], out_dir: Path) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    kind = entry["kind"]
    name = entry["name"]
    path = out_dir / f"{kind}-{name}.mml"
    path.write_text(build_mml(entry, contract), encoding="utf-8")
    return path


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> int:
    ap = argparse.ArgumentParser(
        description="Distill AIML patterns and daemon question templates via Gemma",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    ap.add_argument("--endpoint",  default=DEFAULT_ENDPOINT,
                    help=f"Gemma API base URL (default: {DEFAULT_ENDPOINT})")
    ap.add_argument("--topics",    nargs="+", default=DEFAULT_TOPICS,
                    metavar="TOPIC", help="Topics to generate patterns for")
    ap.add_argument("--count",     type=int, default=0,
                    help="Max topics to process (0 = all)")
    ap.add_argument("--phases",    nargs="+",
                    default=["pop", "wo", "yax", "sek", "chen", "xul"],
                    help="K'UHUL phases to generate daemon questions for")
    ap.add_argument("--aiml-only",      action="store_true")
    ap.add_argument("--questions-only", action="store_true")
    ap.add_argument("--mml-only",       action="store_true",
                    help="Generate only MML contracts, skip AIML/questions")
    ap.add_argument("--mml",            action="store_true",
                    help="Also generate MML contracts (implied by --mml-only)")
    ap.add_argument("--dry-run",        action="store_true",
                    help="Print prompts without calling Gemma")
    ap.add_argument("--aiml-out",    default="data/alice/khanary-distilled.aiml",
                    help="AIML output path")
    ap.add_argument("--distill-out", default="data/gram/codegen-distill.jsonl",
                    help="Daemon question JSONL output path")
    ap.add_argument("--discuss-out", default="data/micronaut/distilled-questions.json",
                    help="Structured discussion templates output path")
    ap.add_argument("--mml-out-dir", default="data/grammar",
                    help="Directory for generated .mml contract files (default: data/grammar)")
    args = ap.parse_args()

    topics = args.topics
    if args.count > 0:
        topics = topics[:args.count]

    do_mml       = args.mml or args.mml_only
    do_aiml      = not args.questions_only and not args.mml_only
    do_questions = not args.aiml_only      and not args.mml_only

    print(f"[distill] endpoint:  {args.endpoint}")
    print(f"[distill] topics:    {topics}")
    print(f"[distill] phases:    {args.phases}")
    print(f"[distill] aiml:      {do_aiml}   questions: {do_questions}   mml: {do_mml}")
    if args.dry_run:
        print("[distill] DRY RUN — printing first prompts only\n")
        print("── AIML prompt ──")
        print(aiml_prompt(topics[0]))
        if do_mml:
            print("\n── MML contract prompt ──")
            print(mml_contract_prompt(DAEMON_REGISTRY[0]))
        return 0

    # Verify endpoint reachable
    test = _chat(args.endpoint, "Reply with the single word: ready", max_tokens=8, temperature=0.0)
    if test.startswith("ERROR:"):
        print(f"[distill] ERROR: Gemma not reachable at {args.endpoint}: {test}")
        print("         Start Gemma first, or pass --endpoint <url>")
        return 1
    print(f"[distill] Gemma online: {test!r}\n")

    all_aiml_pairs:    list[tuple[str, str]] = []
    all_questions:     list[dict]            = []
    all_discussions:   list[dict]            = []

    t0 = time.time()

    for i, topic in enumerate(topics):
        print(f"[{i+1}/{len(topics)}] {topic}")

        # ── AIML patterns ──
        if do_aiml:
            raw = _chat(args.endpoint, aiml_prompt(topic), max_tokens=300, temperature=0.60)
            pairs = parse_aiml_pairs(raw)
            all_aiml_pairs.extend(pairs)
            print(f"  aiml:     {len(pairs)} pairs")

        # ── Daemon discussion template ──
        if do_questions:
            raw = _chat(args.endpoint, discussion_prompt(topic), max_tokens=200, temperature=0.55)
            disc = parse_discussion(raw, topic)
            if disc:
                all_discussions.append(disc)

        # ── Phase-tagged questions (one batch per phase for this topic) ──
        if do_questions:
            for phase in args.phases:
                raw = _chat(args.endpoint, question_prompt(topic, phase),
                            max_tokens=200, temperature=0.65)
                qs = parse_questions(raw, topic, phase)
                all_questions.extend(qs)
            print(f"  questions: {sum(1 for q in all_questions if q['text'].find(topic) >= 0 or True)}")

    elapsed = time.time() - t0
    print(f"\n[distill] {elapsed:.1f}s — "
          f"{len(all_aiml_pairs)} aiml pairs, "
          f"{len(all_questions)} questions, "
          f"{len(all_discussions)} discussion templates")

    # ── Write AIML ──
    if do_aiml and all_aiml_pairs:
        aiml_path = Path(args.aiml_out)
        write_aiml(all_aiml_pairs, aiml_path)
        mb = aiml_path.stat().st_size / 1024 / 1024
        print(f"[distill] wrote {aiml_path}  ({mb:.2f} MB, {len(all_aiml_pairs)} categories)")

    # ── Write question JSONL ──
    if do_questions and all_questions:
        q_path = Path(args.distill_out)
        q_path.parent.mkdir(parents=True, exist_ok=True)
        with open(q_path, "w", encoding="utf-8") as fh:
            for entry in all_questions:
                fh.write(json.dumps(entry, ensure_ascii=False) + "\n")
        mb = q_path.stat().st_size / 1024 / 1024
        print(f"[distill] wrote {q_path}  ({mb:.2f} MB, {len(all_questions)} entries)")

    # ── Write discussion templates ──
    if do_questions and all_discussions:
        d_path = Path(args.discuss_out)
        d_path.parent.mkdir(parents=True, exist_ok=True)
        with open(d_path, "w", encoding="utf-8") as fh:
            json.dump(all_discussions, fh, indent=2, ensure_ascii=False)
        print(f"[distill] wrote {d_path}  ({len(all_discussions)} templates)")

    # ── MML contract generation ──
    if do_mml:
        mml_dir = Path(args.mml_out_dir)
        all_entries = DAEMON_REGISTRY + MICRONAUT_REGISTRY
        print(f"\n[distill] generating {len(all_entries)} MML contracts → {mml_dir}/")
        mml_written = 0
        for entry in all_entries:
            name = entry["name"]
            kind = entry["kind"]
            print(f"  {kind}-{name}.mml", end="  ", flush=True)
            raw = _chat(args.endpoint, mml_contract_prompt(entry),
                        max_tokens=200, temperature=0.45)
            contract = parse_contract(raw)
            if len(contract) < 2:
                # Fallback: use role as CAN, hard boundary as CANNOT
                contract.setdefault("can",      entry["role"])
                contract.setdefault("cannot",   "Cannot commit topology, claim Ch'en verdict, or mutate B.")
                contract.setdefault("supplies", "Output routed through XCFE to downstream daemons.")
                contract.setdefault("boundary", "No Xul commit authority; no non-loopback connections.")
            path = write_mml(entry, contract, mml_dir)
            print(f"✓  ({path.stat().st_size} bytes)")
            mml_written += 1
        print(f"[distill] wrote {mml_written} MML contract files to {mml_dir}/")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
