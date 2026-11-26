import re, glob, collections, sys, os
sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r'D:/数据包')
c = collections.Counter()
for f in glob.glob('fallendream/data/fallendream/function/equipment/**/give.mcfunction', recursive=True):
    t = open(f, encoding='utf-8').read()
    m = re.search(r'item_name=\{text:"[^"]+",bold:true,color:"([a-z_]+)"', t)
    if m:
        c[m.group(1)] += 1
print(c)
# 找一个罕见装备的颜色
for f in glob.glob('fallendream/data/fallendream/function/equipment/armor/*/give.mcfunction'):
    t = open(f, encoding='utf-8').read()
    if '罕见' in t:
        m = re.search(r'item_name=\{text:"([^"]+)",bold:true,color:"([a-z_]+)"', t)
        if m:
            print('罕见例:', m.group(1), m.group(2))
            break
