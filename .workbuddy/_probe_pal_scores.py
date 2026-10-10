# -*- coding: utf-8 -*-
"""_probe_pal_scores.py —— 离线读存档 scoreboard.dat, 打印调色盘相关计分项。

为什么: "色彩"的蓝数 / 已打数 / 目标阀值 都存在计分项里, 而计分项是**唯一事实来源**。
光球现在没有时间寿命(2026-10-08 删掉时间兜底), 测试完的光球会留在存档里,
它的 zx.pal_blu / zx.pal_n 直接回答"一枚光球到底打了几只、算几个蓝"。

用法:
    python _probe_pal_scores.py <存档目录> [关键词...]
关键词默认: zx.pal
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _nbt_dump import load  # noqa: E402  (它 import 时已把 stdout 换成 utf-8)


def main():
    save = sys.argv[1]
    keys = sys.argv[2:] or ['zx.pal']
    path = os.path.join(save, 'data', 'scoreboard.dat')
    if not os.path.exists(path):
        print('没有 scoreboard.dat:', path)
        return 1
    root = load(path)
    data = root.get('data', root)
    print('== 计分项(objectives) ==')
    for o in data.get('Objectives', []):
        print('  %-22s %s' % (o.get('Name'), o.get('CriteriaName', '')))
    print()
    print('== 分数(只打含关键词的) ==')
    rows = []
    for s in data.get('PlayerScores', []):
        name = s.get('Name', '')
        obj = s.get('Objective', '')
        if not obj:
            # 新格式: 一个条目里带多个 objective 字段
            for k, v in s.items():
                if k.startswith('zx.') or k.startswith('manacore'):
                    rows.append((name, k, v))
            continue
        rows.append((name, obj, s.get('Score')))
    hit = 0
    for name, obj, val in sorted(rows, key=lambda r: (r[1], r[0])):
        if any(k in obj for k in keys):
            hit += 1
            print('  %-40s %-14s = %s' % (name, obj, val))
    print('---- 命中 %d 条 ----' % hit)
    print()
    print('== 所有含 zx.pal_ 的玩家/实体名(去重) ==')
    names = sorted({name for name, obj, _ in rows if 'zx.pal' in obj})
    for n in names:
        print('  ', n)
    return 0


if __name__ == '__main__':
    sys.exit(main())
