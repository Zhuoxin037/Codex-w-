"""Hand-authored 16x16 staff sample; review artifacts only, no pack binding."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'模型设计/原版风_法杖像素试绘_20261010'
OUT.mkdir(parents=True,exist_ok=True)

# Every nonempty character is one deliberately placed texture pixel.
# No smoothing, image generation, procedural noise or outer glow.
rows=[
 '............o...',
 '...........oho..',
 '..........ohmso.',
 '.........gohmso.',
 '.........Gomhos.',
 '.........gGooGg.',
 '........dgBGgd..',
 '........dWbd....',
 '.......dWbd.....',
 '......dWbd......',
 '.....dWbd.......',
 '....dWbd........',
 '...dWbd.........',
 '..dWbd..........',
 '.dWbd...........',
 '..dd............',
]
palette={
 'o':'193b43', 's':'286c7c', 'm':'38aab2', 'h':'a3e9de',
 'g':'51412a','G':'ae8b50','B':'d4ba79',
 'd':'33251b','b':'68462c','W':'9d7145',
}
assert len(rows)==16 and all(len(s)==16 for s in rows)
sprite=Image.new('RGBA',(16,16),(0,0,0,0))
for y,row in enumerate(rows):
    for x,key in enumerate(row):
        if key=='.':continue
        color=palette[key]
        sprite.putpixel((x,y),tuple(int(color[i:i+2],16) for i in (0,2,4))+(255,))
sprite.save(OUT/'共鸣_法杖_16x16.png')

board=Image.new('RGB',(900,550),'#22252a');d=ImageDraw.Draw(board)
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',28)
small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',18)
tiny=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',15)
d.text((30,22),'共鸣 · 原版风法杖像素试绘',font=font,fill='#e4e0d5')
d.text((30,66),'16 × 16 手工逐像素绘制 · 木柄 / 黄铜夹座 / 青蓝水晶',font=small,fill='#b0b4b7')
d.rectangle((30,118,430,518),fill='#30343a')
board.paste(sprite.resize((384,384),Image.Resampling.NEAREST),(38,126),sprite.resize((384,384),Image.Resampling.NEAREST))
d.text((475,119),'物品栏尺寸',font=small,fill='#d1d4d5')

def slot(x,y,size,icon=None):
    d.rectangle((x,y,x+size-1,y+size-1),fill='#8b8b8b')
    d.line((x,y,x+size-1,y),fill='#373737',width=2)
    d.line((x,y,x,y+size-1),fill='#373737',width=2)
    d.line((x,y+size-1,x+size-1,y+size-1),fill='#ffffff',width=2)
    d.line((x+size-1,y,x+size-1,y+size-1),fill='#ffffff',width=2)
    if icon:
        q=icon.resize((size-8,size-8),Image.Resampling.NEAREST)
        board.paste(q,(x+4,y+4),q)

for i in range(5):slot(475+i*74,165,68,sprite if i==2 else None)
d.text((475,245),'小图也保留清楚的杖头和细柄。',font=tiny,fill='#a9afb2')
d.text((475,296),'与原版物品放在一起',font=small,fill='#d1d4d5')
refs=[('stick','木棍'),('blaze_rod','烈焰棒')]
for i,(key,label) in enumerate(refs):
    ref=Image.open(ROOT/('.workbuddy/_vanilla_ref/'+key+'.png')).convert('RGBA')
    slot(480+i*110,337,84,ref)
    d.text((480+i*110,432),label,font=tiny,fill='#bfc3c5')
slot(700,337,84,sprite);d.text((700,432),'共鸣',font=tiny,fill='#bfc3c5')
d.text((475,484),'试绘阶段；待确认后再画其他法杖。',font=tiny,fill='#919b9f')
board.save(OUT/'共鸣_法杖_像素预览.png')
(OUT/'试绘说明.json').write_text(json.dumps({'item':'chime','name':'共鸣','resolution':[16,16],
 'opaque_pixels':sum(k!='.' for row in rows for k in row),'palette_colors':len(palette),
 'hand_authored':True,'game_bound':False,'phase':'单张风格审阅'},ensure_ascii=False,indent=2),encoding='utf-8')
print(OUT/'共鸣_法杖_像素预览.png')
