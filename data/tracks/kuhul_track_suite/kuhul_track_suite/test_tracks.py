import unittest
from track_suite import *

class TrackSuite(unittest.TestCase):
    def test_bootstrap_contracts(self):
        for name in ('joke-bootstrap.json','plan-bootstrap.json','advisor-bootstrap.json'):
            with self.subTest(name=name):self.assertTrue(validate_bootstrap(load(name)))
    def test_joke_track_contract(self):self.assertTrue(validate_joke_track(load('JOKE-u.semantic-tracks.v1.json')))
    def test_joke_wildcard(self):
        r=route(load('joke-bootstrap.json'),'TELL ME A JOKE ABOUT VAMPIRES')
        self.assertEqual(r['captures'],['VAMPIRES'])
        self.assertEqual(r['frame'],'humor_frame')
    def test_joke_delivery_route(self):
        r=route(load('joke-bootstrap.json'),'WIND UP PITCH SWING FAST')
        self.assertEqual(r['frame'],'delivery_frame')
    def test_plan_capture(self):
        r=route(load('plan-bootstrap.json'),'MAKE A PLAN FOR BUILDING THE RUNTIME')
        self.assertEqual(r['captures'],['BUILDING THE RUNTIME'])
        self.assertEqual(r['phase'],'Wo')
    def test_advisor_specific_beats_fallback(self):
        r=route(load('advisor-bootstrap.json'),'ADVISE RESEARCH FACT MISS')
        self.assertEqual(r['expert'],'WEB-RESEARCH-µ')
        self.assertEqual(r['pattern'],'ADVISE RESEARCH FACT MISS')
    def test_advisor_generic(self):
        r=route(load('advisor-bootstrap.json'),'I NEED HELP WITH GRAMMAR')
        self.assertEqual(r['expert'],'Coordinator')
    def test_unmatched(self):self.assertIsNone(route(load('plan-bootstrap.json'),'UNRELATED'))
    def test_denied_by_default(self):
        result=joke_reference_run('pitch','bank:blood_repository','Blood Bank')
        self.assertEqual(result['status'],'DENIED')
    def test_admitted_not_verified(self):
        result=joke_reference_run('pitch','bank:blood_repository','Blood Bank',admit=lambda p:True)
        self.assertEqual(result['status'],'UNVERIFIED')
    def test_verified_commit_with_callbacks(self):
        result=joke_reference_run('pitch','bank:blood_repository','Blood Bank',
                admit=lambda p:True,verify=lambda p,a:a=='Blood Bank')
        self.assertTrue(result['committed'])
        self.assertFalse(result['trace'][1]['domain_selected'])
        self.assertEqual([x['phase'] for x in result['trace']],list(PHASES))
    def test_subversion_not_sek_executor(self):
        result=joke_reference_run('swing','JOKE:SUBVERT','Anti-joke',variant='subverted',
                admit=lambda p:True,verify=lambda p,a:True)
        self.assertEqual(result['trace'][3]['executor'],'frame:collapse')
        self.assertEqual(result['trace'][2]['selected'],'frame:subverted')
    def test_failed_cannot_commit(self):
        result=joke_reference_run('pitch','JOKE:FAILED','text',variant='failed',
                admit=lambda p:True,verify=lambda p,a:True)
        self.assertFalse(result['committed'])
    def test_greeting_missing_learned_context(self):
        self.assertEqual(greeting_templates('Wo',{}),[])
    def test_greeting_canonical(self):
        self.assertTrue(greeting_templates('Pop',{}))
    def test_greeting_reactive(self):
        self.assertTrue(greeting_templates('Pop.reactive_mirror',{'Greeting':'Howdy','greeting':'howdy'}))

if __name__=='__main__':unittest.main(verbosity=2)
