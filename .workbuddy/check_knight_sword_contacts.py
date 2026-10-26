from assemble_knight_sword import *
from review_knight_stage2 import obb,gap
from collections import Counter

b=json.loads((W/'有披风/骑士_有披风_持剑.bbmodel').read_text(encoding='utf8'));s=Scene(b);body=[e for e in b['elements'] if not e['name'].startswith('sword_')];groups={g['name']:g for g in b['groups']}
blade={'name':'blade_proxy','uuid':'proxy','from':(A+np.array([8-1.1*1.16,6.25,8-.4])-GRIP).tolist(),'to':(A+np.array([8+1.1*1.16,31.914,8+.4])-GRIP).tolist(),'origin':A.tolist(),'rotation':[0,0,0]}
s.element_bone['proxy']='weapon_knight_sword';s.parents['proxy']=groups['weapon_knight_sword']['uuid'];reports={}
for a in b['animations']:
    hits=Counter();examples=[]
    for t in np.linspace(0,a['length'],round(a['length']*20)+1):
        m=s.matrices(sample(a,float(t)));bb=obb(blade,s,m);center,R,h=bb;ext=np.abs(R)@h;lo=center-ext;hi=center+ext
        for e in body:
            n=s.element_bone[e['uuid']]
            if n=='hand_r':continue
            be=obb(e,s,m);c,r,he=be;ex=np.abs(r)@he
            if np.any(c+ex<lo) or np.any(c-ex>hi):continue
            sep=gap(bb,be)
            if sep<-.08:
                hits[n]+=1
                if len(examples)<7:examples.append([round(float(t),3),e['name'],n,round(sep,3)])
    reports[a['name']]={'blade_broad_proxy_contacts':dict(hits),'examples':examples}
(O/'持剑碰撞预检.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(reports,ensure_ascii=False),flush=True)
