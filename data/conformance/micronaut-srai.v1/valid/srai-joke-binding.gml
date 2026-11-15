# Companion BINDING node for srai-joke-bigram-disambiguate.gml.
# Supplies bigram/trigram sense scores for joke × pitch × swing.
# sense_wordplay wins when the trigram context is "joke pitch swing".
# sense_joke wins when the trigram context is "joke pitch delivery".
# Neither above threshold → fallback: route:clarify_ambiguity.
binding [
  kind: bigram_trigram_score
  sense_classes: ["sense_joke", "sense_wordplay"]
  bigram_ref: "words.manifest:joke × pitch"
  trigram_ref: "words.manifest:joke × pitch × swing"
  argmax: "sense_wordplay"
  alternative: "sense_joke"
  provenance: required
  authority: proposal_only
]
