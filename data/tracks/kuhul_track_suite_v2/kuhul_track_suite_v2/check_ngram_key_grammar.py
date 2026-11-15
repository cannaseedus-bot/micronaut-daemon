#!/usr/bin/env python3
from __future__ import annotations
import copy, json
from pathlib import Path
import os
from typing import Any
ROOT=Path(os.environ.get("KUHUL_KIT_ROOT", Path(__file__).resolve().parents[1])).resolve()
FILES={
 'contract':ROOT/'data/grammar/ngram-key-grammar.contracts.json',
 'grammar':ROOT/'ngram-key-grammar.runtime-grammar.ebnf',
 'fixture':ROOT/'data/grammar/ngram_key_grammar.conformance.json',
 'keys':ROOT/'ngram-key-grammar.key-grammar.jsonl',
 'doc':ROOT/'docs/NGRAM_KEY_GRAMMAR.md',
 'readme':ROOT/'README.md'}

def j(p:Path)->Any: return json.loads(p.read_text(encoding='utf-8'))
def c(name,ok,detail=''): return {'name':name,'pass':bool(ok),'detail':detail}
def validate(o):
    if not isinstance(o,dict): return 'CONTRACT_NOT_OBJECT'
    if o.get('@kind')!='khanary.ngram_key_grammar.contract.v0.1' or o.get('@no-eval') is not True: return 'CONTRACT_HEADER_INVALID'
    r=o.get('recognizer')
    if not isinstance(r,dict) or r.get('algorithm')!='aho_corasick': return 'RECOGNIZER_INVALID'
    for k in ['trie_goto','failure_links','output_sets','emits_overlapping_matches']:
        if r.get(k) is not True: return 'RECOGNIZER_INCOMPLETE'
    if r.get('semantic_authority') is not False: return 'RECOGNIZER_SEMANTIC_AUTHORITY'
    if r.get('collapse_authority') is not False: return 'RECOGNIZER_COLLAPSE_AUTHORITY'
    if r.get('complexity')!='O(n+m+z)': return 'COMPLEXITY_BOUND_INVALID'
    expected=['TokenStream','AhoCorasickDictionaryScan','BagOfNgramKeys','ManifestNeighborhood_NM','GeometryNeighborhood_NI','WoYax_ActiveNeighborhood','Sek_FrontierCandidates','Chen_Verification','Xul_CollapseOrCommit']
    if o.get('pipeline')!=expected: return 'PIPELINE_INVALID'
    laws=o.get('laws',{})
    if 'Aho-Corasick finds keys' not in laws.get('recognition_boundary',''): return 'RECOGNITION_BOUNDARY_INVALID'
    if 'not semantic reasoning' not in laws.get('failure_link_boundary',''): return 'FAILURE_LINK_BOUNDARY_INVALID'
    if 'not identical to catamorphism' not in laws.get('kuhul_fold_container',''): return 'FOLD_CATA_CONFLATION'
    if 'orthogonal' not in laws.get('hof_orthogonality',''): return 'PHASE_HOF_CONFLATION'
    if 'not competing semantic engines' not in laws.get('non_competing_engines',''): return 'COMPETING_ENGINE_CONFLATION'
    if 'speed through n-gram dictionary matching' not in laws.get('speed_vs_computation',''): return 'KEY_GRAMMAR_SPEED_BOUNDARY_INVALID'
    if 'inference field' not in laws.get('inference_field_2d_surface',''): return 'INFERENCE_FIELD_2D_SURFACE_INVALID'
    bitlaw=o.get('foldgraph_2d_bit_pattern_law',{})
    if bitlaw.get('surface')!='inference_field': return 'FOLDGRAPH_2D_SURFACE_INVALID'
    if bitlaw.get('anamorphism')!='sliding_window_generation': return 'FOLDGRAPH_2D_ANA_INVALID'
    if bitlaw.get('pattern_layer')!='((window ^ pattern) & mask)': return 'FOLDGRAPH_2D_PATTERN_INVALID'
    if bitlaw.get('attention')!='popcount_score': return 'FOLDGRAPH_2D_ATTENTION_INVALID'
    if bitlaw.get('catamorphism')!='argmax_reduction': return 'FOLDGRAPH_2D_CATA_INVALID'
    for ex in o.get('phase_hof_examples',[]):
        if '=' in str(ex): return 'PHASE_HOF_CONFLATION'
    b=o.get('authority_boundary',{})
    for k in ['recognition_authority','semantic_authority','topology_authority','verification_authority','commit_authority']:
        if b.get(k) is not False: return 'AUTHORITY_BOUNDARY_INVALID'
    if b.get('xul_required_for_commit') is not True: return 'XUL_REQUIRED_FOR_COMMIT'
    return None

def patch(base,ops):
    obj=copy.deepcopy(base)
    for op in ops:
        parts=[p for p in op['path'].split('/') if p]
        tgt=obj
        for part in parts[:-1]: tgt=tgt[int(part)] if isinstance(tgt,list) else tgt[part]
        last=parts[-1]
        if isinstance(tgt,list): tgt.append(op['value']) if last=='-' else tgt.__setitem__(int(last),op['value'])
        else: tgt[last]=op['value']
    return obj

def main():
    cases=[]
    for name,path in FILES.items(): cases.append(c('file:'+name,path.exists(),str(path.relative_to(ROOT))))
    if not all(x['pass'] for x in cases):
        print(json.dumps({'@kind':'key_grammar_kit.ngram_key_grammar.verdict.v0.1','pass':False,'cases':cases},indent=2,ensure_ascii=False)); return 1
    contract=j(FILES['contract']); err=validate(contract); cases.append(c('canonical_contract',err is None,err or 'ok'))
    gt=FILES['grammar'].read_text(encoding='utf-8')
    for token in ['ngram_key_grammar','aho_corasick','failure_links','Bag of n-gram keys','higher_order']:
        cases.append(c('grammar_token:'+token, token in gt))
    rows=[json.loads(line) for line in FILES['keys'].read_text(encoding='utf-8').splitlines() if line.strip()]
    cases.append(c('key_rows',len(rows)>=8))
    cases.append(c('hof_row',any(r.get('key')=='HOF:PHASE:ORTHOGONAL' for r in rows)))
    cases.append(c('speed_boundary_row',any(r.get('key')=='NGRAM:KEY:BOUNDARY:FAST-RECOGNITION' for r in rows)))
    cases.append(c('foldgraph_2d_row',any(r.get('key')=='FOLDGRAPH:2D:BIT-PATTERN:LAW' for r in rows)))
    doc=FILES['doc'].read_text(encoding='utf-8').lower()
    for token in ['aho-corasick finds keys','semantic book','learned folds','phase and higher-order operation are orthogonal','not competing semantic engines','anaψ        = sliding window generation','pattern     = ((window ^ pattern) & mask)','attention   = popcount score','cataφ       = argmax reduction']:
        cases.append(c('doc_token:'+token, token in doc))
    fx=j(FILES['fixture'])
    ce=validate(j(ROOT/fx['canonical']['contract_ref']))
    cases.append(c('fixture:canonical',fx['canonical']['expect']=='PASS' and ce is None,ce or 'ok'))
    for neg in fx.get('negative_cases',[]):
        try:
            e=validate(patch(contract,neg.get('patch',[])))
        except (KeyError, IndexError, TypeError, ValueError) as exc:
            e='INVALID_PATCH:'+type(exc).__name__
        cases.append(c('fixture:'+neg.get('name','?'),neg.get('expect')=='FAIL' and e==neg.get('error'),e or 'ok'))
    ok=all(x['pass'] for x in cases)
    print(json.dumps({'@kind':'key_grammar_kit.ngram_key_grammar.verdict.v0.1','pass':ok,'cases':cases},indent=2,ensure_ascii=False))
    return 0 if ok else 1
if __name__=='__main__': raise SystemExit(main())
