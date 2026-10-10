#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""临时审计脚本: 从 #minecraft:tick / #minecraft:load 出发做调用图闭包, 数命令条数。
不改动任何数据包文件, 只读。"""
import os, re, json, collections, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PACKS = ["manacore-1.0.0", "sweetdream"]

CALL = re.compile(r'(?:^|\s)(?:function|schedule\s+function)\s+([#a-z0-9_\-\.]+:[a-z0-9_\-/\.]+)')
FUNC_CALL = re.compile(r'(?<![\w/])function\s+([#a-z0-9_\-\.]+:[a-z0-9_\-/\.]+)')

fns = {}      # ns:path -> list[str] raw command lines (non-comment, non-empty)
tags = {}     # tag id (without #) -> list of function ids
where = {}    # id -> file path

for pack in PACKS:
    base = os.path.join(ROOT, pack, "data")
    if not os.path.isdir(base):
        continue
    for dirpath, _dirs, files in os.walk(base):
        for f in files:
            full = os.path.join(dirpath, f)
            rel = os.path.relpath(full, base).replace("\\", "/")
            parts = rel.split("/")
            if f.endswith(".mcfunction") and len(parts) >= 4 and parts[1] == "function":
                ns = parts[0]
                path = "/".join(parts[2:])[:-len(".mcfunction")]
                fid = ns + ":" + path
                lines = []
                with open(full, encoding="utf-8") as fh:
                    for ln in fh:
                        s = ln.strip()
                        if not s or s.startswith("#"):
                            continue
                        lines.append(s)
                fns[fid] = lines
                where[fid] = full
            elif f.endswith(".json") and len(parts) >= 3 and parts[1] == "tags" and parts[2] == "function":
                ns = parts[0]
                path = "/".join(parts[3:])[:-len(".json")]
                tid = ns + ":" + path
                try:
                    with open(full, encoding="utf-8") as fh:
                        data = json.load(fh)
                except Exception as e:
                    print("JSON FAIL", full, e)
                    continue
                vals = []
                for v in data.get("values", []):
                    if isinstance(v, str):
                        vals.append(v)
                    elif isinstance(v, dict) and "id" in v:
                        vals.append(v["id"])
                tags[tid] = vals

print("functions:", len(fns), " tags:", len(tags))

def expand(target):
    """resolve a '#tag' or 'ns:path' to concrete function ids"""
    if target.startswith("#"):
        tid = target[1:]
        out = []
        for v in tags.get(tid, []):
            out.extend(expand(v))
        return out
    return [target] if target in fns else []

def callees(lines):
    out = []
    for ln in lines:
        for m in FUNC_CALL.finditer(ln):
            out.extend(expand(m.group(1)))
    return out

def closure(roots, limit=4000):
    """count commands reachable; also count how many times each fn is reached (static, once)"""
    seen = set()
    order = []
    stack = list(roots)
    while stack:
        fid = stack.pop()
        if fid in seen or fid not in fns:
            continue
        seen.add(fid)
        order.append(fid)
        for c in callees(fns[fid]):
            if c not in seen:
                stack.append(c)
        if len(seen) > limit:
            break
    return order

def direct_cmds(fid):
    """commands that are NOT pure dispatch wrappers - count all lines for budget"""
    return len(fns[fid])

def analyse(name, roots):
    print("\n" + "=" * 70)
    print(name, " roots=", roots)
    order = closure(roots)
    total_cmds = sum(direct_cmds(f) for f in order)
    # a truer budget estimate: every function invocation executes all its lines
    print("reachable functions: %d   total static command lines: %d" % (len(order), total_cmds))
    # selector evaluations (rough): count lines containing @a/@e/@p/@r/@s selectors
    sel = 0
    for f in order:
        for ln in fns[f]:
            if re.search(r'@[aeprs]\[', ln) or re.search(r'@[aeprs]\b', ln):
                sel += 1
    print("static selector-evaluating lines: %d" % sel)
    # biggest fan-out
    fan = sorted(((len(callees(fns[f])), f) for f in order), reverse=True)[:15]
    print("top fan-out (direct callees):")
    for n, f in fan:
        print("   %3d  %s" % (n, f))
    print("top by own line count:")
    for f in sorted(order, key=lambda x: -len(fns[x]))[:15]:
        print("   %4d  %s" % (len(fns[f]), f))
    return order

tick_roots = []
for t in ["sweetdream:core/tick", "manacore:core/tick"]:
    tick_roots.append(t)
# also the extra entries in the tick tag json
for pack in PACKS:
    p = os.path.join(ROOT, pack, "data", "minecraft", "tags", "function", "tick.json")
    if os.path.exists(p):
        with open(p, encoding="utf-8") as fh:
            for v in json.load(fh)["values"]:
                tick_roots.append(v)
tick_roots = sorted(set(tick_roots))
analyse("PER-TICK (every game tick)", tick_roots)

load_roots = []
for pack in PACKS:
    p = os.path.join(ROOT, pack, "data", "minecraft", "tags", "function", "load.json")
    if os.path.exists(p):
        with open(p, encoding="utf-8") as fh:
            for v in json.load(fh)["values"]:
                load_roots.append(v)
analyse("PER-LOAD (once per /reload)", sorted(set(load_roots)))

sec = ["sweetdream:lib/second", "sweetdream:debug/second"]
analyse("PER-SECOND (sweetdream side)", sorted(set(sec)))

# how many of the tick-reachable functions are called with 3-dimension triplication
print("\n" + "=" * 70)
print("3x-dimension duplication check inside core/tick:")
ct = fns.get("sweetdream:core/tick", [])
dims = collections.Counter()
for ln in ct:
    m = re.match(r'execute in (minecraft:[a-z_]+)\s', ln)
    if m:
        dims[m.group(1)] += 1
print("  ", dict(dims))
