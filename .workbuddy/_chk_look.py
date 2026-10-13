# -*- coding: utf-8 -*-
"""守观测镜(equipment/tool/look) 的"多处同一份东西"不要走散。

为什么需要: 2026-10-05 实测两个 bug 都是"改了一处、漏了另一处":
  ① give 加了 item_model, 但右键消耗后还回来的那个(return_item)没加 -> 用一次就没模型
  ② 资源包改了源(D:/数据包/sweetdream_rp_完整版), 版本隔离目录(.minecraft/versions/*/
     resourcepacks/sweetdream_rp_完整版)是**另一份拷贝**, 不同步 -> 游戏里紫黑方块

本脚本离线抓这六类:
  1. give / return_item 三处 recovery_compass[...] 的组件列表必须逐字一致
  2. item_model 引用的 assets/<ns>/items/<id>.json 必须存在
  3. 模型文件存在 / JSON 合法 / elements 非空
  4. 贴图存在 / PNG 头合法 / 尺寸是 2 的幂
  5. 源资源包 与 版本隔离目录 的对应文件必须字节一致（★最容易忘的一步）
  6. 标签字体图集（普通 + 淡色两份字形 / 图集尺寸 / lang 的淡色键）—— 2026-10-06 加
"""
import io, os, re, sys, json, struct

ROOT = r'D:\数据包'
RP_SRC = os.path.join(ROOT, 'sweetdream_rp_完整版')
RP_DST = (r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10'
          r'\resourcepacks\sweetdream_rp_完整版')
LOOK = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                    'equipment', 'tool', 'look')

bad = []


def err(msg):
    bad.append(msg)
    print('[×] ' + msg)


def ok(msg):
    print('[ok] ' + msg)


# ---------------------------------------------------- 1) 三处组件列表一致
def comps(line):
    a = line.find('recovery_compass[')
    b = line.rfind(']')
    return line[a + len('recovery_compass['):b] if a >= 0 else None


lists = {}
for fn in ('give.mcfunction', 'return_item.mcfunction'):
    p = os.path.join(LOOK, fn)
    for i, line in enumerate(io.open(p, encoding='utf-8').read().split('\n'), 1):
        c = comps(line)
        if c is not None:
            lists['%s:%d' % (fn, i)] = c

if len(lists) < 2:
    err('只找到 %d 处观测镜组件列表(应有 3 处)' % len(lists))
else:
    base_k = sorted(lists)[0]
    for k, v in sorted(lists.items()):
        if v != lists[base_k]:
            err('%s 的组件列表和 %s 不一致' % (k, base_k))
            print('      %s: %s' % (base_k, lists[base_k][:150]))
            print('      %s: %s' % (k, v[:150]))
    if len(set(lists.values())) == 1:
        ok('%d 处组件列表完全一致' % len(lists))

# ---------------------------------------------------- 2) item_model 引用存在
m = re.search(r'item_model="([\w:.\-]+)"', lists.get('give.mcfunction:16', '')
              or next(iter(lists.values()), ''))
if not m:
    err('give 里没找到 item_model')
else:
    ref = m.group(1)
    ns, path = ref.split(':', 1) if ':' in ref else ('minecraft', ref)
    for tag, rp in (('源', RP_SRC), ('版本隔离', RP_DST)):
        f = os.path.join(rp, 'assets', ns, 'items', path + '.json')
        if not os.path.exists(f):
            err('%s资源包缺 item model 定义: %s' % (tag, f))
        else:
            json.load(io.open(f, encoding='utf-8'))
            ok('%s items/%s.json 存在且 JSON 合法' % (tag, path))

# ---------------------------------------------------- 3) 模型文件
for tag, rp in (('源', RP_SRC), ('版本隔离', RP_DST)):
    f = os.path.join(rp, 'assets', 'sweetdream', 'models', 'item', 'look.json')
    if not os.path.exists(f):
        err('%s资源包缺模型: %s' % (tag, f))
        continue
    d = json.load(io.open(f, encoding='utf-8'))
    if not d.get('elements'):
        err('%s模型 elements 为空: %s' % (tag, f))
    else:
        ok('%s模型 %d elements' % (tag, len(d['elements'])))
    # 包里可用模型的共同特征: 自带 display(不依赖 parent)
    if not d.get('display'):
        err('%s模型没有 display(包里可用模型都是自带 display, 不靠 parent)' % tag)
    # 贴图键必须是具名的(数字键 "0" 在包里没有先例)
    for k in (d.get('textures') or {}):
        if k.isdigit():
            err('%s模型用了数字贴图键 "%s"(包里全用具名键)' % (tag, k))

# ---------------------------------------------------- 4) 贴图
for tag, rp in (('源', RP_SRC), ('版本隔离', RP_DST)):
    f = os.path.join(rp, 'assets', 'sweetdream', 'textures', 'item', 'look.png')
    if not os.path.exists(f):
        err('%s资源包缺贴图: %s' % (tag, f))
        continue
    d = io.open(f, 'rb').read()
    if d[:8] != b'\x89PNG\r\n\x1a\n':
        err('%s贴图不是合法 PNG' % tag)
        continue
    w, h, bd, ct = struct.unpack('>IIBB', d[16:26])
    if (w & (w - 1)) or (h & (h - 1)):
        err('%s贴图尺寸不是 2 的幂: %dx%d' % (tag, w, h))
    else:
        ok('%s贴图 %dx%d colortype=%d' % (tag, w, h, ct))

# ---------------------------------------------------- 5) 源 / 目标 字节一致
#   ★ 2026-10-12 补两行: O06 之后 items/look.json 指向的是 `sweetdream:item/vanilla/look`,
#     真正渲染用的模型/贴图挪进了 `models|textures/item/vanilla/` —— 只守 items/look.json
#     会漏掉"模型/贴图没同步过去"这一半(2026-10-11 实测: 版本隔离副本缺整个 vanilla/ 目录,
#     items/look.json 也还指着旧的 item/look, 而这条规则当时只报了 items/look.json)。
diff = 0
for rel in ['assets/sweetdream/items/look.json',
            'assets/sweetdream/models/item/look.json',
            'assets/sweetdream/models/item/vanilla/look.json',
            'assets/sweetdream/textures/item/look.png',
            'assets/sweetdream/textures/item/vanilla/look.png',
            # 标签字体（2026-10-06 加：图标"剩余<=3秒变淡"要用新的淡色字形）
            'assets/sweetdream/font/icons.json',
            'assets/sweetdream/textures/font/icons.png',
            'assets/sweetdream/lang/zh_cn.json',
            'assets/sweetdream/lang/en_us.json']:
    a = os.path.join(RP_SRC, *rel.split('/'))
    b = os.path.join(RP_DST, *rel.split('/'))
    if not os.path.exists(b):
        err('版本隔离目录缺: %s' % rel)
    elif io.open(a, 'rb').read() != io.open(b, 'rb').read():
        err('源与版本隔离目录内容不一致: %s' % rel)
        diff += 1
if not diff:
    ok('源 / 版本隔离目录 %d 个文件字节一致' % 9)

# ---------------------------------------------------- 6) 标签字体图集（普通 + 淡色）
ORDER = ['yuanhai', 'liuhuo', 'yehuo', 'shixin', 'dream']
fj = os.path.join(RP_SRC, 'assets', 'sweetdream', 'font', 'icons.json')
fpng = os.path.join(RP_SRC, 'assets', 'sweetdream', 'textures', 'font', 'icons.png')
try:
    font = json.load(io.open(fj, encoding='utf-8'))
    chars = ''.join(p.get('chars', [''])[0] for p in font.get('providers', [])
                    if p.get('type') == 'bitmap')
except Exception as e:
    err('icons.json 读不了: %s' % e)
    chars = ''
if len(chars) < 2 * len(ORDER):
    err('字体图集只映射了 %d 个字形（应 >= %d：5 普通 + 5 淡色）' % (len(chars), 2 * len(ORDER)))
else:
    ok('字体字形 %d 个（含 5 个淡色 U+E005..E009）' % len(chars))
if not os.path.exists(fpng):
    err('缺字体图集: %s' % fpng)
else:
    d = io.open(fpng, 'rb').read()
    if d[:8] != b'\x89PNG\r\n\x1a\n':
        err('字体图集不是合法 PNG')
    else:
        w, h, bd, ct = struct.unpack('>IIBB', d[16:26])
        cols = len(chars) or 1
        if w != 32 * cols or h != 32:
            err('字体图集尺寸 %dx%d 与 %d 个字形对不上（应 %dx32）' % (w, h, cols, 32 * cols))
        else:
            ok('字体图集 %dx%d colortype=%d' % (w, h, ct))
# 淡色字形必须在 lang 里有键（缺了会退化成 fallback 字符，字形可能不对）
for lang in ('zh_cn', 'en_us'):
    lp = os.path.join(RP_SRC, 'assets', 'sweetdream', 'lang', lang + '.json')
    tab = json.load(io.open(lp, encoding='utf-8'))
    missing = [m for m in ORDER if ('sweetdream.icon.dim.' + m) not in tab]
    if missing:
        err('%s.json 缺淡色字形键: %s' % (lang, ', '.join(missing)))
    else:
        ok('%s.json 淡色字形键齐（5 个）' % lang)

print('---- 问题 %d 条' % len(bad))
sys.exit(1 if bad else 0)
