# concept-relative-fold.v1 — operator plan for per-concept accumulation
# Schema: ccc4.operator-plan.v1
# Shows allocate as a named operator (not a side-effect), fold.per and compose as
# distinct steps, and reduce.per / xul.compose as the split that prevents silent drops.
plan [
  id: "concept-relative-fold.v1"
  schema: "ccc4.operator-plan.v1"

  operators: [
    {id: "yax.segment",           kind: SEGMENT,     out: ["concept.fields"]},
    {id: "yax.allocate",          kind: ALLOCATE,    in: ["concept.fields"],           out: ["concept.accumulators"]},
    {id: "yax.retrieve",          kind: RETRIEVE,    in: ["concept.fields"],           out: ["semantic.neighborhoods"]},
    {id: "sek.score",             kind: SCORE,       in: ["gram.activations", "concept.fields"], out: ["concept.scores"]},
    {id: "sek.fold.per",          kind: FOLD_PER,    in: ["concept.scores", "semantic.neighborhoods"], out: ["concept.accumulators"],
                                                     children: ["sek.accumulate.evidence", "sek.accumulate.senses", "sek.accumulate.shared"]},
    {id: "sek.accumulate.evidence", kind: ACCUMULATE, accumulator_shape: ["concept", "evidence"]},
    {id: "sek.accumulate.senses",   kind: ACCUMULATE, accumulator_shape: ["concept", "sense_distribution"]},
    {id: "sek.accumulate.shared",   kind: ACCUMULATE, accumulator_shape: ["concept", "reference"]},
    {id: "sek.compose",           kind: COMPOSE,     in: ["concept.accumulators"],     out: ["prompt.fold"]},
    {id: "sek.reduce.per",        kind: REDUCE_PER,  in: ["concept.accumulators"],     out: ["concept.outputs"]},
    {id: "chen.verify.per",       kind: VERIFY,      in: ["concept.outputs"],          out: ["concept.verified"]},
    {id: "xul.compose",           kind: COMPOSE,     in: ["concept.verified"],         out: ["prompt.output"]}
  ]

  containment: [
    {parent: "sek.fold.per", child: "sek.accumulate.evidence", role: "owns_accumulator"},
    {parent: "sek.fold.per", child: "sek.accumulate.senses",   role: "owns_accumulator"},
    {parent: "sek.fold.per", child: "sek.accumulate.shared",   role: "owns_accumulator"}
  ]

  data_flow: [
    {source: "yax.segment",    output_port: "concept.fields",          target: "yax.allocate",    input_port: "in"},
    {source: "yax.allocate",   output_port: "concept.accumulators",    target: "sek.fold.per",    input_port: "in"},
    {source: "yax.retrieve",   output_port: "semantic.neighborhoods",  target: "sek.fold.per",    input_port: "in"},
    {source: "sek.fold.per",   output_port: "concept.accumulators",    target: "sek.compose",     input_port: "in"},
    {source: "sek.fold.per",   output_port: "concept.accumulators",    target: "sek.reduce.per",  input_port: "in"},
    {source: "sek.reduce.per", output_port: "concept.outputs",         target: "chen.verify.per", input_port: "in"},
    {source: "chen.verify.per",output_port: "concept.verified",        target: "xul.compose",     input_port: "in"}
  ]

  execution_dependencies: [
    {before: "yax.allocate",    after: "yax.retrieve"},
    {before: "yax.retrieve",    after: "sek.score"},
    {before: "sek.score",       after: "sek.fold.per"},
    {before: "sek.fold.per",    after: "sek.compose"},
    {before: "sek.compose",     after: "sek.reduce.per"},
    {before: "sek.reduce.per",  after: "chen.verify.per"},
    {before: "chen.verify.per", after: "xul.compose"}
  ]
]
