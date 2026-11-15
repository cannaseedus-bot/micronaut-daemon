"""Reference K'UHUL bootstrap/track contract suite. No native VM calls."""
import json,re
from pathlib import Path

BASE=Path(__file__).parent/'data'
PHASES=('Pop','Wo','Yax','Sek',"Ch'en",'Xul')

def load(name):
    return json.loads((BASE/name).read_text(encoding='utf-8-sig'))

def compile_pattern(pattern):
    # AIML * is a capture, not an unrestricted regex program.
    chunks=pattern.split('*')
    expr='(.*?)'.join(re.escape(chunk).replace(r'\ ',r'\s+') for chunk in chunks)
    return re.compile(r'^\s*'+expr+r'\s*$',re.IGNORECASE)

def route(bootstrap, utterance):
    matches=[]
    for order,rule in enumerate(bootstrap['routes']):
        match=compile_pattern(rule['pattern']).fullmatch(utterance)
        if match:
            captures=[x.strip() for x in match.groups()]
            # More literal tokens beat broad fallback patterns; preserve source order on ties.
            specificity=len(rule['pattern'].replace('*','').split())
            matches.append((specificity,-order,rule,captures))
    if not matches:return None
    _,_,rule,captures=max(matches,key=lambda m:(m[0],m[1]))
    return {'track':bootstrap['track'],'pattern':rule['pattern'],
            'phase':rule['phase'],'next':rule['next'],
            'captures':captures,'expert':rule.get('expert'),
            'prefix':rule.get('prefix'),'frame':rule.get('frame')}

def validate_bootstrap(b):
    assert b['track'] and isinstance(b['routes'],list)
    assert b['card']['authority']=='none'
    for r in b['routes']:
        assert r['phase'] in PHASES and r['next'] in PHASES
        assert r['pattern'] and compile_pattern(r['pattern'])
    return True

def validate_joke_track(track):
    assert track['schema']=='semantic-tracks.v1'
    assert [r['phase'] for r in track['phase_route']]==list(PHASES)
    folds={f['id']:f for f in track['folds']}
    assert len(folds)==len(track['folds'])
    for f in folds.values():
        assert f['phases'] and set(f['phases'])<=set(PHASES)
    for a in track['aliases']:
        assert a['maps_to'] in folds and a['domain_selected'] is False
    assert 'Sek' in folds['frame:collapse']['phases']
    assert "Ch'en" in folds['frame:subverted']['phases']
    assert 'Sek' not in folds['frame:subverted']['phases']
    return True

def joke_reference_run(surface,semantic_key,answer,admit=None,verify=None,variant='resolved'):
    track=load('JOKE-u.semantic-tracks.v1.json')
    validate_joke_track(track)
    if variant not in ('resolved','subverted','failed'):raise ValueError('unknown variant')
    if not semantic_key:raise ValueError('semantic key required')
    alias=next((a for a in track['aliases'] if a['surface'].casefold()==surface.casefold()),None)
    selected='frame:subverted' if variant=='subverted' else 'frame:collapse'
    # A subverted frame is Ch'en-only. Never pretend it has a Sek executor.
    executor='frame:collapse'
    proposal={'track':track['id'],'fold':executor,'variant':variant,'semantic_key':semantic_key}
    trace=[{'phase':'Pop','frame':'frame:joke_setup'},
           {'phase':'Wo','surface':surface,'alias_frame':alias['maps_to'] if alias else None,
            'overlay':alias['overlay'] if alias else None,'domain_selected':False},
           {'phase':'Yax','selected':selected}]
    authorized=bool(admit(proposal)) if admit else False
    trace.append({'phase':'Sek','executor':executor,'admitted':authorized})
    if not authorized:return {'status':'DENIED','committed':False,'trace':trace}
    # Structural checks are not semantic verification. A separate callback must approve.
    structural=bool(answer.strip()) and variant!='failed'
    verified=bool(verify(proposal,answer)) if verify and structural else False
    trace.append({'phase':"Ch'en",'structural':structural,'externally_verified':verified,
                  'variant':variant})
    trace.append({'phase':'Xul','committed':verified})
    return {'status':'COMMITTED' if verified else 'UNVERIFIED',
            'committed':verified,'trace':trace,
            'output':{'semantic_key':semantic_key,'surface':answer} if verified else None}

def greeting_templates(phase,bindings):
    bank=load('greeting-bank.json')
    entry=next((g for g in bank['greetings'] if g['phase']==phase),None)
    if not entry:return []
    rendered=[]
    for template in entry['templates']:
        placeholders=re.findall(r'\{([^{}]+)\}',template)
        if any(p not in bindings or bindings[p] is None for p in placeholders):continue
        rendered.append(template.format_map(bindings))
    return rendered
