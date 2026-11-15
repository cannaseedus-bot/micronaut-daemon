"""Cross-layer invariants for the key grammar and track suite; no native execution."""
import importlib.util
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parent

def load_module(name):
    spec=importlib.util.spec_from_file_location(name, ROOT/(name+'.py'))
    mod=importlib.util.module_from_spec(spec)
    import sys
    sys.modules[name]=mod
    spec.loader.exec_module(mod)
    return mod

class GrammarBridgeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.graph=load_module('build_key_relation_graph')
        cls.ngram=load_module('check_ngram_key_grammar')

    def test_no_fuzzy_semantic_promotion(self):
        g=self.graph.KeyRelationGraph()
        g.node('BANK:RIVER_EDGE')
        r=g.query('bank')
        self.assertFalse(r['found'])
        self.assertTrue(r['candidates'])

    def test_exact_sense_identity(self):
        g=self.graph.KeyRelationGraph()
        g.node('bank:blood_repository')
        g.node('bank:financial_institution')
        self.assertEqual(g.query('bank:blood_repository')['focus']['id'],'BANK:BLOOD_REPOSITORY')

    def test_zero_relation_weight_preserved(self):
        g=self.graph.KeyRelationGraph()
        g.ingest_row({'from':'A','to':'B','relation':'@supports','weight':0,'confidence':0},'test.jsonl','definition_relations')
        e=next(iter(g.edges.values()))
        self.assertEqual(e.weight,0)
        self.assertEqual(e.confidence,0)

    def test_relation_directionality(self):
        g=self.graph.KeyRelationGraph()
        g.edge('A','B','@requires')
        self.assertEqual(len(g.outgoing['A']),1)
        self.assertEqual(len(g.outgoing['B']),0)

    def test_manifest_compact_by_default(self):
        g=self.graph.KeyRelationGraph()
        g.node('A')
        m=g.manifest()
        self.assertNotIn('nodes',m)
        self.assertIn('sample_nodes',m)

    def test_ngram_recognizer_cannot_claim_authority(self):
        contract={'@kind':'khanary.ngram_key_grammar.contract.v0.1','@no-eval':True,
                  'recognizer':{'algorithm':'aho_corasick','trie_goto':True,'failure_links':True,
                  'output_sets':True,'emits_overlapping_matches':True,'semantic_authority':True,
                  'collapse_authority':False,'complexity':'O(n+m+z)'}}
        self.assertEqual(self.ngram.validate(contract),'RECOGNIZER_SEMANTIC_AUTHORITY')

if __name__=='__main__': unittest.main()
