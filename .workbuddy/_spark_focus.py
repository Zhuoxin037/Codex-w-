#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""定向聚合：Entity.saveWithoutId 被谁调用 / 服务器 tick 时间怎么分"""
import sys, struct
from collections import defaultdict

F = sys.argv[1] if len(sys.argv) > 1 else 'spark.bin'
data = open(F, 'rb').read()

def rv(b, i):
    r = 0; s = 0
    while True:
        x = b[i]; i += 1
        r |= (x & 0x7F) << s
        if not (x & 0x80): return r, i
        s += 7

def parse(buf):
    out = []; i = 0; n = len(buf)
    while i < n:
        k, i = rv(buf, i); fn = k >> 3; wt = k & 7
        if wt == 0: v, i = rv(buf, i); out.append((fn, wt, v))
        elif wt == 1: out.append((fn, wt, struct.unpack('<d', buf[i:i+8])[0])); i += 8
        elif wt == 2: ln, i = rv(buf, i); out.append((fn, wt, buf[i:i+ln])); i += ln
        elif wt == 5: out.append((fn, wt, struct.unpack('<f', buf[i:i+4])[0])); i += 4
        else: raise ValueError(wt)
    return out

g = lambda m, fn, wt=None: [v for (f, w, v) in m if f == fn and (wt is None or w == wt)]
def one(m, fn, d=None):
    v = g(m, fn); return v[0] if v else d
def st(v): return v.decode('utf-8', 'replace') if isinstance(v, bytes) else ''
def pd(b): return list(struct.unpack('<%dd' % (len(b)//8), b[:len(b)//8*8]))
def pi(b):
    o = []; i = 0
    while i < len(b): v, i = rv(b, i); o.append(v)
    return o
def rints(m, fn):
    o = []
    for f, w, v in m:
        if f != fn: continue
        if w == 0: o.append(v)
        elif w == 2: o.extend(pi(v))
    return o
def rdbl(m, fn):
    o = []
    for f, w, v in m:
        if f != fn: continue
        if w == 1: o.append(v)
        elif w == 2: o.extend(pd(v))
    return o

class N:
    __slots__ = ('cls', 'mth', 'line', 'times', 'refs', 'kids', 'parent', 'total', 'self')
    def __init__(s, c, m, l, t, r):
        s.cls = c; s.mth = m; s.line = l; s.times = t; s.refs = r
        s.kids = []; s.parent = None; s.total = sum(t); s.self = s.total

top = parse(data)
allnodes = []
for tb in g(top, 2):
    p = parse(tb)
    flat = []
    for c in g(p, 3, 2):
        q = parse(c)
        flat.append(N(st(one(q, 3)), st(one(q, 4)), one(q, 6, 0) or 0, rdbl(q, 8), rints(q, 9)))
    for nd in flat:
        for r in nd.refs:
            if 0 <= r < len(flat):
                nd.kids.append(flat[r]); flat[r].parent = nd
    for nd in flat:
        nd.self = nd.total - sum(k.total for k in nd.kids)
    allnodes.extend(flat)

grand = sum(n.total for n in allnodes if n.parent is None)
busy = grand  # 用 park 的 self 反推
park = sum(n.self for n in allnodes if n.mth == 'park')
print('总权重 %.0f   空闲(park) %.0f (%.1f%%)   忙 %.0f (%.1f%%)'
      % (grand, park, park/grand*100, grand-park, (grand-park)/grand*100))
busy = grand - park

def pct(x): return '%.2f%%' % (x / busy * 100)

# ---------- 1) Entity.saveWithoutId 被谁调 ----------
SAVE = [n for n in allnodes if n.cls.endswith('class_1297') and n.mth == 'method_5647']
print('\n=== Entity.saveWithoutId(class_1297.method_5647) 出现 %d 次，合计 %.2f%% (占忙时) ===' % (len(SAVE), sum(n.total for n in SAVE)/busy*100))
bypar = defaultdict(lambda: [0, 0.0])
for n in SAVE:
    p = n.parent
    key = '%s.%s' % (p.cls.split('.')[-1] if p else '?', p.mth if p else '?')
    bypar[key][0] += 1
    bypar[key][1] += n.total
for k, (cnt, t) in sorted(bypar.items(), key=lambda kv: -kv[1][1]):
    print('  %7.2f%%  x%-3d  <- 父: %s' % (t/busy*100, cnt, k))

# ---------- 2) 只看 5 层以上「到 saveWithoutId」的调用者链 ----------
print('\n=== saveWithoutId 之上的关键调用者（跳过 codec 帧）===')
def trim(nd, depth=26):
    out = []
    while nd is not None and len(out) < depth:
        out.append('%s.%s' % (nd.cls.split('.')[-1], nd.mth) if nd.cls else nd.mth)
        nd = nd.parent
    return ' <- '.join(out)

seen = set()
for n in sorted(SAVE, key=lambda x: -x.total)[:10]:
    t = trim(n)
    if t in seen: continue
    seen.add(t)
    print('\n  %.2f%%' % (n.total/busy*100))
    for i, seg in enumerate(t.split(' <- ')):
        print('     %s%s' % ('└ ' if i == 0 else '| ', seg))

# ---------- 3) 服务器 tick 主要分支 ----------
print('\n=== 服务器 tick 一级分支（method_3813 的直接子节点）===')
for n in allnodes:
    if n.mth == 'method_3813' and n.kids:
        tot = sum(k.total for k in n.kids)
        for k in sorted(n.kids, key=lambda x: -x.total):
            print('  %7.2f%%  %s.%s' % (k.total/busy*100, k.cls.split('.')[-1], k.mth))

# ---------- 4) 所有 net.minecraft 包 self 排名 ----------
print('\n=== net.minecraft.* 自耗时 TOP 25 ===')
mc = [(n.cls, n.mth, n.self) for n in allnodes if n.cls.startswith('net.minecraft')]
agg = defaultdict(float)
for c, m, v in mc: agg[(c.split('.')[-1], m)] += v
for (c, m), v in sorted(agg.items(), key=lambda kv: -kv[1])[:25]:
    print('  %7.2f%%  %-34s %s' % (v/busy*100, m, c))
