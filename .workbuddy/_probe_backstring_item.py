# -*- coding: utf-8 -*-
"""只读取证：把存档里玩家身上的「退弦」物品 lore 打印出来（对比源 give 是否一致）。

用法: python .workbuddy/_probe_backstring_item.py [物品名子串]
"""
import glob
import json
import os
import sys

import nbtlib

BASE = r"D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\saves\测试包体\playerdata"
KEY = sys.argv[1] if len(sys.argv) > 1 else "退弦"


def flat(comp):
    """把 chat component 渲染成 [文本, 颜色] 列表"""
    out = []

    def walk(e, inh_color=None):
        if isinstance(e, str):
            out.append([e, inh_color or ""])
            return
        if e is None:
            return
        c = e.get("color", inh_color)
        t = e.get("text") if e.get("text") is not None else ""
        if "extra" in e:
            out.append([t, c or ""])
            for x in e["extra"]:
                walk(x, c)
        else:
            out.append([t, c or ""])

    walk(comp)
    return [(t, c) for t, c in out if t]


def find_items(tag, path=""):
    """在 NBT 树里找所有带 components 的物品复合"""
    res = []
    if hasattr(tag, "items"):  # Compound
        if "components" in tag:
            res.append(tag)
        for k, v in tag.items():
            res += find_items(v, path + "/" + str(k))
    elif isinstance(tag, list) or hasattr(tag, "__iter__") and not isinstance(tag, (str, bytes)):
        try:
            for i, v in enumerate(tag):
                res += find_items(v, path + "/%d" % i)
        except TypeError:
            pass
    return res


for f in sorted(glob.glob(os.path.join(BASE, "*.dat"))):
    if f.endswith("_old"):
        continue
    try:
        nbt = nbtlib.load(f)
    except Exception as e:
        print("!! 读不了 %s: %s" % (f, e))
        continue
    hits = 0
    for item in find_items(nbt):
        comps = item["components"]
        cd = comps.get("minecraft:custom_data")
        name = comps.get("minecraft:item_name")
        name_txt = json.dumps(name.snbt() if hasattr(name, "snbt") else str(name), ensure_ascii=False) if name else ""
        is_target = False
        if cd is not None:
            s = cd.snbt() if hasattr(cd, "snbt") else str(cd)
            if "backstring" in s:
                is_target = True
        if KEY in name_txt:
            is_target = True
        if not is_target:
            continue
        hits += 1
        print("=" * 60)
        print("文件:", os.path.basename(f))
        print("item_name:", name_txt)
        if cd is not None:
            print("custom_data:", cd.snbt() if hasattr(cd, "snbt") else str(cd))
        lore = comps.get("minecraft:lore")
        if lore is None:
            print("lore: <无>")
        else:
            print("lore 原始:", lore.snbt()[:400] if hasattr(lore, "snbt") else str(lore)[:400])
            print("--- 渲染 ---")
            for i, line in enumerate(lore, 1):
                parts = flat(line)
                s = "".join("%s%s" % (t, ("(%s)" % c) if c else "") for t, c in parts)
                print("  %2d | %s" % (i, s))
    if not hits:
        print("%s: 没有找到含「%s」的物品" % (os.path.basename(f), KEY))
