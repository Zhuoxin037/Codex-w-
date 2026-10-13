# -*- coding: utf-8 -*-
"""
升级石「定义了但没有任何效果」体检。

为什么查这个: 一块升级石的价值全在 updef 的字段里。如果所有效果字段都是 0,
敲上去就是"占了槽位但什么都没发生" —— 最阴的一种 bug(不报错、描述还写得很好听)。
典型事故: 2026-10-07 火炬石 updef 写的是 tc:0, 而 api/hit_mark 判 #up_tc matches 1..,
=> api/torch 永远不执行, 敲了等于没敲。

判据:
  · 数值字段 dmg/mana/cd/mm/mr/mh/mhp/ar/at/hp/aspd 有非零 => 有效果
  · 开关字段 cdex/tc/boil/nv/rg 有非零 => 有效果
  · ms.pct / ms.every 有非零 => 有效果
  以上全为 0 => 报"空效果"
"""
import os
import re
import io
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEF = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function", "upgrade", "def", "load.mcfunction")

NUM = ("dmg", "mana", "cd", "mm", "mr", "mh", "mhp", "ar", "at", "hp", "aspd")
FLAG = ("cdex", "tc", "boil", "nv", "rg")


def num(s):
    try:
        return float(s)
    except Exception:
        return 0.0


def main():
    txt = io.open(DEF, encoding="utf-8").read()
    print("=" * 70)
    print("升级石效果体检 (updef)")
    print("=" * 70)

    rows = []
    for m in re.finditer(r'updef\."([a-z0-9_]+)" set value \{([^\n]*)\}', txt):
        sid, body = m.group(1), m.group(2)
        eff = {}
        for k in NUM + FLAG:
            km = re.search(r'(?<![a-z])%s:(-?[0-9.]+)' % k, body)
            if km:
                eff[k] = num(km.group(1))
        msp = re.search(r'ms:\{pct:(-?[0-9.]+),every:(-?[0-9.]+)\}', body)
        if msp:
            eff["ms.pct"] = num(msp.group(1))
            eff["ms.every"] = num(msp.group(2))
        lab = re.search(r'label:"([^"]*)"', body)
        note = re.search(r'note:"([^"]*)"', body)
        rows.append((sid, lab.group(1) if lab else "", note.group(1) if note else "", eff))

    print("共 %d 条定义" % len(rows))
    print()

    empty = []
    for sid, lab, note, eff in rows:
        if not any(v != 0 for v in eff.values()):
            empty.append((sid, lab, note))
    print("[1] 全零效果 —— 敲上去什么都不发生 (疑似漏填字段):")
    for sid, lab, note in empty:
        print("      %-16s %-12s %s" % (sid, lab, note))
    if not empty:
        print("      (无)")
    print()

    print("[2] 全部定义一览 (label / 生效字段 / note):")
    for sid, lab, note, eff in rows:
        act = {k: v for k, v in eff.items() if v != 0}
        flag = "  <<< 空效果" if not act else ""
        print("   %-16s %-12s %s%s" % (sid, lab, act or "{}", flag))
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
