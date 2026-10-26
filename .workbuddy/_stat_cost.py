import re, pathlib, json, collections
root = pathlib.Path("sweetdream/data/sweetdream/function/equipment")
stat = collections.defaultdict(list)
for f in root.rglob("give.mcfunction"):
    txt = f.read_text(encoding="utf-8", errors="ignore")
    cat = f.parts[-3]
    if cat not in ("sword","axe","bow","staff","armor","tool"):
        continue
    # 抓拼色行: 魔力 380 · 冷却 10 秒
    for m in re.finditer(r'魔力 \\?",?\\?"?[^,]*,[^}]*?(\d+)[^}]*?冷却[^}]*?(\d+)', txt):
        pass
    # 更简单: 找 lore 里 拼色行 结构 -> 取所有 "魔力 " 后的数值与 "冷却 " 后的值
    pairs = re.findall(r'"text":"魔力 ",?.*?"text":"(\d+)",.*?"text":"冷却 ",?.*?"text":"(\d+) 秒"', txt)
    for a,b in pairs:
        stat[(cat,"active")].append((int(a),int(b)))
    # 普攻行: 魔力 80 · 伤害 当前魔力值 ×0.02
    for m in re.finditer(r'"text":"魔力 ",?.*?"text":"(\d+)".{0,400}?"text":"伤害 "', txt, re.S):
        pass
for k in sorted(stat):
    v = stat[k]
    if not v: continue
    mana = sorted(x[0] for x in v); cd = sorted(x[1] for x in v)
    print(k, "n=",len(v), "mana:", mana[0], "~", mana[-1], "median", mana[len(mana)//2], "| cd:", cd[0],"~",cd[-1],"median",cd[len(cd)//2])
