from pathlib import Path
import json,copy
import numpy as np
from PIL import Image,ImageDraw,ImageFont
from knight_scene import Scene
from animate_knight_stage2 import sample
from refine_knight_gait_alignment import shoe_markers

O=Path(__file__).parent/'knight_gait_fix'
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',17)
b=json.loads((O/'骑士_有披风_步态修订.bbmodel').read_text(encoding='utf8'));s=Scene(b)
hand=copy.deepcopy(b);hand['elements']=[e for e in b['elements'] if s.element_bone[e['uuid']] in ['hand_r','forearm_r']]
hs=Scene(hand);sheet=Image.new('RGB',(1200,420),'#20252d');dr=ImageDraw.Draw(sheet)
for i,d in enumerate([(0,0,-1),(1,0,0),(0,0,1)]):
    sheet.paste(hs.render(d,size=(400,380),center=(8.5,22.5,-4.6),ppu=35),(i*400,40))
    dr.text((i*400+10,10),['右手正面','右手外侧','右手背面'][i],font=font,fill='white')
sheet.save(O/'右手_握持通道检查.png')
print('hand cubes',flush=True)
for e in hand['elements']:
    if s.element_bone[e['uuid']]=='hand_r':print(e['name'],e['from'],e['to'],e.get('rotation'))
report={};sheet=Image.new('RGB',(1440,540),'#20252d');dr=ImageDraw.Draw(sheet)
for i,(nm,t) in enumerate([('walk',.15),('walk',.45),('sprint',.1),('sprint',.45)]):
    a=next(a for a in b['animations'] if a['name']==nm);m=s.matrices(sample(a,t));fr={'matrices':{n:v.T.flatten().tolist() for n,v in m.items()}}
    sheet.paste(s.render((0,0,-1),size=(360,490),center=(0,24,-3),ppu=9,frame=fr),(i*360,40));dr.text((i*360+10,10),f'{nm} {t}s',font=font,fill='white')
sheet.save(O/'步态_正面姿态核对.png')
for a in b['animations']:
    if a['name'] not in ['walk','sprint']:continue
    low=100.;headings={k:[] for k in 'rl'};ankle={k:[] for k in 'rl'}
    for t in np.linspace(0,a['length'],round(a['length']*120)+1):
        m=s.matrices(sample(a,float(t)))
        for side in 'rl':
            n='foot_'+side;pts=np.vstack([s.corners[e['uuid']] for e in b['elements'] if s.element_bone[e['uuid']]==n]);R=m[n][:3,:3];low=min(low,float((pts@R.T+m[n][:3,3])[:,1].min()))
            toe,heel=shoe_markers(b,s,side);v=R@(toe-heel);headings[side].append(float(np.degrees(np.arctan2(v[0],-v[2]))));ankle[side].append(float(m[n][0,3]))
    report[a['name']]={'min_sole_y':low,'shoe_headings':{k:[min(v),max(v)] for k,v in headings.items()},'ankle_x':{k:[min(v),max(v)] for k,v in ankle.items()}}
(O/'步态_插值核对.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
