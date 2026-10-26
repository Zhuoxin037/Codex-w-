# -*- coding: utf-8 -*-
"""扫描 sweetdream 全部装备 give 文件，输出结构化清单。"""
import os, re, json

ROOT = r"D:/数据包/sweetdream/data/sweetdream/function/equipment"
CAT = {"armor": "盔甲", "axe": "斧", "bow": "弩", "staff": "法杖", "sword": "剑", "tool": "副手"}

MAT_STAGE = {
    "iron": "开局(铁)", "golden": "开局(金)", "leather": "开局(皮)", "chainmail": "开局(链)",
    "diamond": "过渡(钻)", "netherite": "终端(下界)",
}
NO_STAGE = "未分档"

re_give = re.compile(r'^give @s ([\w:]+)\[(.+)\]\s*$', re.S | re.M)
re_item = re.compile(r'item_name=\{text:"([^"]+)"')
re_zx   = re.compile(r'zx:\[([^\]]*)\]')
re_tags = re.compile(r'tags:\[([^\]]*)\]')
re_skill = re.compile(r'skill:"([^"]+)"')
re_slot = re.compile(r'equippable=\{slot:"(\w+)"')
re_lore = re.compile(r'\{"text":"([^"]*)"')
re_color = re.compile(r'item_name=\{text:"[^"]+",bold:\w+,color:(\w+)\}')

COLOR_RARITY = {"gold": "史诗", "aqua": "稀有(青)", "gray": "稀有", "light_purple": "传说",
                "red": "传说", "yellow": "精良", "green": "精良", "white": "普通",
                "dark_purple": "传说", "blue": "精良", "dark_red": "传说"}


def parse_lore(body):
    """把 give 里的 lore=[...] 解析成「显示行」列表。
    NBT 不是合法 JSON，按括号深度切出 top-level 项；带 extra 的是拼色行，
    把 extra 内所有 text 拼成一行。"""
    i = body.find("lore=[")
    if i < 0:
        return []
    i += len("lore=[")
    depth, j = 1, i  # 已经处在数组的 [ 之内
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
    lines, flags = [], []
    for it in items:
        if '"extra"' in it:
            k = it.find('"extra"')
            seg = it[k:]
            lines.append("".join(re.findall(r'"text":"([^"]*)"', seg)))
            flags.append(1)          # 1 = 拼色行（魔力 / 冷却 之类），单独成行
        else:
            m = re.search(r'"text":"([^"]*)"', it)
            if m is not None:
                lines.append(m.group(1))
                flags.append(2 if m.group(1).strip().startswith("✦") else 0)
    return [x.strip() for x in lines], flags


def parse(path, cat, eid):
    s = open(path, encoding="utf-8", errors="replace").read()
    m = re_give.search(s)
    if not m:
        return None
    mat, body = m.group(1).replace("minecraft:", ""), m.group(2)
    name = re_item.search(body)
    name = name.group(1) if name else eid
    mz, mt, ms = re_zx.search(body), re_tags.search(body), re_skill.search(body)
    zx = [x.strip().strip('"') for x in mz.group(1).split(",") if x.strip()] if mz else []
    tags = [x.strip().strip('"') for x in mt.group(1).split(",") if x.strip()] if mt else []
    skill = ms.group(1) if ms else ""
    slot = re_slot.search(body)
    raw_lines, _flags = parse_lore(body)
    lore = "\n".join(x for x in raw_lines if x)
    lore_paras = [x for x in raw_lines if x]
    col = re_color.search(body)
    rarity = COLOR_RARITY.get(col.group(1), col.group(1)) if col else ""
    # 阶段
    base = mat.split("_")[0]
    stage = MAT_STAGE.get(base, NO_STAGE)
    return dict(id=eid, cat=cat, cat_cn=CAT[cat], name=name, mat=mat, stage=stage,
                slot=slot.group(1) if slot else "", tags=tags, zx=zx, rarity=rarity,
                lore=lore, skill=skill, lore_paras=lore_paras)


out = []
for cat in CAT:
    d = os.path.join(ROOT, cat)
    if not os.path.isdir(d):
        continue
    for eid in sorted(os.listdir(d)):
        p = os.path.join(d, eid)
        if os.path.isdir(p):
            g = os.path.join(p, "give.mcfunction")
            if os.path.exists(g):
                r = parse(g, cat, eid)
                if r:
                    out.append(r)
                else:
                    print("!! no give line:", g)
        elif eid.endswith(".mcfunction"):
            print(".. skip file:", cat, eid)

print("total =", len(out))
from collections import Counter
print(Counter(x["cat_cn"] for x in out))
json.dump(out, open(r"D:/数据包/.workbuddy/_equip_all.json", "w", encoding="utf-8"),
          ensure_ascii=False, indent=1)
