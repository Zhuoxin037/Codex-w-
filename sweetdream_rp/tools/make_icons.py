"""通用状态像素图标生成器：32×32 原生像素，保留 U+E000..E004 字体映射。"""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFilter
RP=Path(__file__).resolve().parents[1]
ORDER=['yuanhai','liuhuo','yehuo','shixin','dream']
OUTLINES=['#081c36','#421424','#201039','#350e25','#393152']
def render_plain(mark):
 # 16 像素逻辑网格、三层有限色，不加星光、渐变或浮雕描边。
 im=Image.new('RGBA',(16,16));d=ImageDraw.Draw(im)
 if mark=='yuanhai':
  d.polygon([(8,1),(12,7),(13,10),(12,13),(9,14),(6,14),(3,12),(3,9),(5,5)],fill='#153747')
  d.polygon([(8,3),(10,7),(11,10),(10,12),(6,12),(5,10),(6,7)],fill='#397c98')
  d.line([(7,6),(6,8),(6,10)],fill='#93c2cb',width=1)
 elif mark=='liuhuo':
  d.polygon([(9,1),(9,6),(12,8),(13,5),(14,10),(12,13),(9,14),(5,14),(2,11),(3,6),(5,8),(6,4)],fill='#633626')
  d.polygon([(8,4),(8,8),(10,9),(12,8),(12,11),(10,13),(5,12),(4,9),(6,10),(6,7)],fill='#c77c37')
  d.polygon([(8,8),(10,11),(9,12),(7,12),(6,11)],fill='#eac477')
 elif mark=='yehuo':
  d.polygon([(10,2),(7,2),(4,4),(2,7),(2,11),(4,13),(8,14),(12,12),(13,9),(10,11),(6,10),(5,7),(7,4)],fill='#332b4b')
  d.line([(7,3),(4,6),(3,9),(5,12),(8,13),(11,11)],fill='#796a97',width=1)
  d.line([(4,7),(4,9),(5,10)],fill='#a89ab9',width=1)
 elif mark=='shixin':
  d.polygon([(2,5),(4,3),(6,3),(8,5),(10,3),(13,4),(12,6),(10,6),(11,9),(13,9),(10,12),(8,14),(3,10),(2,8)],fill='#552e37')
  d.polygon([(3,5),(5,4),(7,6),(8,7),(10,5),(9,7),(10,10),(8,12),(4,9),(3,7)],fill='#ad535a')
  d.line([(4,5),(5,5),(6,6)],fill='#d79590',width=1)
 return im.resize((32,32),Image.Resampling.NEAREST)

def render(mark):
 if mark!='dream':return render_plain(mark)
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 # 珍珠云层 + 金星，浅色背景也有深色轮廓。
 d.polygon([(4,19),(6,15),(10,15),(12,10),(17,9),(21,12),(22,16),(26,16),(28,20),(27,24),(24,26),(8,26),(4,23)],fill='#b2afdb')
 d.polygon([(5,19),(7,16),(11,17),(13,12),(17,11),(20,14),(20,18),(24,17),(27,20),(26,23),(8,23),(5,22)],fill='#eee7df')
 d.line([(7,18),(10,18),(12,20),(15,18),(20,18)],fill='#fffaf0',width=2)
 d.line([(8,24),(22,24),(25,22)],fill='#8c88b4')
 d.polygon([(24,3),(25,6),(28,7),(25,8),(24,11),(23,8),(20,7),(23,6)],fill='#ffda83')
 d.point((24,7),fill='#fffbed');d.rectangle((7,9,8,10),fill='#d8cef6')
 # 一像素硬边，无模糊采样，PNG 只使用全透明/全不透明。
 alpha=im.getchannel('A').filter(ImageFilter.MaxFilter(3));edge=Image.new('RGBA',im.size,OUTLINES[ORDER.index(mark)])
 edge.putalpha(alpha);edge.alpha_composite(im);return edge
def main():
 atlas=Image.new('RGBA',(160,32))
 for i,m in enumerate(ORDER):atlas.alpha_composite(render(m),(i*32,0))
 atlas.save(RP/'assets/sweetdream/textures/font/icons.png')
 font={'providers':[{'type':'space','advances':{' ':4}},{'type':'bitmap','file':'sweetdream:font/icons.png','height':16,'ascent':14,'chars':[''.join(chr(0xe000+i) for i in range(5))]}]}
 (RP/'assets/sweetdream/font/icons.json').write_text(json.dumps(font,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 for lang in ['zh_cn','en_us']:
  p=RP/f'assets/sweetdream/lang/{lang}.json';table=json.loads(p.read_text(encoding='utf-8')) if p.exists() else {}
  table.update({'sweetdream.icon.'+m:chr(0xe000+i) for i,m in enumerate(ORDER)})
  p.write_text(json.dumps(table,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('Five icons: 160x32 RGBA. Unrelated translation keys preserved.')
if __name__=='__main__':main()
