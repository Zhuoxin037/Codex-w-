from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
P=Path(__file__).resolve().parent
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',n)
im=Image.new('RGB',(1700,1170),'#eeeae0');d=ImageDraw.Draw(im)
ink='#233b48';muted='#607782';blue='#a4c3ce';cream='#dfd2bd';pink='#d3b8ac'
d.text((55,30),'梦核巨构 / 新方案',font=font(38),fill=ink)
d.text((57,88),'体量与空间关系 · 设计提案，尚未建成 · 320 × 384 格用地',font=font(21),fill=muted)
sx,sy,scale=310,430,1.35
def point(x,z):return (sx+x*scale,sy+z*scale)
def rect(x1,z1,x2,z2,c,label):
    a=point(x1,z1);b=point(x2,z2);d.rectangle((*a,*b),fill=c,outline=ink,width=2)
    if label:d.text(((a[0]+b[0])/2,(a[1]+b[1])/2),label,font=font(17),fill=ink,anchor='mm',align='center')
d.text((55,135),'01  主层平面 / 北 ↑',font=font(24),fill=ink)
rect(-160,-192,160,192,'#e5e1d5','')
rect(-152,-164,152,-144,blue,'G · 高层回廊投影')
rect(-112,-144,112,-72,pink,'F · 层叠露台\n+24 / +48')
rect(-64,-56,64,88,cream,'')
rect(-36,-28,36,60,blue,'下沉水庭\n-6')
rect(-144,-72,-80,72,'#b6d0d3','E\n池庭群')
rect(80,-56,144,72,'#d8c7b2','D\n阅读翼')
rect(-20,88,20,128,'#c2b8aa','B\n入口')
rect(-50,128,50,192,'#e8d8bc','A · 前庭')
for x in [-74,74]:rect(x-6,-144,x+6,88,'#c9cebf','')
for z in [-40,-8,24,56]:
    for x in [-53,53]:
        a=point(x-2,z-2);b=point(x+2,z+2);d.rectangle((*a,*b),fill=ink)
for a,b in [((-80,0),(-64,0)),((64,0),(80,0)),((-60,-72),(-60,-56)),((60,-72),(60,-56))]:d.line([point(*a),point(*b)],fill='#688a76',width=9)
d.text(point(0,77),'C · 中央候厅',font=font(16),fill=ink,anchor='mm')
route=[(0,177),(0,110),(0,80),(49,70),(49,0),(109,0),(109,-40),(70,-40),(70,-110),(0,-110),(-70,-110),(-70,60),(-25,80),(0,110)]
for a,b in zip(route,route[1:]):d.line([point(*a),point(*b)],fill='#ae7258',width=3)
d.text((72,696),'棕线：主游览方向   蓝灰：水 / 高廊   暖灰：主体',font=font(15),fill=muted)
# Architectural axonometric massing. These are proposal solids, not game geometry.
d.text((665,145),'02  体量组合 / 从前庭望向巨厅',font=font(24),fill=ink)
ox,oy=1160,570
def iso(x,y,z):return (ox+(x-z)*1.32,oy+(x+z)*.42-y*2.1)
def cub(x1,z1,x2,z2,y,h,color):
    a,b,c,e=[iso(x,y,z) for x,z in [(x1,z1),(x2,z1),(x2,z2),(x1,z2)]]
    aa,bb,cc,ee=[iso(x,y+h,z) for x,z in [(x1,z1),(x2,z1),(x2,z2),(x1,z2)]]
    rgb=tuple(int(color[i:i+2],16) for i in [1,3,5])
    d.polygon([b,c,cc,bb],fill=tuple(int(v*.77) for v in rgb),outline=ink)
    d.polygon([c,e,ee,cc],fill=tuple(int(v*.9) for v in rgb),outline=ink)
    d.polygon([aa,bb,cc,ee],fill=color,outline=ink)
cub(-160,-192,160,192,-8,8,'#d2c9b8')
cub(-112,-144,112,-72,0,24,'#d9c6b6')
cub(-90,-142,90,-112,24,24,'#e2d5c2')
cub(-70,-140,70,-126,48,60,'#d7d7c9')
cub(-144,-72,-80,72,0,22,'#b9d2d4')
cub(-64,-56,64,88,0,3,'#e5d8c4')
cub(-36,-28,36,60,3,1,'#9ebdca')
# Side walls, successive piers and a frame. Roof cut away deliberately.
for x in [-64,61]:cub(x,-56,x+3,88,3,73,'#dce0d5')
for z in [-40,-8,24,56]:
    for x in [-53,53]:cub(x-2,z-2,x+2,z+2,3,55,'#e4dece')
cub(-64,-20,64,-10,48,3,'#b3c4c5')
cub(-67,-59,67,-54,76,7,'#d6c4b7')
cub(80,-56,144,72,0,24,'#d2c3ae')
cub(82,-54,142,40,24,24,'#ded2bf')
cub(88,-52,136,6,48,20,'#e3dcce')
cub(-20,88,20,128,0,12,'#c9bfaf')
cub(-50,128,50,192,0,2,'#ddcdb4')
d.text((725,740),'示意切去中央顶盖，以显示水庭、立柱和高廊；细部尚未设计。',font=font(16),fill=muted)
# Longitudinal section, with an unambiguous player size reference.
d.text((55,765),'03  空间剖面 / 以主地面为 ±0',font=font(24),fill=ink)
base=1045;left=100;ss=3.5
def section(x,w,h,color,y=0):
    d.rectangle((left+x*ss,base-(y+h)*2.3,left+(x+w)*ss,base-y*2.3),fill=color,outline=ink,width=2)
section(0,55,2,cream);section(55,40,12,pink)
section(95,144,3,cream);section(115,78,6,blue,y=-6)
for x in [95,232]:section(x,4,76,'#bcc7c3')
section(95,144,5,'#cad0c8',76)
section(165,10,3,blue,48)
section(239,36,24,pink);section(275,36,48,cream)
section(311,20,108,'#c4ccc5')
for x,label in [(22,'前庭'),(75,'低入口'),(160,'中央候厅'),(255,'退台'),(293,'高台')]:d.text((left+x*ss,1073),label,font=font(17),fill=ink,anchor='mm')
d.text((left+155*ss,base-67*2.3),'净高约 76 格',font=font(22),fill=ink)
d.ellipse((left+102*ss,base-7,left+102*ss+4,base-3),fill='#a85644');d.line((left+102*ss+2,base-3,left+102*ss+2,base),fill='#a85644',width=2)
d.text((1290,890),'人尺度\n门 3×4\n侧廊 6–12\n楼梯宽 6–8',font=font(21),fill=muted,spacing=12)
d.text((55,1130),'本轮审阅：轮廓 · 高差 · 空间先后 · 步行连接   |   具体材质与构件将在样段阶段验证',font=font(17),fill=muted)
im.save(P/'体量与空间总览.png')
print(P/'体量与空间总览.png')
