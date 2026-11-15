# AIML/SRAI Micronaut examples

Status: **design examples supplied for the Gemma Bridge**. The `(⟁MICRONAUT⟁)` blocks, `@` verbs, and proposed bridge/track JSON mappings below describe an intended compiler contract. This repository has not yet demonstrated a compiler that accepts these exact blocks or emits that pair. Parsing and registration do not grant XCFE execution authority.

## Concept map

| AIML construct | Proposed Micronaut form | Required behavior |
| --- | --- | --- |
| `<category>` | `(⟁MICRONAUT⟁)` | Typed declaration with source identity |
| `<pattern>`, `<star/>` | `@pattern` | Normalized matcher and bounded wildcard capture |
| `<template>` | `@agent` | Response proposal; render only after verification |
| `<srai>`, `<sr/>` | `@call` | Bounded redirect, with `<sr/>` forwarding captured text |
| `<topic>`, `<topicstar/>` | `@topic` | Topic scope and capture |
| `<that>`, `<thatstar/>` | `@condition` | Match prior bot response and verify context binding |
| `<think>` | `@think` | Suppress rendered text while applying admitted internal effects |
| `<learn>` | `@learn` | Propose a category; separate commit required |
| `<set>`, `<get>` | `@remember`, `@recall` | Session predicate write/read under explicit effects |
| `<bot>` | `@identity` | Read bot properties |
| `<person>`, case tags | `@eval` | Deterministic text transform |
| `<condition>` | `@condition` | Ordered branch selection |
| `<random>` | `@decide` | Explicitly specified random selection policy |
| `<input/>` | `@agent` input | Original input binding |

The mapping is semantic, not a claim that the current compiler implements every tag. In particular, AIML `<think>` means hidden template output; it does not automatically perform model reasoning. `<random>` requires a random-choice contract; scoring options with `Math.random()` is an example proposal, not a deterministic rank policy.

## Source examples

### Basic category

```xml
<category><pattern>HELLO</pattern><template>Hello! How can I help?</template></category>
```

```kuhul
(⟁MICRONAUT⟁) HELLO-µ {
  @identity: { @name: "HELLO-µ", @role: "greeting", @category: "dialogue" }
  @pattern: "HELLO"
  @agent: (input) => "Hello! How can I help?"
}
```

### Bounded SRAI redirect and wildcard forwarding

```xml
<category><pattern>HELLO *</pattern><template><srai>HELLO</srai> <star/></template></category>
<category><pattern>WHAT IS *</pattern><template><sr/></template></category>
```

```kuhul
(⟁MICRONAUT⟁) HELLO-STAR-µ {
  @pattern: "HELLO *"
  @agent: (input, star) => {
    greeting = @call("HELLO-µ", "@agent", { input: "HELLO" })
    return greeting.result + " " + star
  }
}
```

`<sr/>` means redirect using the captured star text as new matcher input. It needs a route through the AIML matcher, not an assumed direct call to a named definition agent. Both forms require a depth bound, active-path cycle check, and an admitted target.

### Topic and prior-response context

```xml
<topic name="weather"><category><pattern>WHAT IS THE FORECAST</pattern>
<template>Here is the forecast.</template></category></topic>
<category><pattern>YES</pattern><that>DO YOU LIKE COFFEE</that>
<template>Great!</template></category>
```

```kuhul
(⟁MICRONAUT⟁) COFFEE-YES-µ {
  @topic: "conversation"
  @pattern: "YES"
  @condition: { that: "DO YOU LIKE COFFEE" }
  @agent: (input) => "Great!"
}
```

Context participates in candidate matching; Ch’en independently verifies the selected context before emission.

### Session predicates and branch selection

```xml
<category><pattern>MY NAME IS *</pattern>
<template><set name="name"><star/></set> Nice to meet you.</template></category>
<category><pattern>WHAT IS MY NAME</pattern>
<template>Your name is <get name="name"/>.</template></category>
```

```kuhul
(⟁MICRONAUT⟁) NAME-SET-µ {
  @pattern: "MY NAME IS *"
  @agent: (input, name) => {
    @remember("MEM-µ", { fact: { key: "name", value: name }, category: "user_variables" })
    return "Nice to meet you."
  }
}
```

`@remember` needs an admitted session-write effect. `<condition>` additionally needs an ordered branch contract; `<get>` is a read and does not grant write authority.

### Learning proposal

```xml
<category><pattern>LEARN * IS *</pattern><template>
<learn><category><pattern><star index="1"/></pattern>
<template><star index="2"/></template></category></learn>
I can propose that category.</template></category>
```

```kuhul
(⟁MICRONAUT⟁) LEARN-µ {
  @pattern: "LEARN * IS *"
  @agent: (input, term, definition) => {
    @learn("ORCH-µ", { pattern: term, response: definition, mode: "proposal_only" })
    return "I can propose that category."
  }
}
```

The proposal must pass grammar, source, and Ch’en checks before a separate versioned commit updates a rule bank. A proposal-only handler must not tell the user it has already learned the rule.

## Intended phase path

`Pop` binds identity and input → `Wo` normalizes and binds session context → `Yax` expands matcher and redirect candidates → `Sek` applies admitted ranking or dispatch → `Ch’en` verifies provenance, phase order, context, cycles, effects, and response form → `Xul` closes and emits an authorized result.

A redirect or proposed graph edge is not executable merely because it appears in the route graph. Micronaut registration, successful transpilation, vector proximity, and matching a wildcard remain separate from admission.

## Bridge and track output to specify

The proposed compiler should emit a versioned bridge/track JSON pair with explicit identity, normalized patterns, topic/that context, wildcard bindings, redirect targets, phase folds, effect declarations, and source provenance. Before implementation, define canonical encoding, depth and cycle limits, random-choice semantics, session-write authority, and Ch’en conformance tests. `GEMMA-BRIDGE.md` tracks these tasks.
