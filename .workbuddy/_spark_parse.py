#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""解析 spark sampler protobuf -> 调用树自耗时排行
schema: spark/spark_sampler.proto (SamplerData / SamplerMetadata / ThreadNode / StackTraceNode)
纯手写 wire-format 解析，不依赖 protobuf 库。
"""
import sys, struct, io
from collections import defaultdict

F = sys.argv[1] if len(sys.argv) > 1 else 'spark.bin'
data = open(F, 'rb').read()
print('file %s  %d bytes' % (F, len(data)))

# ---------------- 通用 wire 解析 ----------------
def read_varint(b, i):
    r = 0; s = 0
    while True:
        x = b[i]; i += 1
        r |= (x & 0x7F) << s
        if not (x & 0x80):
            return r, i
        s += 7

def parse(buf):
    """返回 [(field_no, wire_type, value)]，value: varint->int, len->bytes, fixed64->float, fixed32->int"""
    out = []
    i = 0; n = len(buf)
    while i < n:
        key, i = read_varint(buf, i)
        fn = key >> 3; wt = key & 7
        if wt == 0:
            v, i = read_varint(buf, i)
            out.append((fn, wt, v))
        elif wt == 1:
            out.append((fn, wt, struct.unpack('<d', buf[i:i+8])[0])); i += 8
        elif wt == 2:
            ln, i = read_varint(buf, i)
            out.append((fn, wt, buf[i:i+ln])); i += ln
        elif wt == 5:
            out.append((fn, wt, struct.unpack('<f', buf[i:i+4])[0])); i += 4
        else:
            raise ValueError('wire type %d at %d' % (wt, i))
    return out

def get(multi, fn, wt=None):
    return [v for (f, w, v) in multi if f == fn and (wt is None or w == wt)]

def one(multi, fn, default=None):
    v = get(multi, fn)
    return v[0] if v else default

def s(v):
    return v.decode('utf-8', 'replace') if isinstance(v, bytes) else ''

def packed_doubles(b):
    return list(struct.unpack('<%dd' % (len(b)//8), b[:len(b)//8*8]))

def packed_ints(b):
    out = []; i = 0
    while i < len(b):
        v, i = read_varint(b, i); out.append(v)
    return out

def rep_ints(multi, fn):
    """repeated int32 可能 packed(wire2) 也可能逐条(wire0)"""
    out = []
    for f, w, v in multi:
        if f != fn: continue
        if w == 0: out.append(v)
        elif w == 2: out.extend(packed_ints(v))
    return out

def rep_doubles(multi, fn):
    out = []
    for f, w, v in multi:
        if f != fn: continue
        if w == 1: out.append(v)
        elif w == 2: out.extend(packed_doubles(v))
    return out

# ---------------- 顶层 ----------------
top = parse(data)
meta_b = one(top, 1)
threads_b = get(top, 2)
windows = rep_ints(top, 6)

print('\n=== metadata ===')
if meta_b:
    md = parse(meta_b)
    def mi(fn): 
        v = one(md, fn); return v
    creator = one(md, 1)
    if creator:
        cd = parse(creator)
        print('  creator : %s (%s)' % (s(one(cd, 2)), s(one(cd, 3))))
    import datetime
    st = mi(2); et = mi(11)
    print('  start   : %s' % datetime.datetime.fromtimestamp(st/1000).strftime('%Y-%m-%d %H:%M:%S'))
    print('  end     : %s' % datetime.datetime.fromtimestamp(et/1000).strftime('%Y-%m-%d %H:%M:%S'))
    print('  interval: %s ms' % mi(3))
    print('  windows : %s   (time_windows=%d)' % (mi(12), len(windows)))
    print('  mode    : %s (0=EXECUTION 1=ALLOCATION 2=LOCK)' % mi(15))
    print('  engine  : %s (0=JAVA 1=ASYNC)  ver=%s' % (mi(16), s(mi(17) or b'')))
    cm = one(md, 6)
    if cm: print('  comment : %s' % s(cm))
    # thread dumper
    td = one(md, 4)
    if td:
        tdp = parse(td)
        print('  dumper  : type=%s' % one(tdp, 1))
    da = one(md, 5)
    if da:
        dap = parse(da)
        print('  aggr    : type=%s grouper=%s' % (one(dap, 1), one(dap, 2)))

print('\n=== threads (%d) ===' % len(threads_b))

class Node:
    """children_refs 是**同一线程扁平数组里的下标**，不是嵌套子消息 (proto3 里 1/2 已 reserved)"""
    __slots__ = ('cls', 'mth', 'line', 'times', 'refs', 'total', 'kids')
    def __init__(self, cls, mth, line, times, refs):
        self.cls = cls; self.mth = mth; self.line = line
        self.times = times; self.refs = refs
        self.total = sum(times); self.kids = []

threads = []
for tb in threads_b:
    p = parse(tb)
    name = s(one(p, 1))
    times = rep_doubles(p, 4)
    tn = Node('<thread>', name, 0, times, [])
    flat = []
    for c in get(p, 3, 2):
        q = parse(c)
        flat.append(Node(s(one(q, 3)), s(one(q, 4)), one(q, 6, 0),
                         rep_doubles(q, 8), rep_ints(q, 9)))
    tn.kids = flat          # 扁平，稍后按 refs 连边
    threads.append((tn, flat))

# 连边 + 找根
roots = []
for tn, flat in threads:
    has_parent = set()
    for nd in flat:
        for r in nd.refs:
            if 0 <= r < len(flat):
                nd.kids.append(flat[r])
                has_parent.add(r)
    roots.extend([flat[i] for i in range(len(flat)) if i not in has_parent])
# 用包装结构统一后续遍历
class Wrap:
    __slots__ = ('cls', 'mth', 'kids', 'total')
    def __init__(self, cls, mth, kids, total):
        self.cls = cls; self.mth = mth; self.kids = kids; self.total = total
threads_w = []
for tn, flat in threads:
    has_parent = set()
    for nd in flat:
        for r in nd.refs:
            if 0 <= r < len(flat):
                has_parent.add(r)
    rts = [flat[i] for i in range(len(flat)) if i not in has_parent]
    rt_tot = sum(r.total for r in rts)
    threads_w.append(Wrap('<thread>', tn.mth, rts, rt_tot))
threads = threads_w

# 时间单位: spark times 是**每个窗口内的秒数**? 实际是采样点权重*interval。统一按“占比”处理
def fmt(d): return '%.2f%%' % (d * 100)

grand = sum(t.total for t in threads)
print('总累计时间(所有权重) %.3f  窗口数 %d' % (grand, len(windows)))
for t in sorted(threads, key=lambda x: -x.total)[:12]:
    print('  %-34s %10.3f  %s' % (t.mth, t.total, fmt(t.total / grand if grand else 0)))

# ---------------- 自耗时聚合 ----------------
self_time = defaultdict(float)     # (cls, mth) -> self
total_time = defaultdict(float)    # (cls, mth) -> total(含子)
lines_of = defaultdict(lambda: defaultdict(float))

def walk(nd, agg_self, agg_total, agg_line):
    agg_total[(nd.cls, nd.mth)] += nd.total
    kids = sum(k.total for k in nd.kids)
    agg_self[(nd.cls, nd.mth)] += nd.total - kids
    if nd.line:
        agg_line[(nd.cls, nd.mth, nd.line)] += nd.total - kids
    for k in nd.kids:
        walk(k, agg_self, agg_total, agg_line)

S = defaultdict(float); T = defaultdict(float); L = defaultdict(float)
for t in threads:
    for k in t.kids:
        walk(k, S, T, L)

def show(agg, label, topn=30, grand_denom=None):
    den = grand_denom or grand
    print('\n=== %s (前 %d) ===' % (label, topn))
    for (cls, mth), v in sorted(agg.items(), key=lambda kv: -kv[1])[:topn]:
        if v <= 0: continue
        print('  %8.2f%%  %-46s %s' % (v/den*100, mth[:46], cls))

show(S, '自耗时 SELF')
show(T, '总耗时 TOTAL(含子调用)', 20)

print('\n=== 热点行号(自耗时前 20) ===')
for (cls, mth, ln), v in sorted(L.items(), key=lambda kv: -kv[1])[:20]:
    if v <= 0: continue
    print('  %8.2f%%  %s#%d  %s' % (v/grand*100, mth[:40], ln, cls))

# ---------------- 关键词定位 ----------------
KW = ['nbt', 'NbtIo', 'EntityStorage', 'save', 'writeCompressed', 'gzip',
      'Scoreboard', 'CommandFunction', 'CommandDispatcher', 'parse',
      'ServerLevel.tick', 'MinecraftServer.tickServer', 'chunk',
      'serialize', 'CompoundTag', 'StringTag', 'ListTag']
print('\n=== 关键词命中(自耗时) ===')
for kw in KW:
    tot = sum(v for (c, m), v in S.items() if kw.lower() in (c + ' ' + m).lower())
    tt  = sum(v for (c, m), v in T.items() if kw.lower() in (c + ' ' + m).lower())
    if tot or tt:
        print('  %-22s self %6.2f%%   total %6.2f%%' % (kw, tot/grand*100, tt/grand*100))
