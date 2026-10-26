#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 spark sampler protobuf 里打出「热点调用链」：谁调用了 NBT 编码"""
import sys, struct
from collections import defaultdict

F = sys.argv[1] if len(sys.argv) > 1 else 'spark.bin'
data = open(F, 'rb').read()

def read_varint(b, i):
    r = 0; s = 0
    while True:
        x = b[i]; i += 1
        r |= (x & 0x7F) << s
        if not (x & 0x80): return r, i
        s += 7

def parse(buf):
    out = []; i = 0; n = len(buf)
    while i < n:
        key, i = read_varint(buf, i)
        fn = key >> 3; wt = key & 7
        if wt == 0:
            v, i = read_varint(buf, i); out.append((fn, wt, v))
        elif wt == 1:
            out.append((fn, wt, struct.unpack('<d', buf[i:i+8])[0])); i += 8
        elif wt == 2:
            ln, i = read_varint(buf, i); out.append((fn, wt, buf[i:i+ln])); i += ln
        elif wt == 5:
            out.append((fn, wt, struct.unpack('<f', buf[i:i+4])[0])); i += 4
        else:
            raise ValueError(wt)
    return out

def get(m, fn, wt=None): return [v for (f, w, v) in m if f == fn and (wt is None or w == wt)]
def one(m, fn, d=None):
    v = get(m, fn); return v[0] if v else d
def st(v): return v.decode('utf-8', 'replace') if isinstance(v, bytes) else ''
def pd(b): return list(struct.unpack('<%dd' % (len(b)//8), b[:len(b)//8*8]))
def pi(b):
    o = []; i = 0
    while i < len(b):
        v, i = read_varint(b, i); o.append(v)
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

top = parse(data)
threads_b = get(top, 2)

class N:
    __slots__ = ('cls', 'mth', 'line', 'times', 'refs', 'kids', 'parent', 'total', 'self')
    def __init__(s, cls, mth, line, times, refs):
        s.cls = cls; s.mth = mth; s.line = line; s.times = times; s.refs = refs
        s.kids = []; s.parent = None; s.total = sum(times); s.self = sum(times)

allroots = []
grand = 0.0
for tb in threads_b:
    p = parse(tb)
    tname = st(one(p, 1))
    flat = []
    for c in get(p, 3, 2):
        q = parse(c)
        flat.append(N(st(one(q, 3)), st(one(q, 4)), one(q, 6, 0) or 0, rdbl(q, 8), rints(q, 9)))
    for nd in flat:
        for r in nd.refs:
            if 0 <= r < len(flat):
                nd.kids.append(flat[r])
                flat[r].parent = nd
    for nd in flat:
        nd.self = nd.total - sum(k.total for k in nd.kids)
    roots = [flat[i] for i in range(len(flat)) if flat[i].parent is None]
    g = sum(r.total for r in roots)
    grand += g
    print('[thread] %-24s 根节点 %d  累计 %.1f' % (tname, len(roots), g))
    allroots.append((tname, roots))

def chain(nd):
    out = []
    while nd is not None:
        nm = nd.mth or '<root>'
        out.append('%s.%s' % (nd.cls.split('.')[-1], nm) if nd.cls else nm)
        nd = nd.parent
    return ' <- '.join(reversed(out))

# ---- 1) 自耗时最高的叶子，打印完整调用链 ----
leaves = []
def collect(nd):
    if not nd.kids or nd.self > 0:
        if nd.self > 0:
            leaves.append(nd)
    for k in nd.kids:
        collect(k)
for _t, roots in allroots:
    for r in roots:
        collect(r)
leaves.sort(key=lambda x: -x.self)
print('\n=== 自耗时 TOP 25（完整调用链） 总权重 %.0f ===' % grand)
seen = set()
shown = 0
for nd in leaves:
    c = chain(nd)
    if c in seen: continue
    seen.add(c)
    print('\n  %6.2f%%  self=%.1f' % (nd.self/grand*100, nd.self))
    parts = c.split(' <- ')
    for i, pp in enumerate(parts):
        print('        ' + '  '*0 + ('└ ' if i == len(parts)-1 else '| ') + pp)
    shown += 1
    if shown >= 25: break

# ---- 2) 按关键字找「谁把时间花在 NBT/codec 上」----
print('\n\n=== 关键字子树 & 其根路径 ===')
KW = ['codec', 'Codec', 'class_2487', 'class_5379', 'class_2499', 'class_2528',
      'NbtIo', 'EntityStorage', 'saveWithoutId', 'ChunkMap', 'ServerChunkCache',
      'PlayerList', 'ServerLevel.tick', 'MinecraftServer', 'CommandFunction',
      'command', 'Command', 'Scoreboard']
for kw in KW:
    hits = [nd for nd in leaves if kw in nd.cls or kw in nd.mth]
    if not hits: continue
    tot = sum(h.self for h in hits)
    if tot/grand < 0.005: continue
    h = max(hits, key=lambda x: x.self)
    print('\n  [%s] self 合计 %.2f%%  最多的那条链:' % (kw, tot/grand*100))
    print('      ' + chain(h))

# ---- 3) 悬停: 找出「class_2487 的父调用」分布 ----
print('\n\n=== 父调用分布：谁在调 CompoundTag(class_2487) 相关 ===')
agg = defaultdict(float)
def walk(nd):
    if 'class_2487' in nd.cls or 'codec' in nd.cls.lower():
        p = nd.parent
        agg['%s.%s' % (p.cls.split('.')[-1] if p and p.cls else '?', p.mth if p else '?')] += nd.self
    for k in nd.kids: walk(k)
for _t, roots in allroots:
    for r in roots: walk(r)
for k, v in sorted(agg.items(), key=lambda kv: -kv[1])[:15]:
    print('  %6.2f%%  %s' % (v/grand*100, k))
