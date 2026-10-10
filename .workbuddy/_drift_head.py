# -*- coding: utf-8 -*-
"""核对: 6 件 give 的差异是否仅为「生成器缺少 ✦ 小标题」。"""
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


def heads(lore):
    out = []
    for e in lore or []:
        if isinstance(e, dict) and e.get('bold') is True:
            out.append(e.get('text', ''))
    return out


def body_text(lore):
    """所有非标题文本拼接(去空白), 用来验证正文一字不差"""
    buf = ''
    for e in lore or []:
        if not isinstance(e, dict):
            continue
        if e.get('bold') is True:
            continue
        buf += e.get('text', '')
        for x in e.get('extra', []) or []:
            if isinstance(x, dict):
                buf += x.get('text', '')
    return re.sub(r'\s+', '', buf)


for rel in FILES:
    a = comps('C:/Users/qq303/AppData/Local/Temp/givebak/equipment/%s/give.mcfunction' % rel)
    b = comps('sweetdream/data/sweetdream/function/equipment/%s/give.mcfunction' % rel)
    ha, hb = heads(a), heads(b)
    ba, bb = body_text(a), body_text(b)
    print('#### %s' % rel)
    print('   小标题 旧: %s' % ha)
    print('   小标题 新: %s' % hb)
    print('   正文完全相同: %s' % (ba == bb))
    if ba != bb:
        # 找不同
        i = 0
        while i < min(len(ba), len(bb)) and ba[i] == bb[i]:
            i += 1
        print('     首个不同 @%d: 旧…%s / 新…%s' % (i, ba[i:i + 24], bb[i:i + 24]))
    print()
