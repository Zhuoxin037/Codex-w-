# -*- coding: utf-8 -*-
"""统计每刻可达函数的命令规模与重操作分布（静态估算）。

用途：定位"单 tick 里到底跑了多少命令 / 多少次实体 NBT 序列化"。
  - 从 core/tick 出发 BFS，返回 depth + 入口条件
  - 重操作分类（这些才是"卡一下"的真凶，条数少也可能很贵）：
      nbt_sel    选择器里带 nbt={...}      -> 每个候选实体完整 NBT 序列化
      data_get   data get/modify entity     -> 一次 NBT 序列化
      items_ent  items entity ...           -> 物品谓词匹配
      attribute  attribute get              -> 属性查询
      raw_at_e   裸 @e / @a（无 type/dx/distance 限制） -> 全实体遍历
      particle   particle 命令
      summon     summon
"""
import os
import re
import sys
from collections import defaultdict, deque

ROOT = r'D:\数据包'
PACKS = {
    'sweetdream': os.path.join(ROOT, 'sweetdream', 'data'),
    'manacore': os.path.join(ROOT, 'manacore-1.0.0', 'data'),
}
CALL = re.compile(r'(?:^|\s)(?:run\s+)?function\s+([a-z0-9_.\-]+:[a-z0-9_./\-]+)')

funcs = {}   # fid -> (path, [lines])
for ns, data in PACKS.items():
    fd = os.path.join(data, ns, 'function')
    if not os.path.isdir(fd):
        continue
    for dp, _, fs in os.walk(fd):
        for fn in fs:
            if not fn.endswith('.mcfunction'):
                continue
            full = os.path.join(dp, fn)
            rel = os.path.relpath(full, fd).replace('\\', '/')[:-11]
            funcs['%s:%s' % (ns, rel)] = (full, open(full, encoding='utf-8', errors='replace').read().split('\n'))


def body(fid):
    out = []
    for ln in funcs[fid][1]:
        s = ln.strip()
        if not s or s.startswith('#'):
            continue
        out.append(s)
    return out


def classify(s):
    """返回这行命中的重操作类别列表"""
    tags = []
    if re.search(r'nbt\s*=\s*\{', s):
        tags.append('nbt_sel')
    if re.search(r'data\s+(get|modify)\s+entity', s):
        tags.append('data_get')
    if re.search(r'\bitems\s+entity\b', s):
        tags.append('items_ent')
    if re.search(r'\battribute\s+\S+\s+get\b', s):
        tags.append('attribute')
    if re.match(r'^(execute\s+.*\s+)?(run\s+)?(tag\s+)?@[ea](\s|\[)', s) or re.search(r'(^|\s)(as|at|if entity|unless entity)\s+@[ea]\[', s):
        # 粗判：选择器里没有任何范围/类型限制
        for m in re.finditer(r'@[ea]\[([^\]]*)\]', s):
            inner = m.group(1)
            if not any(k in inner for k in ('type=', 'dx=', 'distance=', 'nbt=', 'tag=', 'scores=', 'predicate=')):
                tags.append('raw_sel')
                break
        else:
            if re.search(r'(^|\s)(as|at|if entity|unless entity)\s+@[ea](\s|$)', s):
                tags.append('raw_sel')
    if re.search(r'(^|\s)particle\s', s):
        tags.append('particle')
    if re.search(r'(^|\s)summon\s', s):
        tags.append('summon')
    return tags


def reach(roots, maxdepth=64):
    seen = {r: (0, '<ROOT>') for r in roots if r in funcs}
    q = deque(seen)
    while q:
        cur = q.popleft()
        d = seen[cur][0]
        if d >= maxdepth:
            continue
        for ln in body(cur):
            for m in CALL.finditer(ln):
                cal = m.group(1)
                if cal in funcs and cal not in seen:
                    seen[cal] = (d + 1, ln[:150])
                    q.append(cal)
    return seen


def report(label, roots):
    seen = reach(roots)
    print('\n' + '=' * 90)
    print('【%s】  可达函数 %d 个' % (label, len(seen)))
    print('=' * 90)
    tot = defaultdict(int)
    rows = []
    for fid in sorted(seen):
        lines = body(fid)
        c = defaultdict(int)
        for ln in lines:
            for t in classify(ln):
                c[t] += 1
        for k, v in c.items():
            tot[k] += v
        if c:
            rows.append((sum(c.values()), fid, seen[fid][0], c))
    print('全树重操作总计：')
    for k in ('nbt_sel', 'data_get', 'items_ent', 'attribute', 'raw_sel', 'particle', 'summon'):
        if tot[k]:
            print('   %-11s %4d' % (k, tot[k]))
    print('\n按重操作密度排序（越前面越值得看）：')
    rows.sort(key=lambda r: -(r[3].get('nbt_sel', 0) * 6 + r[3].get('data_get', 0) * 3
                             + r[3].get('items_ent', 0) * 2 + r[3].get('raw_sel', 0) * 2
                             + r[3].get('particle', 0)))
    for score, fid, d, c in rows[:22]:
        print('  [w%-3d] %-62s d%-2d  %s' % (score, fid[:62], d,
              ' '.join('%s=%d' % (k, c[k]) for k in ('nbt_sel', 'data_get', 'items_ent', 'raw_sel', 'particle') if c[k])))


report('每刻入口 core/tick', ['sweetdream:core/tick', 'manacore:core/tick'])
report('一次伤害投递', ['sweetdream:api/damage'])
report('法球命中', ['sweetdream:projectile/ball/hit'])
report('偏振光每秒结算', ['sweetdream:equipment/staff/polarized_light/tick'])
report('偏振光一次铺线', ['sweetdream:equipment/staff/polarized_light/beam'])
