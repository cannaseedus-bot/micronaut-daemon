# K'UHUL Micronaut Semantic Registry v1

`kuhul-micronaut-registry.json` is the full declarative registry document. Its JSON objects and arrays map directly to XPath 3.1 maps and arrays when parsed into the XPath data model. It includes ADVISOR-µ; `advisor-semantic-map.json` is the route map compiled from the authoritative `advisor-bootstrap.json` source.

For a runtime that has bound the document to `$registry`, lookups use ordinary XPath map/array semantics:

```xpath
$registry?micronauts("micronaut:ELIZA")?identity?name
$registry?micronauts("micronaut:ELIZA")?phase_bindings?Yax?descriptor_ref
$registry?micronauts("micronaut:ELIZA")?aiml?pattern
$registry?micronauts("micronaut:ELIZA")?cfpc?gap
$registry?micronauts("micronaut:ELIZA")?questions?1?key
$advisor?routes("advisor:route:001")?expert_ref
$advisor?routes($advisor?routing?route_order?1)?normalized_pattern
```

These expressions resolve descriptor values. They do not call Micronauts, follow SRAI redirects, execute listed operators, or perform admission.

## Shared contract, independent programs

Every Micronaut entry has a `program_contract` using `kuhul.micronaut-program/1`. The envelope is shared; its roles, source references, grammar or typed-contract references, entry points, typed input/query/output bindings, sandbox declaration, field relativity, and learning behavior are specific to that Micronaut. A program model may be EBNF, an AIML adapter, a typed runtime, a route-map compiler, or a declaration that has no implementation yet.

`interaction.direct_user_io` is false and host bindings are required: program streams and proposal outputs are not direct UI channels. A host or downstream consumer supplies query bindings and decides whether to present an output. Replay is optional and separately declared; evidence-only replay does not update learned state. Confidence or weight changes remain proposals until their own verification and authorized Xul commit.

`implementation.source_status`, `implementation.runtime_registration`, and `implementation.validation_status` are separate. Source presence does not establish runtime registration or conformance. `capabilities.registered` remains empty until the active runtime confirms registration, and XCFE admission remains per invocation.

The `sandbox` block declares the requested operational envelope; host policy enforces it. `field_relativity` bounds the semantic neighborhood a program may inspect and is independent of WCR's `R` score.

`micronaut:IMAGE-SAMPLER` is a forward-only LOD-estimation proposal. Its explicit `dx`/`dy` values describe the texture-coordinate footprint; they are not learned weights. The referenced contract estimates a bounded mip LOD and explicitly does not sample an image. No kernel source or runtime registration is currently declared.

Training is a separate extension. A differentiable sampler would need a backward contract for `dL/dUV` and `dL/dTexture`; discrete mip selection is discontinuous, so the contract must choose trilinear blending, stop-gradient, or a specified custom gradient. `GradientLane` (`target - prediction`) remains a learning signal and is not the image-space derivative lane. Any future learning proposal flows through the existing LearningLane verification and authorized commit gates.

## CODEX AST to CodeWASM generation

The registry's `code_generation_pipeline` records the intended handoff: CODEX compiles a request into `kuhul.ast/1`, then the CodeWASM generator emits a requested target format as `kuhul.generated-source/1`. `CodeWASM/parse.js` is a separate Tree-sitter source parser; it parses source text into a syntax tree and is not the AST-to-source generator. `CodeWASM/generator.js` consumes the normalized AST subset documented in its header and emits JavaScript, Python, C, or C++ proposals. It does not execute output. The CODEX AST compiler's concrete handoff remains marked unverified until its implementation emits that contract.

## Contract boundaries

- `identity.authority_claim`, `capabilities.declared`, `program_contract.role`, typed bindings, sandbox and field-relativity declarations, phase operator inventories, seed `default_weight` values, and XCFE requirements are descriptive claims or policy references.
- `capabilities.registered` is reserved for capabilities confirmed by an active runtime registration. In this checked-in declarative proposal, each list is empty and `registered_status` says that registration is unverified; consumers must not treat these entries as an active runtime snapshot.
- Eligibility must use registered capabilities and the MicronautPatterns `Eligible(µ, op)` contract. Cross-domain use also requires a Bridge.
- XCFE admission is per invocation and remains a separate runtime decision. No field in this document grants admission or execution authority.
- Learning updates remain proposals until verified and committed through the authorized Xul path. Seed `default_weight` values are not learned weights.

Validate the registry and Advisor route map against `data/schema/kuhul-micronaut-registry.v1.schema.json` and `data/schema/advisor-semantic-map.v1.schema.json`. The registry `content_digest` is SHA-256 over UTF-8 canonical JSON after removing `registry_contract.generated_at` and `registry_contract.content_digest`. The Advisor map digest omits only its `content_digest` field.
