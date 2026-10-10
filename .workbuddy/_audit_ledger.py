#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""临时审计脚本: 找"账本式"计分项(记录已加成多少), 检查每个账本是否同时存在
"加"和"减"两条路径 —— 只有加没有减 = 摘装备后永久残留。只读。"""
import os, re, collections

FP = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                  "sweetdream", "data", "sweetdream", "function")

# 账本命名习惯: zx.<x> 且语义是"已经加了多少"
LEDGER = re.compile(r'\bzx\.(am_mana|[a-z]{1,3}_mana|up_mana|up_armor|up_at|up_hp|floor_mana|'
                    r'pump_mana|set_mana|power_hp|set_hp|em_mana|se_mana|dd_app|dd_mana|'
                    r'ir_mana|mr_mana|bl_mana|bl_atk|ss_mana|ss_armor|ss_hp|wg_mana|dio_mana|'
                    r'up_at|am_mana)\b')
# 所有 zx.<name> 形式, 用来发现没被上面列到的账本
ANY = re.compile(r'\bzx\.([a-z0-9_]{2,16})\b')
ADD = re.compile(r'(players\s+(add|operation)\s+@s\s+zx\.\w+\s*(\+=)?)')
SUB = re.compile(r'(players\s+(remove|operation)\s+@s\s+zx\.\w+\s*-=)')

ledgers = collections.defaultdict(lambda: {"add": [], "sub": [], "files": set()})
for dp, _dd, fs in os.walk(FP):
    for f in fs:
        if not f.endswith(".mcfunction"):
            continue
        p = os.path.join(dp, f)
        rel = os.path.relpath(p, FP).replace("\\", "/")
        for i, line in enumerate(open(p, encoding="utf-8", errors="replace"), 1):
            if line.lstrip().startswith("#"):
                continue
            for m in LEDGER.finditer(line):
                L = m.group(1)
                ledgers[L]["files"].add(rel)
                if re.search(r'players\s+add\s+@s\s+zx\.' + L, line) or \
                   re.search(r'players\s+operation\s+@s\s+zx\.' + L + r'\s*\+=', line):
                    ledgers[L]["add"].append((rel, i, line.strip()))
                if re.search(r'players\s+remove\s+@s\s+zx\.' + L, line) or \
                   re.search(r'players\s+operation\s+@s\s+zx\.' + L + r'\s*-=', line):
                    ledgers[L]["sub"].append((rel, i, line.strip()))

print("%-12s %5s %5s  %s" % ("ledger", "add", "sub", "verdict"))
print("-" * 78)
bad = []
for L in sorted(ledgers):
    d = ledgers[L]
    if not d["add"] and not d["sub"]:
        continue
    if d["add"] and not d["sub"]:
        v = "*** 只加不减(疑似泄漏) ***"
        bad.append(L)
    elif d["sub"] and not d["add"]:
        v = "只减不加"
    else:
        v = "ok"
    print("%-12s %5d %5d  %s" % (L, len(d["add"]), len(d["sub"]), v))
print()
for L in bad:
    print("=== %s: 加的地方 ===" % L)
    for rel, i, line in ledgers[L]["add"][:12]:
        print("   %s:%d  %s" % (rel, i, line[:120]))
    print("   (该账本出现于 %d 个文件)" % len(ledgers[L]["files"]))
