from analyze_a_boss_static_20261022 import *
from refine_b_headcloth_20261022 import hierarchy,face_points

def main():
    bb=json.loads((S/'A_头部与胸骨_精修分部.bbmodel').read_text(encoding='utf8'));gs,pa,ep,ns,world=hierarchy(bb);centers=[];axes=[];halves=[]
    for e in bb['elements']:
        g=gs[ep[e['uuid']]];m=world[g['uuid']];c=(np.array(e['from'])+e['to'])/2;centers.append((c-g['origin'])@m[:3,:3].T+m[:3,3]);axes.append(m[:3,:3]);halves.append((np.array(e['to'])-e['from'])/2)
    c=np.array(centers);a=np.array(axes);h=np.array(halves);d=c[None]-c[:,None];rot=np.einsum('nwa,mwb->nmab',a,a);local=np.einsum('nmw,nwa->nma',d,a);radius=h[:,None]+np.einsum('nmab,mb->nma',abs(rot),h);ok=(radius-abs(local)).min(2)>=-.015;touch=ok&ok.T;seen=set(range(len(c)));comps=[]
    while seen:
        todo=[seen.pop()];ids=[]
        while todo:
            i=todo.pop();ids.append(i);nxt=set(np.flatnonzero(touch[i]))&seen;seen-=nxt;todo.extend(nxt)
        comps.append(ids)
    comps.sort(key=len,reverse=True);report={'cubes':len(c),'components':[{'cubes':len(ids),'elements':[bb['elements'][i]['name'] for i in ids] if len(ids)<20 else [],'bounds':[np.min(c[ids]-h[ids],axis=0).tolist(),np.max(c[ids]+h[ids],axis=0).tolist()]} for ids in comps],'method':'OBB separating axes; all cube rotations are zero and bone rotations are Y-only. Contact tolerance .015 model units.','not_complete_character':True}
    (S/'分部实际连接核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=False),flush=True)

if __name__=='__main__':main()
