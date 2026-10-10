# -*- coding: utf-8 -*-
"""修观测镜两件事:
① return_item 的两处组件列表漏了 item_model / max_stack_size
   -> 右键消耗后还回来的那个没有模型(变回追溯指针原版外观)。
② 模型的 element 里多了个 "name" 字段(包里既有模型都没有, 我生成时加的)
   -> 有触发模型加载失败显示紫黑方块的风险, 去掉。

改完会把 sweetdream_rp 同步到版本隔离的 resourcepacks 目录。
"""
import io, os, json

DATA = r'D:\数据包\sweetdream\data\sweetdream\function\equipment\tool\look'
RP_SRC = r'D:\数据包\sweetdream_rp'
RP_DST = r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\resourcepacks\sweetdream_rp'

# ---------------------------------------------------------- ① return_item
p = os.path.join(DATA, 'return_item.mcfunction')
t = io.open(p, encoding='utf-8').read()
OLD = 'with recovery_compass[minecraft:item_name='
NEW = ('with recovery_compass[max_stack_size=1,'
       'minecraft:item_model="sweetdream:look",minecraft:item_name=')
n = t.count(OLD)
t = t.replace(OLD, NEW)
io.open(p, 'w', encoding='utf-8', newline='\n').write(t)
print('return_item: 补齐 %d 处' % n)

# ---------------------------------------------------------- ② 模型去掉 name
mp = os.path.join(RP_SRC, 'assets', 'sweetdream', 'models', 'item', 'look.json')
m = json.load(io.open(mp, encoding='utf-8'))
k = 0
for el in m['elements']:
    if 'name' in el:
        del el['name']
        k += 1
io.open(mp, 'w', encoding='utf-8', newline='\n').write(
    json.dumps(m, ensure_ascii=False, indent=1))
print('模型: 去掉 %d 个 name 字段' % k)

# ---------------------------------------------------------- ③ 同步资源包
cnt = 0
for root, dirs, files in os.walk(RP_SRC):
    rel = os.path.relpath(root, RP_SRC)
    dst = os.path.join(RP_DST, rel) if rel != '.' else RP_DST
    os.makedirs(dst, exist_ok=True)
    for f in files:
        s, d = os.path.join(root, f), os.path.join(dst, f)
        if (not os.path.exists(d)) or (os.path.getmtime(s) > os.path.getmtime(d)):
            io.open(d, 'wb').write(io.open(s, 'rb').read())
            cnt += 1
print('资源包同步: %d 个文件' % cnt)

# ---------------------------------------------------------- ④ 复查三处一致
def comps(line):
    a = line.find('recovery_compass[')
    b = line.rfind(']')
    return line[a:b]

g = [l for l in io.open(os.path.join(DATA, 'give.mcfunction'), encoding='utf-8').read().split('\n')
     if l.startswith('give ')][0]
r = [comps(l) for l in io.open(p, encoding='utf-8').read().split('\n')
     if 'recovery_compass[' in l]
base = comps(g)
for i, c in enumerate(r):
    same = (c == base)
    print('  return_item[%d] 组件与 give 一致: %s' % (i, '是' if same else '否'))
    if not same:
        print('    give: %s' % base[:120])
        print('    ret : %s' % c[:120])
