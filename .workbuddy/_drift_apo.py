# -*- coding: utf-8 -*-
import io, re, sys
sys.path.insert(0, '.workbuddy')
import lore_fmt as LF


def comps(p):
    s = io.open(p, encoding='utf-8').read()
    for ln in s.split('\n'):
        if not ln.startswith('give @s '):
            continue
        m = re.search(r'lore=(\[.*\]),(?:unbreakable|enchantments|custom_data|consumable|tooltip_display)', ln.rstrip('\r'))
        if m:
            return LF.snbt_to_json(m.group(1))
    return None


def desc(e):
    if not isinstance(e, dict):
        return repr(e)
    k = 'H' if e.get('bold') else ('S' if e.get('text') == ' ' and 'extra' not in e else ('I' if 'extra' in e else 'P'))
    if k == 'I':
        return '[I] ' + ''.join(x.get('text', '') for x in e.get('extra', []))
    return '[%s] %s' % (k, e.get('text', ''))


A = comps('C:/Users/qq303/AppData/Local/Temp/givebak2/equipment/staff/apocalypse/give.mcfunction')
B = comps('sweetdream/data/sweetdream/function/equipment/staff/apocalypse/give.mcfunction')
print('运行前 %d 段 / 运行后 %d 段' % (len(A), len(B)))
for i in range(max(len(A), len(B))):
    x = desc(A[i]) if i < len(A) else '<无>'
    y = desc(B[i]) if i < len(B) else '<无>'
    flag = '   ' if x == y else ' **'
    print('%s %02d 前: %s' % (flag, i, x))
    if x != y:
        print('      后: %s' % y)
