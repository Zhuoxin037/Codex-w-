# -*- coding: utf-8 -*-
"""
全包体检(独立于 check.py 的"横向"视角):
  A 计分项: 用了但没建 / 建了但没人用
  B 装备 id: give 里的 zx:[id] <-> names 表 / layer 表 / second 表
  C 每件装备的"标配文件"齐不齐(give / 技能 / 进度)
  D 重复与孤儿: 没人调用的函数 / 表里登记了但文件不存在
用法: python .workbuddy/_audit.py
"""
import re, io, sys
from pathlib import Path

ROOT = Path(r'D:/数据包')
PACKS = ['sweetdream', 'manacore-1.0.0']
NS = {'sweetdream': 'sweetdream', 'manacore-1.0.0': 'manacore'}

funcs = {}   # id -> path
for p in PACKS:
    d = ROOT / p / 'data'
    if not d.exists():
        continue
    for ns in d.iterdir():
        fd = ns / 'function'
        if not fd.exists():
            continue
        for f in fd.rglob('*.mcfunction'):
            funcs[f"{ns.name}:{f.relative_to(fd).as_posix()[:-len('.mcfunction')]}"] = f

def text(fid):
    if fid in funcs:
        try:
            return funcs[fid].read_text(encoding='utf-8')
        except Exception:
            return ''
    return ''

all_lines = []
for fid, fp in funcs.items():
    try:
        src = fp.read_text(encoding='utf-8')
    except Exception:
        continue
    for i, ln in enumerate(src.split('\n'), 1):
        s = ln.strip()
        if s and not s.startswith('#'):
            all_lines.append((fid, i, s))

print('=' * 74)
print('全包体检  函数 %d 个' % len(funcs))
print('=' * 74)

# ---------------- A 计分项 ----------------
created = set()
used = {}
add_obj = re.compile(r'scoreboard\s+objectives\s+add\s+([A-Za-z0-9_.]+)')
for fid, i, s in all_lines:
    for m in add_obj.finditer(s):
        created.add(m.group(1))

use_pats = [
    re.compile(r'scoreboard\s+players\s+(?:set|add|remove|reset|get|enable|operation)\s+\S+\s+([A-Za-z0-9_.]+)'),
    re.compile(r'scores?\s*=\s*\{([A-Za-z0-9_.]+)\s*='),
    re.compile(r'"objective"\s*:\s*"([A-Za-z0-9_.]+)"'),
    re.compile(r'\{o\s*:\s*"([A-Za-z0-9_.]+)"'),
    re.compile(r'\{o:\s*"([A-Za-z0-9_.]+)"'),
]
for fid, i, s in all_lines:
    for pat in use_pats:
        for m in pat.finditer(s):
            nm = m.group(1)
            if nm in ('manacore.math', 'manacore.meta'):
                continue
            used.setdefault(nm, set()).add(fid)

print('\n【A1】用了但没在 core/load 里 add 的计分项 —— 运行时"该命令静默失败/整函数作废"')
bad = sorted(n for n in used if n not in created)
if bad:
    for n in bad:
        where = sorted(used[n])[:3]
        print('   ✗ %-16s 用到它的: %s' % (n, ', '.join(where)))
else:
    print('   ✓ 0 条')

print('\n【A2】建了但全包没人写的计分项(可能是死代码/漏接线)')
dangling = sorted(n for n in created if n not in used)
for n in dangling:
    print('   · %s' % n)
if not dangling:
    print('   ✓ 0 条')

# ---------------- B 装备 id ----------------
ids = {}
give_of = {}
id_re = re.compile(r'zx\s*:\s*\[\s*"([a-z0-9_]+)"')
for fid, fp in funcs.items():
    if not fid.endswith('/give') and '/give' not in fid:
        continue
    try:
        src = fp.read_text(encoding='utf-8')
    except Exception:
        continue
    m = id_re.search(src)
    if m:
        ids[m.group(1)] = fid
        give_of[m.group(1)] = fid

names = {}
build = text('sweetdream:lib/reg/build')
for m in re.finditer(r'names\.([a-z0-9_]+)\s+set\s+value\s+"([^"]*)"', build):
    names[m.group(1)] = m.group(2)

layer_rows = []
for m in re.finditer(r'layer\s+append\s+value\s*\{([^}]*)\}', build):
    row = m.group(1)
    d = {}
    for k, v in re.findall(r'(\w+)\s*:\s*("(?:[^"\\]|\\.)*"|[-\w.]+)', row):
        d[k] = v.strip('"')
    layer_rows.append(d)

print('\n【B1】有 give 但 names 表没登记中文全名 —— 面板上只显示英文 id')
miss = sorted(i for i in ids if i not in names)
print('   %s' % ('✓ 0 条' if not miss else '   ✗ ' + ', '.join(miss)))

print('\n【B2】names 表登记了但没有 give(可能是改名/已删除的残留)')
ghost = sorted(n for n in names if n not in ids)
print('   %s' % ('✓ 0 条' if not ghost else '   · ' + ', '.join(ghost)))

# ---------------- C 观测镜 layer 表 ----------------
print('\n【C】观测镜「层数」表逐行体检(共 %d 行)' % len(layer_rows))
in_names = set(names)
for r in layer_rows:
    o, l, c, e = r.get('o', '?'), r.get('l', '?'), r.get('c', '?'), r.get('e', '?')
    prob = []
    if o not in created:
        prob.append('计分项 %s 没建' % o)
    if e != 'all' and e not in in_names:
        prob.append('e=%s 不在 names 表' % e)
    for k in ('o', 'l', 'c', 'e'):
        if k not in r:
            prob.append('缺字段 %s(宏参数不全 -> 整条不跑)' % k)
    print('   %-8s %-6s e=%-18s %s' % (l, o, e, ('✗ ' + '; '.join(prob)) if prob else '✓'))

# 有层数/计数机制但没登记进 layer 表的装备
print('\n【C2】 suspected: 有 zx.<前缀> 计分项在涨、但没进 layer 表(面板上看不见)')
layer_o = {r.get('o') for r in layer_rows}
cnt_re = re.compile(r'scoreboard players (?:add|set|remove|operation)\s+@s\s+(zx\.[a-z0-9_]+)')
freq = {}
for fid, i, s in all_lines:
    for m in cnt_re.finditer(s):
        freq.setdefault(m.group(1), set()).add(fid)
cand = []
for o, where in sorted(freq.items()):
    if o in layer_o or o.startswith(('zx.ap_t', 'zx.de_', 'zx.sv_', 'zx.mt_', 'zx.dash',
                                      'zx.ac_d', 'zx.up_', 'zx.regen', 'zx.meta', 'zx.ts_',
                                      'zx.freeze', 'zx.im_', 'zx.ball', 'zx.ol_', 'zx.stg')):
        continue
    if o in created:
        cand.append((o, len(where)))
for o, n in sorted(cand, key=lambda x: -x[1])[:20]:
    print('   · %-18s 被 %d 个文件写' % (o, n))
if not cand:
    print('   ✓ 0 条')

# ---------------- D 装备标配文件 ----------------
print('\n【D】每件装备的标配文件(缺 = 静默失效)')
rows = []
for eid, gfid in sorted(ids.items()):
    base = gfid.rsplit('/give', 1)[0]
    ns = gfid.split(':')[0]
    have_skill = f"{base}/skill" in funcs
    have_attack = f"{base}/attack" in funcs
    # 进度: 找同名 advancement
    adv_dir = ROOT / ('sweetdream' if ns == 'sweetdream' else 'manacore-1.0.0') / 'data' / ns / 'advancement'
    adv = None
    if adv_dir.exists():
        rel = gfid.split(':', 1)[1].rsplit('/give', 1)[0]
        p = adv_dir / (rel + '.json')
        adv = p if p.exists() else None
    rows.append((eid, have_skill, have_attack, bool(adv)))
no_adv = [r[0] for r in rows if not r[3]]
print('   没有同名 advancement 的(%d 件): %s' % (len(no_adv), ', '.join(no_adv) if no_adv else '—'))
no_atk = [r[0] for r in rows if not r[1] and not r[2]]
print('   既没 skill 也没 attack 的(%d 件): %s' % (len(no_atk), ', '.join(no_atk) if no_atk else '—'))

# ---------------- E 孤儿函数 ----------------
print('\n【E】没有任何地方调用的顶层函数(可能是拆件/入口文件, 仅供参考)')
called = set()
for fid, i, s in all_lines:
    for m in re.finditer(r'function\s+([a-z0-9_]+:[a-z0-9_./\-]+)', s):
        called.add(m.group(1))
for p in PACKS:
    for tf in (ROOT / p / 'data').rglob('tags/function/*.json'):
        try:
            import json
            j = json.loads(tf.read_text(encoding='utf-8'))
            for v in j.get('values', []):
                if isinstance(v, str):
                    called.add(v)
        except Exception:
            pass
orphan = []
for fid in sorted(funcs):
    if fid in called:
        continue
    tail = fid.split('/')[-1]
    # 玩家手敲 / 对外 API / 事件入口 / 生成件 不算孤儿
    if tail in ('load', 'tick', 'second', 'skill', 'attack', 'give', 'cast', 'observe',
                'tick_s', 'tick_go', 'snap', 'one', 'deal', 'with_from', 'go', 'menu',
                'diagnose', 'toggle', 'render', 'render_go', 'hit', 'fire', 'passive',
                'equip', 'unequip', 'init', 'noop', 'main'):
        continue
    if any(k in fid for k in ('/api/', ':api/', '/debug/', ':debug/', '/example/')):
        continue
    orphan.append(fid)
for o in orphan[:60]:
    print('   · %s' % o)
print('   共 %d 个' % len(orphan))
