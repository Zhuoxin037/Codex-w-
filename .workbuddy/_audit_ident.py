# -*- coding: utf-8 -*-
"""
装备身份一致性体检 —— 找出「装备自己都不认识自己」的情况。

为什么查这个: 全包判定装备身份一律走 `custom_data~{zx:["<id>"]}`(部分匹配)。
如果 give 里打的 id 词、和别处判定用的 id 词对不上 —— 那件装备的被动/伤害/回响
**一条都不会触发**, 而且不报任何错(选择器就是选不到)。最阴的一种 bug。

查三件事:
  1) 装备目录存在、但全包搜不到 zx["<同名>"] => 它自己都不被认得
  2) give 里没给自己打本装备的词 (可能是改了名没同步)
  3) 代码判了某个 zx 词、但没有对应装备目录 (改名残留 / 写错)

⚠️ 注意 [1][2] 是**弱信号**: 有些装备靠 `skill` / 物品模型 / 别的判据认身份,
   报告出来的先人工确认再说要改, 别直接判 bug。
"""
import os
import re
import io
import sys
import collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EQ = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function", "equipment")
DATA = os.path.join(ROOT, "sweetdream", "data")
RP = os.path.join(ROOT, "sweetdream_rp")

# zx:["a","b","c"] —— 列表里每个引号词都要抽出来(不能只认单元素写法)
ZX_LIST = re.compile(r'zx\s*:\s*\[([^\]]*)\]')
ZX_ITEM = re.compile(r'"([a-z0-9_]+)"')

# 非装备的通用标记(不是装备 id, 别报幽灵)
GENERIC = {"itemreplace", "armor", "sword", "axe", "bow", "staff", "crossbow", "tool",
           "skill", "weapon", "staff1", "consume", "material", "shield", "helmet"}


def read(p):
    try:
        return io.open(p, encoding="utf-8", errors="replace").read()
    except Exception:
        return ""


def words_in(text):
    out = set()
    for ml in ZX_LIST.finditer(text):
        out.update(ZX_ITEM.findall(ml.group(1)))
    return out


def equipment_dirs():
    out = {}
    for cat in os.listdir(EQ):
        cd = os.path.join(EQ, cat)
        if not os.path.isdir(cd):
            continue
        for eid in os.listdir(cd):
            if os.path.isdir(os.path.join(cd, eid)):
                out[eid] = (cat, os.path.join(cd, eid))
    return out


def scan_words():
    hits = collections.defaultdict(list)
    for base in (DATA, RP):
        for r, _d, fs in os.walk(base):
            for f in fs:
                if not f.endswith((".mcfunction", ".json", ".mcmeta")):
                    continue
                p = os.path.join(r, f)
                rel = os.path.relpath(p, ROOT).replace("\\", "/")
                for i, ln in enumerate(read(p).split("\n"), 1):
                    for ml in ZX_LIST.finditer(ln):
                        for w in ZX_ITEM.findall(ml.group(1)):
                            hits[w].append((rel, i))
    return hits


def main():
    eq = equipment_dirs()
    hits = scan_words()

    print("=" * 70)
    print("装备身份一致性体检")
    print("=" * 70)
    print("装备件数 %d · 出现过的 zx 词 %d" % (len(eq), len(hits)))
    print()

    print("[1] 装备目录存在、但全包搜不到同名 zx 词 => 别人认不出它:")
    n = 0
    for eid in sorted(eq):
        if eid not in hits:
            print("      %-22s (%s)" % (eid, eq[eid][0]))
            n += 1
    if not n:
        print("      (无)")
    print()

    print("[2] give 里没给自己打本装备的词:")
    n = 0
    for eid in sorted(eq):
        cat, d = eq[eid]
        g = os.path.join(d, "give.mcfunction")
        if not os.path.exists(g):
            print("      %-22s !! 没有 give.mcfunction" % eid)
            n += 1
            continue
        words = words_in(read(g))
        if eid not in words:
            near = [w for w in words if len(w) >= 4 and (w in eid or eid in w)]
            print("      %-22s give 里的词: %s%s"
                  % (eid, sorted(words),
                     ("   <- 形近: " + ",".join(near)) if near else ""))
            n += 1
    if not n:
        print("      (无)")
    print()

    print("[3] 代码判了 zx 词、但没有对应装备目录 (改名残留/写错):")
    n = 0
    for w in sorted(hits):
        if w in eq or w in GENERIC or w.startswith(("ol_", "up_")):
            continue
        files = sorted(set(f for f, _i in hits[w]))
        shown = files[:5] + (["…共%d处" % len(hits[w])] if len(files) > 5 else [])
        print("      %-20s %s" % (w, ", ".join(shown)))
        n += 1
    if not n:
        print("      (无)")
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
