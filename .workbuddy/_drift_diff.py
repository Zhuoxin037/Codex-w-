# -*- coding: utf-8 -*-
"""逐 component 对照: 生成器文本(磁盘当前) vs 磁盘原状(/tmp/givebak)。
输出「旧段 -> 新段」的最小差异, 而不是整行。"""
import io, re

FILES = ["armor/furnace_core", "armor/lightless_sea", "armor/withered_garden",
         "bow/lucid_dream", "bow/sculk_echo", "staff/apocalypse",
         "armor/resonance", "bow/rainbow", "sword/myriad"]


def segs_of(p, field='lore'):
    s = io.open(p, encoding='utf-8').read()
    if field == 'name':
        m = re.search(r'item_name=(\{.*?\}),lore=', s, re.S)
        if not m:
            m = re.search(r'item_name=(\{.*?\}),', s, re.S)
        if not m:
            return None
        return m.group(1)
    m = re.search(r'lore=\[(.*)\],(?:unbreakable|enchantments|custom_data|consumable|tooltip_display)', s, re.S)
    if not m:
        return None
    return m.group(1)


def split_lines(body):
    res, depth, cur = [], 0, ''
    for ch in body:
        if ch == '[':
            depth += 1
            if depth == 1:
                cur = ''
                continue
        elif ch == ']':
            depth -= 1
            if depth == 0:
                res.append(cur)
                continue
        if depth >= 1:
            cur += ch
    return res


TXT = re.compile(r'"text":"((?:[^"\\]|\\.)*)"')
SEG = re.compile(r'\{"text":"((?:[^"\\]|\\.)*)"([^}]*)\}')


def seg_list(line):
    out = []
    for text, attrs in SEG.findall(line):
        attrs = re.sub(r'"(?:color|bold|italic|underlined)":"?[^,"}]*"?', '', attrs)
        attrs = re.sub(r'[,:]+', '', attrs).strip()
        out.append((text, attrs))
    return out


for rel in FILES:
    pa = 'C:/Users/qq303/AppData/Local/Temp/givebak/equipment/%s/give.mcfunction' % rel
    pb = 'sweetdream/data/sweetdream/function/equipment/%s/give.mcfunction' % rel
    print('=' * 78)
    print('#### %s' % rel)
    print('=' * 78)
    # 名字
    na, nb = segs_of(pa, 'name'), segs_of(pb, 'name')
    if na != nb:
        print('  [名字 旧] %s' % na)
        print('  [名字 新] %s' % nb)
    la, lb = segs_of(pa), segs_of(pb)
    if la is None or lb is None:
        print('  (lore 未匹配)')
        continue
    A = [seg_list(x) for x in split_lines(la)]
    B = [seg_list(x) for x in split_lines(lb)]
    for i in range(max(len(A), len(B))):
        sa = A[i] if i < len(A) else None
        sb = B[i] if i < len(B) else None
        if sa == sb:
            continue
        if sa is None:
            print('  [第%d行 · 新增] %r' % (i, sb))
        elif sb is None:
            print('  [第%d行 · 删除] %r' % (i, sa))
        else:
            ta = ''.join(t for t, _ in sa)
            tb = ''.join(t for t, _ in sb)
            if ta == tb:
                print('  [第%d行 · 仅切分] 旧 %d 段 -> 新 %d 段' % (i, len(sa), len(sb)))
                print('        旧段: %r' % [t for t, _ in sa])
                print('        新段: %r' % [t for t, _ in sb])
            else:
                print('  [第%d行 · 文字变了]' % i)
                print('        旧: %s' % ta)
                print('        新: %s' % tb)
    print()
