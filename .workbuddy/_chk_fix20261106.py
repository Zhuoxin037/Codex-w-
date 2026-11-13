# -*- coding: utf-8 -*-
"""本轮修复完整性核查：只报告问题，不改任何文件。"""
import os, json, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DP = os.path.join(ROOT, "sweetdream", "data", "sweetdream")
MC = os.path.join(ROOT, "manacore-1.0.0", "data", "manacore")
RP = os.path.join(ROOT, "sweetdream_rp_完整版", "assets")


def walk_mcf(base):
    out = []
    for root, _, fs in os.walk(base):
        for f in fs:
            if f.endswith(".mcfunction"):
                out.append(os.path.join(root, f))
    return out


fn_files = walk_mcf(os.path.join(DP, "function")) + walk_mcf(os.path.join(MC, "function"))
exists = set()
for p in fn_files:
    for base, ns in ((os.path.join(DP, "function"), "sweetdream"),
                     (os.path.join(MC, "function"), "manacore")):
        if p.startswith(base):
            rel = os.path.relpath(p, base).replace("\\", "/")[:-11]
            exists.add(ns + ":" + rel)

issues = []

# 1) 函数引用目标是否存在（含动态分派拼接，只查字面量）
for p in fn_files:
    for i, line in enumerate(open(p, encoding="utf-8", errors="replace"), 1):
        s = line.strip()
        if s.startswith("#"):
            continue
        for m in re.finditer(r"\bfunction\s+([a-z0-9_]+):([a-z0-9_/]+)", s):
            target = m.group(1) + ":" + m.group(2)
            if target not in exists and not target.startswith("minecraft:"):
                issues.append(("缺失函数引用", p, i, target))

# 2) advancement rewards.function
adv_root = os.path.join(DP, "advancement")
for root, _, fs in os.walk(adv_root):
    for f in fs:
        if not f.endswith(".json"):
            continue
        p = os.path.join(root, f)
        try:
            d = json.load(open(p, encoding="utf-8"))
        except Exception as e:
            issues.append(("JSON 解析失败", p, 0, str(e)))
            continue
        fn = (d.get("rewards") or {}).get("function")
        if fn and fn not in exists:
            issues.append(("advancement 指向不存在函数", p, 0, fn))

# 3) item_modifier 引用
mod_root = os.path.join(DP, "item_modifier")
mods = set()
for root, _, fs in os.walk(mod_root):
    for f in fs:
        if f.endswith(".json"):
            rel = os.path.relpath(os.path.join(root, f), mod_root).replace("\\", "/")[:-5]
            mods.add("sweetdream:" + rel)
for p in fn_files:
    for i, line in enumerate(open(p, encoding="utf-8", errors="replace"), 1):
        s = line.strip()
        if s.startswith("#"):
            continue
        for m in re.finditer(r"\bitem modify\s+\S+\s+(sweetdream:[a-z0-9_/]+)", s):
            if m.group(1) not in mods:
                issues.append(("item_modifier 不存在", p, i, m.group(1)))

# 4) 八件 item_model 指向的资源包 items 定义
ids = ["armor_bulwark", "sword_sacrifice", "axe_detach", "staff_lucid_illusion",
       "axe_throe", "staff_intone", "sword_aftersound", "staff_surge_ebb"]
for iid in ids:
    hit = 0
    for root, _, fs in os.walk(RP):
        for f in fs:
            if f == iid + ".json":
                hit += 1
    if not hit:
        issues.append(("资源包缺 item 定义", RP, 0, iid))

# 5) 本轮新增关键函数接线
wires = [
    ("sacrifice/tick", "sweetdream:equipment/sword/sacrifice/tick"),
    ("bulwark/event", "sweetdream:equipment/armor/bulwark/event"),
    ("surge_ebb/one", "sweetdream:equipment/staff/surge_ebb/one"),
    ("throe/settle", "sweetdream:equipment/axe/throe/settle"),
    ("throe/watch", "sweetdream:equipment/axe/throe/watch"),
    ("lib/victim 目录", None),
    ("b21_icons", "sweetdream:visual/b21_icons"),
    ("hp_digit", "sweetdream:lib/math/hp_digit"),
]
all_text = {}
for p in fn_files:
    all_text[p] = "".join(l for l in open(p, encoding="utf-8", errors="replace")
                          if not l.strip().startswith("#"))
joined = "\n".join(all_text.values())
for label, target in wires:
    if target and target not in joined:
        issues.append(("新函数未接线", "", 0, label + " -> " + target))

# 6) 常量是否注册（core/load）
load = open(os.path.join(DP, "function", "core", "load.mcfunction"),
            encoding="utf-8").read()
for c in ["#10 zx.meta", "#20 zx.meta", "#1000 zx.meta", "#5 zx.meta"]:
    if ("players set " + c) not in load:
        issues.append(("core/load 未注册常量", "", 0, c))

# 7) 新计分项是否都在 core/load 注册
score_re = re.compile(r"\bzx\.([a-z_0-9]+)")
declared = set(re.findall(r"scoreboard objectives add (zx\.[a-z_0-9]+)", load))
new_scores = ["zx.hurt_evt", "zx.sc_step", "zx.pn_sid", "zx.se_b_atk", "zx.se_b_mm",
              "zx.bw_atk", "zx.hp_p100", "zx.sid"]
for sname in new_scores:
    if sname in joined and sname not in declared:
        issues.append(("计分项可能未注册", "", 0, sname))

print("函数文件:", len(fn_files), " 问题:", len(issues))
seen = set()
for kind, p, ln, detail in issues:
    key = (kind, detail)
    if key in seen:
        continue
    seen.add(key)
    short = os.path.relpath(p, ROOT) if p else "-"
    print("  [%s] %s L%s  %s" % (kind, short, ln, detail))
