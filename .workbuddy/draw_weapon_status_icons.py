"""Draw the five verified creature-side weapon states for review; never modify live packs."""
from pathlib import Path
import hashlib, json, math, zipfile
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'模型设计/武器专属标签_20261015'
RP=ROOT/'sweetdream_rp_完整版'
ATLAS=RP/'assets/sweetdream/textures/font/icons.png'
PAL={
 'shenghen':['#68451f','#c99b44','#f4d88f','#fff3cd'],
 'stg':['#21475b','#4798b3','#9bd6db','#e2f5e8'],
 'dianci':['#34365c','#7987d0','#becde9','#f2f0d6'],
 'shizhou':['#412e4b','#885580','#c88ca5','#f3d3ce'],
}
NAMES={'shenghen':'圣痕','stg':'升痕','dianci':'电刺','mancai':'漫彩','shizhou':'世咒'}
ROMAN={1:'I',2:'II',3:'III',4:'IV',5:'V'}
ROMAN_LABEL={1:'Ⅰ',2:'Ⅱ',3:'Ⅲ',4:'Ⅳ',5:'Ⅴ'}
# Taken from the actual five existing status glyphs: shadow, body, highlight.
PIGMENTS={
 'yuanhai':dict(name='渊海',colors=['#153747','#397c98','#93c2cb']),
 'liuhuo':dict(name='流火',colors=['#633626','#c77c37','#eac477']),
 'yehuo':dict(name='夜火',colors=['#332b4b','#796a97','#a89ab9']),
 'shixin':dict(name='噬心',colors=['#552e37','#ad535a','#d79590']),
 'dream':dict(name='白昼梦',colors=['#b2afdb','#eee7df','#fffaf0']),
}
SOURCE={
 'shenghen':dict(name='圣痕',weapon='天使核心',source='equipment/axe/angel_core/mark.mcfunction',
  state='zx.status.shenghen',timer='zx.sh_t',levels=1,lifetime='15秒，到期或被引爆后移除'),
 'stg':dict(name='升痕',weapon='天穹',source='equipment/axe/skyvault/mark.mcfunction',
  state='zx.stg',timer='zx.stg_t',levels=3,lifetime='最多3层；每15秒减少1层，叠加时刷新计时'),
 'dianci':dict(name='电刺',weapon='电弧',source='equipment/bow/arc/hook_victim.mcfunction',
  state='zx.status.dianci',timer=None,levels=1,lifetime='没有自然倒计时；配对放电后移除'),
 'mancai':dict(name='漫彩',weapon='虹彩',source='equipment/bow/rainbow/fire.mcfunction',
  state='zx.rb_rainbow',timer='zx.rb_end',levels=1,lifetime='初始10秒，每次吞噬通用状态缩短1秒'),
 'shizhou':dict(name='世咒',weapon='五世恶咒',source='equipment/staff/five_curses/curse_step.mcfunction',
  state='zx.fcv_st',timer='zx.fcv_t',levels=5,lifetime='第一/第二世3秒；第三至第五世5秒；终世是瞬时结算'),
}

def color(s):return tuple(bytes.fromhex(s.lstrip('#')))+(255,)
def shape():return Image.new('1',(16,16)),None
def mask_image(polygons=(),rects=()):
 m=Image.new('1',(16,16));d=ImageDraw.Draw(m)
 for p in polygons:d.polygon(p,fill=1)
 for r in rects:d.rectangle(r,fill=1)
 return m
def shaded(mask,name):
 im=Image.new('RGBA',(16,16));p=[color(x) for x in PAL[name]]
 def inside(x,y):return 0<=x<16 and 0<=y<16 and mask.getpixel((x,y))
 for y in range(16):
  for x in range(16):
   if not inside(x,y):continue
   k=2 if not inside(x,y-1) else 0 if not inside(x+1,y) or not inside(x,y+1) else 1
   im.putpixel((x,y),p[k])
 return im
def holy():
 m=mask_image(polygons=[[(7,0),(9,4),(14,7),(10,9),(8,14),(5,10),(1,8),(5,5)],
                       [(0,3),(3,5),(4,7),(1,6)],[(11,9),(15,10),(13,12),(10,11)]])
 im=shaded(m,'shenghen');d=ImageDraw.Draw(im)
 d.line([(7,4),(7,10)],fill=color(PAL['shenghen'][2]),width=2)
 d.rectangle((6,6,8,8),fill=color(PAL['shenghen'][3]))
 d.point((13,2),fill=color(PAL['shenghen'][2]));return im
def rising(level):
 m=mask_image(polygons=[[(7,0),(13,6),(10,7),(7,4),(4,7),(1,6)],
                       [(7,6),(13,11),(10,12),(7,10),(4,12),(1,11)]],rects=[(6,3,8,10)])
 im=shaded(m,'stg');d=ImageDraw.Draw(im)
 d.point((7,1),fill=color(PAL['stg'][3]))
 return im
def spark():
 m=mask_image(polygons=[[(8,0),(13,0),(9,6),(12,6),(5,14),(6,9),(2,9)]])
 im=shaded(m,'dianci');d=ImageDraw.Draw(im)
 d.line([(10,1),(6,7),(8,7),(6,11)],fill=color(PAL['dianci'][3]),width=1)
 for xy in [(2,2),(1,4),(14,10),(13,13)]:d.point(xy,fill=color(PAL['dianci'][2]))
 return im
def pigment():
 im=Image.new('RGBA',(16,16));d=ImageDraw.Draw(im)
 # Five uneven paint strokes use the five status palettes, not generic rainbow colors.
 bands=[('yuanhai',[(7,1),(10,1),(13,4),(11,6),(9,4),(6,4)]),
        ('liuhuo',[(12,4),(14,6),(14,10),(11,12),(9,10),(11,8),(10,6)]),
        ('yehuo',[(10,10),(12,12),(9,14),(5,14),(4,12),(6,10),(8,11)]),
        ('shixin',[(5,11),(5,14),(2,12),(1,8),(3,6),(5,8),(4,10)]),
        ('dream',[(2,7),(1,5),(4,2),(7,1),(9,3),(6,5),(5,4),(4,6)])]
 for name,poly in bands:
  colors=PIGMENTS[name]['colors']
  m=mask_image(polygons=[poly])
  def at(x,y):return 0<=x<16 and 0<=y<16 and m.getpixel((x,y))
  for y in range(16):
   for x in range(16):
    if at(x,y):im.putpixel((x,y),color(colors[2 if not at(x,y-1) else 0 if not at(x+1,y) else 1]))
 d=ImageDraw.Draw(im);d.point((11,0),fill=color(PIGMENTS['yuanhai']['colors'][1]));d.point((0,12),fill=color(PIGMENTS['shixin']['colors'][1]))
 d.rectangle((6,6,8,8),fill=color(PIGMENTS['dream']['colors'][1]));d.point((9,8),fill=color(PIGMENTS['yehuo']['colors'][1]))
 return im
def curse(level):
 m=mask_image(polygons=[[(4,1),(10,1),(14,5),(13,11),(9,14),(4,13),(1,9),(1,5)]])
 d=ImageDraw.Draw(m);d.polygon([(5,4),(9,3),(11,6),(11,9),(8,11),(5,10),(3,7)],fill=0)
 # Open breaks keep the ring from reading as a solid medallion.
 d.rectangle((9,1,10,2),fill=0);d.rectangle((1,9,2,10),fill=0)
 im=shaded(m,'shizhou');d=ImageDraw.Draw(im)
 d.polygon([(7,4),(9,7),(7,10),(5,7)],fill=color(PAL['shizhou'][1]))
 d.line([(7,5),(7,8)],fill=color(PAL['shizhou'][2]));d.point((7,6),fill=color(PAL['shizhou'][3]))
 for x,y in [(6,0),(12,3),(12,11),(5,13),(0,5)]:
  d.rectangle((x,y,x+1,y+1),fill=color(PAL['shizhou'][1]))
 return im
def roman_badge(im,level):
 """Pixel Roman numeral in the lower-right corner, with a thin dark outline."""
 strokes={
  'I':['##']*10,
  'V':['##....##','##....##','##....##','.##..##.','.##..##.','.##..##.','..####..','..####..','...##...','...##...'],
 }
 label=ROMAN[level];width=sum(len(strokes[c][0]) for c in label)+2*(len(label)-1)
 mask=Image.new('L',im.size);d=ImageDraw.Draw(mask);x=31-width;y=21
 for c in label:
  for row,line in enumerate(strokes[c]):
   for col,pixel in enumerate(line):
    if pixel=='#':d.point((x+col,y+row),fill=255)
  x+=len(strokes[c][0])+2
 out=im.copy();outline=mask.filter(ImageFilter.MaxFilter(3))
 out.paste(color('#211e28'),(0,0),outline);out.paste(color('#f8edcc'),(0,0),mask)
 return out
def dim(im):
 out=im.copy()
 for y in range(im.height):
  for x in range(im.width):
   r,g,b,a=im.getpixel((x,y));l=.299*r+.587*g+.114*b
   if a:out.putpixel((x,y),(round(r+(l-r)*.35),round(g+(l-g)*.35),round(b+(l-b)*.35),102))
 return out
def font(size):return ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',size)

def main():
 OUT.mkdir(parents=True,exist_ok=True);(OUT/'图标').mkdir(exist_ok=True)
 before=hashlib.sha256(ATLAS.read_bytes()).hexdigest()
 legacy=Image.open(ATLAS).convert('RGBA');assert legacy.width>=320 and legacy.height==32
 legacy=legacy.crop((0,0,320,32))
 glyphs=[];icons={};code=0xE00A
 for name,data in SOURCE.items():
  assert (ROOT/'sweetdream/data/sweetdream/function'/data['source']).is_file()
  for level in range(1,data['levels']+1):
   im={'shenghen':holy,'dianci':spark,'mancai':pigment}.get(name,lambda:None)() if name not in ['stg','shizhou'] else (rising(level) if name=='stg' else curse(level))
   key=name+(f'_{level}' if data['levels']>1 else '')
   im=im.resize((32,32),Image.Resampling.NEAREST)
   if name in ['stg','shizhou']:im=roman_badge(im,level)
   icons[key]=im
   for faded in [False,True] if data['timer'] else [False]:
    cell=dim(im) if faded else im;ident=key+('_dim' if faded else '')
    cell.save(OUT/'图标'/(ident+'.png'))
    glyphs.append({'key':ident,'state':name,'level':level,'dim':faded,'codepoint':f'U+{code:04X}','character':chr(code),'image':'图标/'+ident+'.png'})
    code+=1
 preview_atlas=Image.new('RGBA',(320+32*len(glyphs),32));preview_atlas.paste(legacy,(0,0))
 for i,g in enumerate(glyphs):preview_atlas.paste(Image.open(OUT/g['image']),(320+i*32,0))
 preview_atlas.save(OUT/'候选字体图集_未部署.png')

 sheet=Image.new('RGB',(1060,810),(26,29,33));d=ImageDraw.Draw(sheet)
 d.text((24,14),'武器专属状态 · 头顶图标',font=font(27),fill=(233,222,198))
 d.text((24,54),'实际像素纹理预览 · 现有五大标签保持原样 · 尚未写入游戏资源包',font=font(15),fill=(160,165,166))
 notes=['圣光刻印／无层数','右下角Ⅰ–Ⅲ','蓝白电刺／无计时','五色涂痕／10秒','右下角Ⅰ–Ⅴ']
 keys=['shenghen','stg_3','dianci','mancai','shizhou_5']
 for i,(name,key,note) in enumerate(zip(SOURCE,keys,notes)):
  x=24+i*206
  d.rounded_rectangle((x,91,x+188,328),radius=8,fill=(36,40,44))
  d.text((x+12,102),NAMES[name],font=font(23),fill=(235,229,212))
  sheet.paste(icons[key].resize((128,128),Image.Resampling.NEAREST),(x+30,145),icons[key].resize((128,128),Image.Resampling.NEAREST))
  d.text((x+12,284),SOURCE[name]['weapon'],font=font(16),fill=(193,186,165))
  d.text((x+12,307),note,font=font(13),fill=(149,160,163))
 d.text((24,351),'层级变化：图案固定，右下角罗马数字显示层级',font=font(17),fill=(211,210,197))
 d.text((24,402),'升痕',font=font(18),fill=(143,196,204))
 for i in range(1,4):
  im=icons[f'stg_{i}'].resize((64,64),Image.Resampling.NEAREST);sheet.paste(im,(100+(i-1)*88,390),im)
  d.text((116+(i-1)*88,459),ROMAN_LABEL[i],font=font(15),fill=(187,197,196))
 d.text((424,402),'世咒',font=font(18),fill=(210,161,188))
 for i in range(1,6):
  im=icons[f'shizhou_{i}'].resize((64,64),Image.Resampling.NEAREST);sheet.paste(im,(500+(i-1)*100,390),im)
  d.text((516+(i-1)*100,459),ROMAN_LABEL[i],font=font(15),fill=(200,186,191))
 d.text((24,483),'漫彩五色：',font=font(14),fill=(180,181,174))
 for i,v in enumerate(PIGMENTS.values()):
  x=122+i*175;d.rectangle((x,484,x+12,496),fill=color(v['colors'][1])[:3])
  d.text((x+20,480),v['name'],font=font(15),fill=(201,199,188))
 d.text((24,510),'临期：圣痕、升痕、漫彩、世咒只淡化自己的图标；电刺没有自然到期，不画倒计时',font=font(16),fill=(180,181,174))
 for i,key in enumerate(keys):
  im=(icons[key] if key=='dianci' else dim(icons[key])).resize((64,64),Image.Resampling.NEAREST)
  sheet.paste(im,(44+i*206,548),im)
  if key=='dianci':d.text((470,616),'保持常态',font=font(13),fill=(151,158,166))
 d.text((24,657),'同排排版示意：渊海＋流火＋圣痕＋3层升痕＋第五世；多种状态可同时出现',font=font(16),fill=(211,210,197))
 row=[legacy.crop((0,0,32,32)),legacy.crop((32,0,64,32)),icons['shenghen'],icons['stg_3'],icons['shizhou_5']]
 for i,im in enumerate(row):
  tile=im.resize((48,48),Image.Resampling.NEAREST);sheet.paste(tile,(24+i*52,706),tile)
 d.text((340,718),'仅示意图标组合，尚非游戏截图。',font=font(16),fill=(158,165,167))
 sheet.save(OUT/'武器专属状态_图标预览.png')
 plan={'stage':'drawn_for_review_not_deployed','source_atlas_sha256':before,'states':SOURCE,'glyphs':glyphs,
       'level_display':{'position':'lower-right','stg':['Ⅰ','Ⅱ','Ⅲ'],'shizhou':['Ⅰ','Ⅱ','Ⅲ','Ⅳ','Ⅴ'],'replaces':'level-dependent dots'},
       'mancai_five_status_colors':PIGMENTS,
       'legacy_characters_unchanged':10,'new_glyphs':len(glyphs),'candidate_atlas_size':list(preview_atlas.size),
       'excluded':['熔浆、风声、冰凌、梦回、悲鸣、曲调、启示等玩家资源','深海连续追击等内部目标快照','冰冻、时停等通用控制效果','终世瞬时结算，不作为第六种持续世咒'],
       'runtime_plan':'接入现有每生物一个text_display的头顶行，不额外为每个图标召唤实体；显示层不得推进任何状态时长。'}
 (OUT/'图标与接入清单.json').write_text(json.dumps(plan,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 lines=['# 武器专属状态核对与绘制','', '阶段：5种状态的实际纹理已绘制；尚未修改或部署游戏资源/数据包。','',
        '| 状态 | 来源武器 | 生物上的真实状态 | 层级和时长 |','|---|---|---|---|']
 for k,v in SOURCE.items():lines.append(f'| {v["name"]} | {v["weapon"]} | `{v["state"]}` | {v["lifetime"]} |')
 lines+=['','圣痕的内部名shenghen与升痕的stg不可混用。世咒是阶段，不是五个同时叠加的独立图标；终世只结算，不新增持续图标。',
         '','实际贴图采用16像素构图，再以最近邻放大到现有字体要求的32×32格。新增11个普通档位和10个临期档位；电刺没有自然倒计时，不添加临期字形。',
         '','旧的五大标签以及旧10个字形保持逐像素原样。候选图集只写在本设计目录，未替换完整版。层级固定格宽：升痕右下角为Ⅰ–Ⅲ，世咒右下角为Ⅰ–Ⅴ，取代按刻点表示层级；数字带细暗边，临期数字随各自图标淡化。',
         '','漫彩改为对应五个通用标签的五种颜料色：渊海蓝、流火橙、夜火紫、噬心红、白昼梦白。色阶直接取自包内实际五大标签图标，保留原涂痕旋绕造型。',
         '','后续头顶接入沿用每只生物单一text_display，按真实状态同排组合；显示刷新只读状态，不调用倒计时、扣层、伤害等机制。',
         '','未纳入玩家资源、临时内部选敌标记或通用控制效果。旧审计脚本提到的“蛊虫”不符合当前蛊毒技能：当前蛊毒实际施加的是已有噬心与缓慢，因此未虚构额外图标。',
         '','## 核对源码','']
 for v in SOURCE.values():
  p=ROOT/'sweetdream/data/sweetdream/function'/v['source'];lines.append(f'- {v["name"]}：[{v["source"]}]({p.as_posix()})')
 (OUT/'状态核对与绘制说明.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
 assert hashlib.sha256(ATLAS.read_bytes()).hexdigest()==before
 assert preview_atlas.crop((0,0,320,32)).tobytes()==legacy.tobytes()
 assert len(glyphs)==21 and len({g['codepoint'] for g in glyphs})==21
 assert all(Image.open(OUT/g['image']).size==(32,32) for g in glyphs)
 print(json.dumps({'states':5,'normal_variants':11,'dim_variants':10,'preview':str(OUT/'武器专属状态_图标预览.png'),'game_files_changed':0},ensure_ascii=False))

if __name__=='__main__':main()
