# -*- coding: utf-8 -*-
"""把所有装备 lore 渲染成可读文本（离线审查用，不改任何文件）。

用法:
    python .workbuddy/_dump_lore.py                 # 全部 -> logs/lore_dump.txt
    python .workbuddy/_dump_lore.py <路径子串> ...   # 只看路径含该子串的
    python .workbuddy/_dump_lore.py --stdout        # 打到屏幕

颜色名缩写: 灰=gray 青=aqua 黄=yellow 金=gold 深灰=dark_gray 红=red
            暗紫=dark_purple 暗绿=dark_green 白=white 绿=green 蓝=blue
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lore_fmt as L  # noqa: E402

CNAME = {
    'gray': '灰', 'aqua': '青', 'yellow': '黄', 'gold': '金', 'dark_gray': '深灰',
    'red': '红', 'dark_purple': '暗紫', 'dark_green': '暗绿', 'white': '白',
    'green': '绿', 'blue': '蓝', 'light_purple': '淡紫', 'dark_red': '暗红',
    'dark_blue': '暗蓝', 'dark_aqua': '暗青', 'black': '黑',
}


def seg(e, inherited=None):
    """把一条组件渲染成 (文本, 颜色标记)"""
    t = e.get('text', '')
    if 'extra' in e:
        parts = []
        for x in e['extra']:
            sub, c = seg(x, inherited)
            parts.append(sub if not c else '%s(%s)' % (sub, c))
        return t + ''.join(parts), CNAME.get(inherited or e.get('color', ''), '')
    c = CNAME.get(e.get('color') or inherited or '', '')
    mark = []
    if e.get('bold'):
        mark.append('粗')
    if e.get('italic') is False:
        pass
    return t, '+'.join([c] + mark) if c else ''


def dump(path, out):
    s = io.open(path, encoding='utf-8').read()
    rel = os.path.relpath(path, L.ROOT).replace('\\', '/')
    out.append('#' * 4 + ' ' + rel)
    n = 0
    for m in re.finditer(r'\blore\s*[:=]\s*\[', s):
        i = s.index('[', m.end() - 1)
        j = L._find_array(s, i)
        try:
            arr = L.snbt_to_json(s[i:j + 1])
        except Exception as ex:
            out.append('   [解析失败] %s' % ex)
            continue
        n += 1
        out.append('   ---- lore 块 %d (%d 行) ----' % (n, len(arr)))
        for k, e in enumerate(arr):
            t, c = seg(e)
            label = ('(%s)' % c) if c else ''
            out.append('   %2d | %s%s' % (k + 1, t, label))
    out.append('')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    to_stdout = '--stdout' in sys.argv
    paths = L.collect_targets()
    if args:
        paths = [p for p in paths if any(a in p.replace('\\', '/') for a in args)]
    out = []
    for p in paths:
        dump(p, out)
    text = '\n'.join(out)
    if to_stdout:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        print(text)
    else:
        dst = os.path.join(r'D:\数据包\logs', 'lore_dump.txt')
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        io.open(dst, 'w', encoding='utf-8', newline='\n').write(text + '\n')
        print('写入 %s  (%d 个文件, %d 行)' % (dst, len(paths), len(out)))


if __name__ == '__main__':
    main()
