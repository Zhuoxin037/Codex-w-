# -*- coding: utf-8 -*-
"""用 lore_fmt 自己的 SNBT 解析器, 把两版 lore 逐段(text/color/bold)打印出来。"""
import io, re, sys, json
sys.path.insert(0, '.workbuddy')
import lore_fmt as LF


def lore_of(p):
    s = io.open(p, encoding='utf-8').read()
    for ln in s.split('\n'):
        if not ln.startswith('give @s '):
            continue
        m = re.search(r'lore=(\[.*\]),(?:unbreakable|enchantments|custom_data|consumable|tooltip_display)', ln.rstrip('\r'))
        if m:
            return LF.snbt_to_json(m.group(1))
    return None


def show(tag, lore):
    print('--- %s ---' % tag)
    if lore is None:
        print('  (解析失败)')
        return
    for i, line in enumerate(lore):
        parts = []
        if isinstance(line, list):
            for seg in line:
                if isinstance(seg, dict):
                    t = seg.get('text', '')
                    c = seg.get('color', '-')
                    b = 'B' if seg.get('bold') else ''
                    it = seg.get('italic')
                    parts.append('[%s|%s%s%s]' % (t, c, b, '' if it in (False, None) else '?i'))
                else:
                    parts.append(str(seg))
        else:
            parts.append(str(line))
        print('  %02d %s' % (i, ''.join(parts)))


for rel in ("armor/furnace_core", "bow/lucid_dream"):
    print('=' * 78)
    print('#### %s' % rel)
    show('磁盘原状 /tmp/givebak', lore_of('C:/Users/qq303/AppData/Local/Temp/givebak/equipment/%s/give.mcfunction' % rel))
    show('生成器+lore_fmt(当前磁盘)', lore_of('sweetdream/data/sweetdream/function/equipment/%s/give.mcfunction' % rel))
    print()
