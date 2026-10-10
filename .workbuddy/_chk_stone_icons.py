# -*- coding: utf-8 -*-
"""守住"强化石/超限石图标编号表"三处一致。

为什么要单独守: 石头的底座统一是 recovery_compass(追溯指针), 长得一样 —— 全靠
`custom_model_data={floats:[N.0f]}` 换外观。于是同一个编号 N 必须在**三处**对齐:
  ① 数据包 give 里写的 floats:[N.0f]
  ② 资源包 assets/minecraft/items/recovery_compass.json 的 entries(N -> 模型)
  ③ 模型文件 + 贴图文件真实存在
任何一处漏了, 游戏里不会报错 —— 只是那块石头**长得和别的石头一样**(或直接变紫黑块),
玩家只会在拿到手的时候才发现。give 文件头也写着"改一边要改两边", 这条脚本就是它的机器版。

另守第六步: **资源包有"两份"**(源 + 版本隔离目录), 是拷贝不是链接, 改源必须同步过去。
本脚本离线抓这四类:
  1. give(upgrade/item/* + overlimit/item/*) 的每个 N 都要在 recovery_compass.json 里有 entry
  2. 每个 entry 引用的 models/item/stone/<id>.json 存在且 JSON 合法 / textures 指向的 PNG 存在
  3. 编号不重复、阈值 >0(阈值 0 会顶掉原版指针)、id 与文件名对得上
  4. 源资源包 与 版本隔离目录 的 recovery_compass.json / stone 素材**字节一致**
重跑: python .workbuddy/_chk_stone_icons.py
"""
import io, os, re, sys, json

ROOT = r'D:\数据包'
DP = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')
RP_SRC = os.path.join(ROOT, 'sweetdream_rp')
RP_DST = (r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10'
          r'\resourcepacks\sweetdream_rp')
RC = 'assets/minecraft/items/recovery_compass.json'

bad = []


def err(m):
    bad.append(m)
    print('[x] ' + m)


def ok(m):
    print('[ok] ' + m)


# ---------------------------------------------------- 1) give 里用到的编号
uses = {}          # N -> [来源文件]
for sub in ('upgrade/item', 'overlimit/item'):
    d = os.path.join(DP, *sub.split('/'))
    if not os.path.isdir(d):
        err('目录不存在: %s' % d)
        continue
    for fn in sorted(os.listdir(d)):
        if not fn.endswith('.mcfunction'):
            continue
        txt = io.open(os.path.join(d, fn), encoding='utf-8').read()
        for m in re.finditer(r'custom_model_data=\{floats:\[(\d+)\.0f\]\}', txt):
            uses.setdefault(int(m.group(1)), []).append('%s/%s' % (sub, fn))
if not uses:
    err('一件石头都没扫到 —— give 的写法变了? (期望 custom_model_data={floats:[N.0f]})')
else:
    ok('give 用到 %d 个编号: %s' % (len(uses), ', '.join(str(n) for n in sorted(uses))))

# ---------------------------------------------------- 2) 编号表 entries
try:
    doc = json.load(io.open(os.path.join(RP_SRC, RC), encoding='utf-8'))
    entries = doc['model']['entries']
except Exception as e:
    err('读不了 %s: %s' % (RC, e))
    entries = []
by_thr = {}
for e in entries:
    thr = float(e.get('threshold', -1))
    mid = e.get('model', {}).get('model', '')
    if thr in by_thr:
        err('阈值 %.1f 重复(entries 只能有一个)' % thr)
    by_thr[thr] = mid
    if thr <= 0:
        err('阈值 %.1f <= 0 —— 会把原版指针顶掉(没有 cmd 的物品取值 0)' % thr)
    if not mid.startswith('sweetdream:item/stone/'):
        err('entry %.1f 指向非 stone 模型: %s' % (thr, mid))

missing = [n for n in sorted(uses) if float(n) not in by_thr]
if missing:
    for n in missing:
        err('编号 %d 在 recovery_compass.json 里没有 entry(来源: %s)'
            % (n, ', '.join(uses[n])))
else:
    ok('give 用到的 %d 个编号全部在 entries 里找得到' % len(uses))

# ---------------------------------------------------- 3) 模型 + 贴图存在
for thr in sorted(by_thr):
    mid = by_thr[thr]
    name = mid.split(':', 1)[1].split('/')[-1]           # item/stone/<name>
    for tag, rp in (('源', RP_SRC), ('版本隔离', RP_DST)):
        mf = os.path.join(rp, 'assets', 'sweetdream', 'models', 'item', 'stone',
                          name + '.json')
        if not os.path.exists(mf):
            err('%s资源包缺模型: models/item/stone/%s.json' % (tag, name))
            continue
        try:
            md = json.load(io.open(mf, encoding='utf-8'))
        except Exception as e:
            err('%s模型 JSON 非法 %s: %s' % (tag, name, e))
            continue
        tex = (md.get('textures') or {}).get('layer0', '')
        if not tex:
            err('%s模型 %s 没有 layer0' % (tag, name))
            continue
        tp = os.path.join(rp, 'assets', tex.split(':', 1)[0], 'textures',
                          tex.split(':', 1)[1] + '.png')
        if not os.path.exists(tp):
            err('%s资源包缺贴图: %s' % (tag, tp))
        elif name in ('', None):
            err('模型名空了')
if not bad:
    ok('entries 全部指向存在的模型 + 贴图(%d 个)' % len(by_thr))

# ---------------------------------------------------- 4) 源 / 目标 字节一致
diff = 0
rel_list = [RC]
for thr in sorted(by_thr):
    name = by_thr[thr].split(':', 1)[1].split('/')[-1]
    rel_list.append('assets/sweetdream/models/item/stone/%s.json' % name)
    rel_list.append('assets/sweetdream/textures/item/stone/%s.png' % name)
for rel in rel_list:
    a = os.path.join(RP_SRC, *rel.split('/'))
    b = os.path.join(RP_DST, *rel.split('/'))
    if not os.path.exists(b):
        err('版本隔离目录缺: %s' % rel)
        diff += 1
    elif io.open(a, 'rb').read() != io.open(b, 'rb').read():
        err('源与版本隔离目录内容不一致: %s' % rel)
        diff += 1
if not diff:
    ok('源 / 版本隔离目录 %d 个文件字节一致' % len(rel_list))

print('---- 问题 %d 条' % len(bad))
sys.exit(1 if bad else 0)
