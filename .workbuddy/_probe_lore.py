# -*- coding: utf-8 -*-
"""读出某个 equipment 分类下每件武器的：显示名 / lore 正文(str)。vo 用于设计参考。

用法: python _probe_lore.py <category> [id]
     例: python _probe_lore.py axe           # 全部摘要(每段一行)
         python _probe_lore.py axe meteor    # 单件全文
只读。
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def grab_lore(s):
    """从 give 行里切出 lore=[...] 的方括号内容, 处理 SNBT 转义。"""
    i = s.find('lore=[')
    if i < 0:
        return None
    j = i + len('lore=[')
    depth = 0
    instr = False
    esc = False
    while j < len(s):
        c = s[j]
        if instr:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                instr = False
        else:
            if c == '"':
                instr = True
            elif c in '[{':
                depth += 1
            elif c in ']}':
                if depth == 0:
                    return s[i + len('lore=['):j]
                depth -= 1
        j += 1
    return None


TEXT = re.compile(r'"text":"((?:[^"\\]|\\.)*)"')


def flat(snbt):
    """把所有 "text":"..." 拼起来 —— 顺序即阅读顺序(extra 也在这层文本里)。"""
    out = []
    # 按 { … } 逐块处理, 每块内部按顺序收集 text
    for blk in re.finditer(r'\{[^{}]*\}', snbt):
        ts = [m.group(1) for m in TEXT.finditer(blk.group(0))]
        ts = [t for t in ts if t.strip() not in ('', ' ')]
        if ts:
            out.append(''.join(ts))
    if not out:  # 退化: 直接全抓
        ts = [m.group(1) for m in TEXT.finditer(snbt)]
        out = [''.join(ts)]
    return out


def esc(s):
    return s.replace('\\"', '"').replace('\\\\', '\\').replace('\\n', '')


def main(cat, only=None):
    d = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment', cat)
    if not os.path.isdir(d):
        print('无此分类:', cat)
        return
    for name in sorted(os.listdir(d)):
        if only and name != only:
            continue
        g = os.path.join(d, name, 'give.mcfunction')
        if not os.path.isfile(g):
            continue
        s = open(g, encoding='utf-8').read()
        line = ''
        for ln in s.split('\n'):
            if ln.strip().startswith('give '):
                line = ln
                break
        nm = re.search(r'item_name=\{text:"((?:[^"\\]|\\.)*)"[^}]*color:(\w+)', line)
        print('=' * 78)
        print('## %s   《%s》  color=%s' % (name, esc(nm.group(1)) if nm else '?',
                                            nm.group(2) if nm else '?'))
        lo = grab_lore(line)
        if lo:
            for t in flat(lo):
                t = esc(t).strip()
                if t:
                    print('   ', t)
        print()


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
