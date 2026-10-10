#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""临时审计脚本: 从 lib/skill_mul/def 的注释里抽"通道 + 系数", 从技能文件里抽耗蓝/冷却,
在两个代表性面板下估算每次释放的伤害, 用来看三条通道的平衡。只读。"""
import os, re, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FP = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function")
EQ = os.path.join(FP, "equipment")

# ---- 1. 通道表 + 从注释里抽系数 ----
defsrc = open(os.path.join(FP, "lib", "skill_mul", "def.mcfunction"), encoding="utf-8").read()
chan = {}
coef = collections.defaultdict(dict)
cur_id = None
for line in defsrc.splitlines():
    m = re.search(r'wchan\.([a-z_0-9]+)\s+set value \{mm:(\d)b,atk:(\d)b,oth:(\d)b\}', line)
    if m:
        cur_id = m.group(1)
        chan[cur_id] = (int(m.group(2)), int(m.group(3)), int(m.group(4)))
        continue
    if line.strip().startswith("#") and cur_id:
        # 例: "最大魔力 ×0.1 / ×0.25"  /  "基础攻击力 ×2"  /  "当前魔力 ×0.15"
        for kw, key in (("最大魔力", "mm"), ("基础攻击力", "atk"), ("当前魔力", "oth"), ("最大生命", "hp")):
            if kw in line:
                for c in re.findall(r'[×x]\s*(\d+(?:\.\d+)?)', line):
                    coef[cur_id].setdefault(key, []).append(float(c))

# ---- 2. 每个技能文件的耗蓝 / 冷却 ----
COST = re.compile(r'mana:\s*([\d.]+)')
CD   = re.compile(r'cooldown_seconds:\s*([\d.]+)')
rows = []
for cat in sorted(os.listdir(EQ)):
    p = os.path.join(EQ, cat)
    if not os.path.isdir(p):
        continue
    for it in sorted(os.listdir(p)):
        d = os.path.join(p, it)
        if not os.path.isdir(d) or it not in chan:
            continue
        costs, cds = [], []
        for dp, _dd, fs in os.walk(d):
            for f in fs:
                if not f.endswith(".mcfunction"):
                    continue
                t = open(os.path.join(dp, f), encoding="utf-8", errors="replace").read()
                costs += [float(x) for x in COST.findall(t)]
                cds += [float(x) for x in CD.findall(t)]
        rows.append((cat, it, chan[it], min(costs) if costs else None,
                     min(cds) if cds else None, coef.get(it, {})))

# ---- 3. 两套代表性面板 ----
def dmg(flags, co, mid, cast):
    mm, atk, oth = mid
    d = 0.0
    if flags[0] and co.get("mm"):  d += mm  * max(co["mm"])
    if flags[1] and co.get("atk"): d += atk * max(co["atk"])
    if flags[2] and co.get("oth"): d += max(0.0, oth - cast) * max(co["oth"])   # 支付后基数
    if co.get("hp"):               d += 20.0 * max(co["hp"])
    return d

mid = (800.0, 12.0, 800.0)
mx  = (2500.0, 25.0, 2500.0)

print("%-18s %-10s %-4s %-4s %-4s %8s %7s | %8s %8s | %8s" %
      ("weapon", "channels", "mm", "atk", "oth", "cost", "cd(s)", "dmg@mid", "dmg@max", "dmg/mana"))
print("-" * 118)
agg = collections.defaultdict(list)
for cat, it, flags, cost, cd, co in sorted(rows):
    c = cost or 0.0
    d1 = dmg(flags, co, mid, c)
    d2 = dmg(flags, co, mx, c)
    eff = (d2 / c) if c else float("nan")
    key = ("mm" if flags[0] else "") + ("atk" if flags[1] else "") + ("oth" if flags[2] else "")
    agg[key or "fixed"].append(eff)
    print("%-18s %-10s %-4d %-4d %-4d %8s %7s | %8.1f %8.1f | %8.2f" %
          (it, key or "fixed", flags[0], flags[1], flags[2],
           ("%.0f" % c) if cost else "-", ("%.0f" % cd) if cd else "-", d1, d2, eff))

print("\n按通道组合的 伤害/耗蓝 中位数(@max 面板):")
for k, v in sorted(agg.items()):
    v = sorted(x for x in v if x == x)
    if v:
        print("   %-8s n=%-3d median=%6.2f  min=%6.2f  max=%7.2f" % (k, len(v), v[len(v)//2], v[0], v[-1]))
