# -*- coding: utf-8 -*-
"""扫描 overlimit/def/load.mcfunction，抽出每件装备的「超限形态」定义。
输出 .workbuddy/_ol_all.json = {武器id: {label, name, dmg, mana, cd, lore_paras}}
lore 就是敲上超限石后物品描述被**整段替换**成的那份文本。"""
import re, json


def parse_lore(body):
    i = body.find("lore:[")          # oldef 里是 lore:[...]
    if i >= 0:
        i += len("lore:[")
    else:
        i = body.find("lore=[")      # give 里是 lore=[...]
        if i < 0:
            return []
        i += len("lore=[")
    depth, j = 1, i
    while j < len(body):
        c = body[j]
        if c in "[{":
            depth += 1
        elif c in "]}":
            depth -= 1
            if depth == 0:
                break
        j += 1
    inner = body[i:j]
    items, depth, buf = [], 0, ""
    for c in inner:
        if c in "[{":
            depth += 1
        elif c in "]}":
            depth -= 1
        if c == "," and depth == 0:
            items.append(buf); buf = ""
        else:
            buf += c
    if buf.strip():
        items.append(buf)
    out = []
    for it in items:
        if '"extra"' in it:
            k = it.find('"extra"')
            out.append("".join(re.findall(r'"text":"([^"]*)"', it[k:])))
        else:
            m = re.search(r'"text":"([^"]*)"', it)
            if m is not None:
                out.append(m.group(1))
    return [x.strip() for x in out]


SRC = r"D:/数据包/sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction"
STONE_DIR = r"D:/数据包/sweetdream/data/sweetdream/function/overlimit/item"
import os
stones = {f[:-11] for f in os.listdir(STONE_DIR) if f.endswith(".mcfunction")}
txt = open(SRC, encoding="utf-8", errors="replace").read()

# 逐条切：以 `data modify storage zx:config oldef."<id>"` 开头，到行尾
entries = {}
cur_id = None
for line in txt.split("\n"):
    if not line.startswith("data modify storage zx:config oldef."):
        continue
    m = re.match(r'data modify storage zx:config oldef\."(\w+)"', line)
    if not m:
        continue
    cur_id = m.group(1)
    label = re.search(r'label:"([^"]*)"', line)
    dmg = re.search(r'dmg:(-?[\d.]+)', line)
    mana = re.search(r'mana:(-?[\d.]+)', line)
    cd = re.search(r'cd:(-?[\d.]+)', line)
    paras = [x for x in parse_lore(line) if x]
    entries[cur_id] = dict(
        label=label.group(1) if label else "",
        stone=cur_id in stones,          # 有没有自己的超限石
        dmg=float(dmg.group(1)) if dmg else 0.0,
        mana=float(mana.group(1)) if mana else 0.0,
        cd=float(cd.group(1)) if cd else 0.0,
        lore_paras=paras,
    )

# 对账：装备 id 是否都能对上
eq = json.load(open(r"D:/数据包/.workbuddy/_equip_all.json", encoding="utf-8"))
eqids = {x["id"] for x in eq}
miss = [k for k in entries if k not in eqids]
print("超限定义 %d 条 / 能对上装备的 %d 条" % (len(entries), len(entries) - len(miss)))
if miss:
    print("!! 对不上的 id:", miss)
no_lore = [k for k, v in entries.items() if not v["lore_paras"]]
if no_lore:
    print("!! 没有 lore 的:", no_lore)

json.dump(entries, open(r"D:/数据包/.workbuddy/_ol_all.json", "w", encoding="utf-8"),
          ensure_ascii=False, indent=1)
for k in list(entries)[:2]:
    print("---", k, entries[k]["label"], entries[k]["dmg"], entries[k]["mana"], entries[k]["cd"])
    for p in entries[k]["lore_paras"]:
        print("   |", p[:70])
