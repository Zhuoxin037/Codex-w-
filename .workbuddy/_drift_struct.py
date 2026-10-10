# -*- coding: utf-8 -*-
"""打印磁盘原状(/tmp/givebak) 6 件 give 的完整段结构, 作为改生成器的依据。"""
import io, re, sys
sys.path.insert(0, '.workbuddy')
import lore_fmt as LF

FILES = ["armor/furnace_core", "armor/lightless_sea", "armor/withered_garden",
         "bow/lucid_dream", "bow/sculk_echo", "staff/apocalypse"]


def comps(p):
    s = io.open(p, encoding='utf-8').read()
    for ln in s.split('\n'):
        if not ln.startswith('give @s '):
            continue
        m = re.search(r'lore=(\[.*\]),(?:unbreakable|enchantments|custom_data|consumable|tooltip_display)', ln.rstrip('\r'))
        if m:
            return LF.snbt_to_json(m.group(1))
    return None


for rel in FILES:
    lore = comps('C:/Users/qq303/AppData/Local/Temp/givebak/equipment/%s/give.mcfunction' % rel)
    print('=' * 76)
    print('#### %s   (%d 段)' % (rel, len(lore or [])))
    print('=' * 76)
    for i, e in enumerate(lore or []):
        if not isinstance(e, dict):
            print('  %02d %r' % (i, e))
            continue
        kind = 'H' if e.get('bold') else ('S' if e.get('text') == ' ' and 'extra' not in e else ('I' if 'extra' in e else 'P'))
        t = e.get('text', '')
        if kind == 'I':
            sub = ''.join(x.get('text', '|%s|' % x.get('color', '')) for x in e.get('extra', []))
            print('  %02d [I] %s' % (i, sub))
        else:
            print('  %02d [%s] %s' % (i, kind, t))
    print()
