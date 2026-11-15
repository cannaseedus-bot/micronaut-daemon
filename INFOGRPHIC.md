# Infographic and Semantic Tracks

## Purpose

The repository can pair a grounded chat answer with a visual app. Facts and domain data remain in JSON; SVG is the editable illustration, and PNG is a convenient raster preview. App manifests and key-grammar rows bind those resources to the UI. For example, the Saturn explorer binds its system data, source notes, SVG map, and selectable moon view.

## K’UHUL Example

`data/facts/kuhul-runtime.json` records the repository’s definition of K’UHUL and its canonical six-phase sequence. The definition is consistent with `data/apps/kuhul-field.xaiml` and `data/alice/kuhul-runtime.aiml`, which supply question patterns and answer text. `data/apps/kuhul-explorer.html` adds a looping, selectable perspective orbit; its companion data, app manifest, and SVG provide the visual overview. `tools/render-kuhul-infographic.ps1` uses the local Powernaut `Kuhul3D.psm1` renderer to generate the PNG. Treat phase diagrams as explanations: phase labels, track scores, and declarations do not authorize host operations; runtime contracts and XCFE admission still govern execution.

## How Tracks Guide AIML

Semantic tracks are useful guidance for pattern recognition and routing. Their `governs`, `capabilities`, and conformance questions can suggest aliases, related concepts, or candidate intents. An AIML pattern can anchor the question's intent; the runtime can then compare related key and n-gram patterns, unfold relevant context, and rank candidates. Similarity helps retrieve context but does not establish truth. Tracks do not automatically become AIML categories, and an expected key is not answer evidence. Keep the steps separate:

1. Match the user’s wording to an AIML pattern or candidate intent.
2. Expand nearby key and n-gram patterns to find relevant context.
3. Rank the candidates, then ground factual claims in an admitted fact or source-backed record.
4. Bind an infographic app only when the question and response concern its topic.

Review the track files under `data/tracks/` alongside `data/apps/kuhul-field.xaiml` when extending coverage. Preserve provenance, confidence, and execution boundaries when adding aliases or patterns.

## Updating Assets

Edit structured content in JSON and the illustration in SVG; regenerate PNG with `tools/svg-to-png.ps1` when a renderer is installed. Keep text large enough to read at normal display scale, provide a scale or scope note where needed, and link the interactive app from the response card. Update key grammar bindings when adding or renaming an app so runtime discovery stays aligned with its manifest.
