"""Check the complete optimized native animation and each exported game frame."""
from pathlib import Path
import json,math,hashlib
import numpy as np
from model_review_io import renderer
B=Path(__file__).resolve().parents[1]
load=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
M=load(B/'.workbuddy/deepsea_dual_optimized_binding.json');O=Path(M['review'])
bb=load(O/M['native_name']);r=renderer(O/M['native_name'])
assert len(bb['elements'])<=1000
water={e['uuid']:e for e in bb['elements'] if e['name'].startswith('连续水体_')}
meta={a['band']:a for a in load(O/'嵌边检查数据.json')};groups={g['uuid']:g for g in bb['groups']};owners={}
def walk(n):
    for c in n['children']:
        if isinstance(c,dict):walk(c)
        else:owners[c]=groups[n['uuid']]['name']
walk(bb['outliner'][0])
offset=np.array([7.775,2,7.895]);A=B/'sweetdream_rp/assets/deepseaecho/models/item';base=load(A/'liquid/base.json')
maxerr=0;count=0
for ai,(sub,n) in enumerate([('idle',96),('cast',48)]):
    for i in range(n):
        frame=load(A/'liquid'/sub/f'{i:02d}.json');moving=[(e,v) for e,v,_ in r['scene'](i*.05,ai) if e['uuid'] in water]
        assert len(moving)==len(frame['elements'])==88
        assert len(base['elements'])+len(moving)==998
        for (e,v),q in zip(moving,frame['elements']):
            lo=v.min(0);hi=v.max(0);a=meta[owners[e['uuid']]]
            assert lo[2]>=a['z_min']-1e-7 and hi[2]<=a['z_max']+1e-7
            sign=-int(e['name'].split('_')[1]);anchor=lo[0] if sign>0 else hi[0]
            assert abs(anchor-a['edge_anchor'])<1e-7
            assert q['faces']['north']['texture']==q['faces']['south']['texture']=='#3'
            maxerr=max(maxerr,float(np.max(np.abs(lo+offset-q['from']))),float(np.max(np.abs(hi+offset-q['to']))));count+=1
        for sign in [-1,1]:
            ordered=sorted([e for e,_ in moving if int(e['name'].split('_')[1])==sign],key=lambda e:e['from'][1])
            assert all(a['to'][1]>b['from'][1] for a,b in zip(ordered,ordered[1:]))
assert maxerr<=.00000051
for a in bb['animations']:
    for bone in a['animators'].values():
        k=bone['keyframes'];assert k[0]['data_points']==k[-1]['data_points']
assert all(hashlib.sha256((B/p).read_bytes()).hexdigest()==sha for p,sha in M['immutable_datapack'].items())
prior=renderer(O.parent/'阶段五_双面嵌边水刃/深海回响_双面嵌边水刃_分组动画.bbmodel')
metrics=[]
for yaw in [0,math.pi,.45,math.pi+.45,math.pi/2+.3]:
    args=dict(yaw=yaw,pitch=.035,scale=24,focus=(0,7.8,0))
    before=np.array(prior['render']((520,1160),**args)).astype(float);after=np.array(r['render']((520,1160),**args)).astype(float)
    bg=before[0,0];mb=np.any(before!=bg,2);ma=np.any(after!=bg,2);union=mb|ma
    metrics.append({'yaw':round(yaw,5),'silhouette_iou':round(float(np.sum(mb&ma)/np.sum(union)),5),
        'mean_rgb_difference_on_object':round(float(np.abs(before-after)[union].mean()),4)})
assert min(m['silhouette_iou'] for m in metrics)>.94,metrics
result={'cubes_before':1879,'cubes_after':998,'fixed_cubes':910,'water_cubes':88,'cube_reduction_percent':round((1-998/1879)*100,2),
        'faces_before':1879*6,'faces_after':sum(len(e['faces']) for e in base['elements']+frame['elements']),
        'frames_checked':144,'water_attachment_tests':count,'maximum_native_java_error':maxerr,
        'visual_comparison':metrics,'skill_and_display_preserved':True,'game_tested':False}
(B/'.workbuddy/deepsea_dual_optimized_verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False),flush=True)
