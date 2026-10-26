from pathlib import Path
import json,base64,sys
from PIL import Image,ImageDraw,ImageFont
from bb_local_bridge_client import script,call
import native_c_static_20261024 as n
D=n.D
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',21)
def shots(label,views,width=1200,height=1450):
 ss=call('screenshot_views',{'views':[{'position':p,'target':t}for p,t in views],'width':width,'height':height,'annotate':False},timeout=60)['shots']
 out=Image.new('RGB',(len(ss)*700,1050),'#171c23');dr=ImageDraw.Draw(out)
 for i,sh in enumerate(ss):
  path=D/(label+'_'+str(i)+'.png');path.write_bytes(base64.b64decode(sh['base64']));im=Image.open(path).convert('RGBA');a=im.getchannel('A');box=a.getbbox();im=im.crop(box) if box else im
  im.thumbnail((670,965));out.paste(im,(i*700+(700-im.width)//2,65+(965-im.height)//2),im);dr.text((i*700+15,15),label+' '+str(i+1),font=font,fill='white')
 out.save(D/(label+'.png'))
def isolate(expr):
 expr=expr.replace('c.name','c.name.replace(/^opt_/, "")')
 script('''if(Project.name!==params.title)throw new Error('Wrong model');globalThis.__c_review_visibility=Cube.all.map(c=>[c.uuid,c.visibility]);Cube.all.forEach(c=>c.visibility=Boolean(c.visibility && (new Function('c','return ('+params.expression+')'))(c)));Canvas.updateAll();return Cube.all.filter(c=>c.visibility).length;''',{'title':n.TITLE,'expression':expr})
def restore():
 script('''let m=new Map(globalThis.__c_review_visibility||[]);Cube.all.forEach(c=>{if(m.has(c.uuid))c.visibility=m.get(c.uuid);});Canvas.updateAll();delete globalThis.__c_review_visibility;return true;''')
if __name__=='__main__':
 assert n.state()['name']==n.TITLE
 try:
  isolate('c.to[1]<29 && !c.name.startsWith("cape_")')
  shots('腰裙与腿甲_披风隐藏检查',[([10,20,-42],[2,15,1]),([45,22,6],[1,15,2]),([5,20,43],[1,15,2])])
 finally:restore()
 try:
  isolate('c.name.startsWith("hand_") || c.name.startsWith("armour_bracer_") || c.name.startsWith("limb_forearm_")')
  shots('手套与护臂_实体检查',[([15,28,-38],[1,26,0]),([-36,24,15],[1,26,0])])
 finally:restore()
 try:
  isolate('c.name.startsWith("boot_") || c.name.startsWith("limb_shin_") || c.name.startsWith("armour_shin_")')
  shots('靴子与小腿_实体检查',[([7,12,-36],[1,6,1]),([38,14,6],[1,6,1]),([6,12,40],[1,6,1])])
 finally:restore()
 print(n.save(),flush=True)
