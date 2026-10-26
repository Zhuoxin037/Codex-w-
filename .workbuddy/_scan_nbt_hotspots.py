# -*- coding: utf-8 -*-
"""
扫描全包「高频实体 NBT 写入」热点。

原理:
  tag add/remove、data modify entity ... 都是**写实体 NBT** 的操作。
  写一次 => 该实体所在 chunk 变脏 => 服务端在 tick 末尾 EntityStorage.save()
  把整份 chunk 重写压缩写盘(实测 JFR: 法球那次 53.4% 的服务端样本卡在这里)。

所以要从 tick 入口做调用图可达性, 把「每刻都会跑的」和「每秒/事件触发的」分开。

用法: python _scan_nbt_hotspots.py [--all]
"""
import os, re, sys, json
from collections import defaultdict, deque

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # D:\数据包

PACKS = {
    'sweetdream': os.path.join(ROOT, 'sweetdream', 'data'),
    'manacore':   os.path.join(ROOT, 'manacore-1.0.0', 'data'),
}

CALL_RE = re.compile(r'(?:^|\s)(?:run\s+)?function\s+([a-z0-9_.-]+:[a-z0-9_./-]+)')
# 写实体 NBT 的行
WRITE_TAG_RE = re.compile(r'(?:^|\s)tag\s+(\S+)\s+(add|remove)\s+(\S+)')
WRITE_DATA_RE = re.compile(r'data\s+modify\s+entity\s+(\S+)\s+(\S+)')
WRITE_TAGS_NBT_RE = re.compile(r'data\s+merge\s+entity\s+(\S+)\s+(\S+)')


def func_id(ns, path):
    return '%s:%s' % (ns, path)


def collect():
    """返回 {fid: {'file':..., 'lines':[(no, text)]}}"""
    funcs = {}
    for ns, data in PACKS.items():
        fdir = os.path.join(data, ns, 'function')
        if not os.path.isdir(fdir):
            continue
        for dirpath, _, files in os.walk(fdir):
            for fn in files:
                if not fn.endswith('.mcfunction'):
                    continue
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, fdir).replace('\\', '/')[:-len('.mcfunction')]
                fid = func_id(ns, rel)
                with open(full, 'r', encoding='utf-8', errors='replace') as f:
                    lines = f.read().split('\n')
                funcs[fid] = {'file': full, 'lines': lines}
    return funcs


def build_graph(funcs):
    """edges[caller] = [(callee, condition_text)]"""
    edges = defaultdict(list)
    for fid, info in funcs.items():
        for no, ln in enumerate(info['lines'], 1):
            s = ln.strip()
            if not s or s.startswith('#'):
                continue
            for m in CALL_RE.finditer(s):
                edges[fid].append((m.group(1), s, no))
    return edges


def reachable(roots, edges, funcs, maxdepth=64):
    """BFS 返回 {fid: (depth, parent, entry_line)}"""
    seen = {}
    q = deque()
    for r in roots:
        if r in funcs:
            seen[r] = (0, None, '<ROOT>')
            q.append(r)
    while q:
        cur = q.popleft()
        d = seen[cur][0]
        if d >= maxdepth:
            continue
        for callee, _s, _no in edges.get(cur, ()):
            if callee not in funcs:
                continue
            if callee in seen:
                continue
            seen[callee] = (d + 1, cur, _s)
            q.append(callee)
    return seen


def writes_in(fid, funcs):
    out = []
    info = funcs[fid]
    for no, ln in enumerate(info['lines'], 1):
        s = ln.strip()
        if not s or s.startswith('#'):
            continue
        m = WRITE_TAG_RE.search(s)
        if m:
            out.append((no, 'TAG %s %s %s' % (m.group(1), m.group(2), m.group(3)), s))
            continue
        m = WRITE_DATA_RE.search(s)
        if m:
            out.append((no, 'DATA entity %s' % m.group(1), s))
            continue
        m = WRITE_TAGS_NBT_RE.search(s)
        if m:
            out.append((no, 'MERGE entity %s' % m.group(1), s))
    return out


def main():
    funcs = collect()
    edges = build_graph(funcs)
    print('函数总数: %d' % len(funcs))

    ROOTS = {
        'EVERY_TICK': ['sweetdream:core/tick'],
        'EVERY_SECOND': ['sweetdream:lib/second'],
    }
    # manacore 的 tick 入口
    for cand in ('manacore:core/tick', 'manacore:tick', 'manacore:main/tick'):
        if cand in funcs:
            ROOTS['EVERY_TICK'].append(cand)
            break

    for label, roots in ROOTS.items():
        seen = reachable(roots, edges, funcs)
        print('\n' + '=' * 78)
        print('【%s】可达函数 %d 个 (roots=%s)' % (label, len(seen), roots))
        print('=' * 78)
        total = 0
        rows = []
        for fid in sorted(seen):
            ws = writes_in(fid, funcs)
            if not ws:
                continue
            total += len(ws)
            rows.append((fid, seen[fid][0], seen[fid][2], ws))
        print('带 NBT 写的函数 %d 个, 写点 %d 处\n' % (len(rows), total))
        for fid, depth, entry, ws in rows:
            gated = '闸' if re.search(r'\bmatches\b', entry) else '无闸'
            print('-- %-58s [d%d][%s]' % (fid, depth, gated))
            print('   入口: %s' % entry[:170])
            for no, kind, s in ws:
                print('     %4d | %-46s | %s' % (no, kind, s[:150]))
        print()


if __name__ == '__main__':
    main()
