# -*- coding: utf-8 -*-
"""把一件武器 give.mcfunction 里的「底物 / 中文名 / 技能文本」抽出来（读原文，不臆造）。"""
import os
import re
import sys

ROOT = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'

TEXT_RE = re.compile(r'"text":"([^"]*)"')
NAME_RE = re.compile(r'item_name=\{text:"([^"]*)"')
GIVE_RE = re.compile(r'give @s (\S+?)\[')

LORE_END = '],unbreakable'


def info(kind, wid):
    p = os.path.join(ROOT, kind, wid, 'give.mcfunction')
    if not os.path.isfile(p):
        return None
    t = open(p, encoding='utf-8').read()
    base = GIVE_RE.search(t)
    name = NAME_RE.search(t)
    seg = t.split('lore=[', 1)
    lore = []
    if len(seg) > 1:
        body = seg[1]
        cut = body.find(LORE_END)
        if cut >= 0:
            body = body[:cut]
        lore = [x for x in TEXT_RE.findall(body) if x.strip()]
    return (base.group(1) if base else '?',
            name.group(1) if name else '?',
            ' '.join(lore))


def main():
    kind = sys.argv[1] if len(sys.argv) > 1 else 'sword'
    wids = sys.argv[2:] or sorted(os.listdir(os.path.join(ROOT, kind)))
    for w in wids:
        r = info(kind, w)
        if not r:
            print('==== %-18s  (无 give.mcfunction)' % w)
            continue
        base, name, lore = r
        print('==== %-18s | %-16s | %s' % (w, base, name))
        print('     ' + lore[:600])


if __name__ == '__main__':
    main()
