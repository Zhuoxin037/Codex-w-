# -*- coding: utf-8 -*-
"""抽取剑类 24 件的 lore 原文 + 现有标签，供逐条复核。"""
import io, os, re, sys, json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

ROOT = r'D:\数据包\sweetdream\data\sweetdream\function'
OUT = r'D:\数据包\.workbuddy\_sword_lore.txt'

SWORDS = [c for c in D.TAGS if c in (
    'aurora_dream', 'deepsea_echo', 'everfrost', 'flame_brokenbody', 'hengdao', 'hush',
    'liaoyuan', 'liuguang', 'myriad', 'qiansan', 'rebound', 'remelt', 'rogue_star',
    'shadow_blade', 'sickle_dreams', 'tinder', 'verdict',
    'tidemark', 'grayscale', 'crescent',
    'backflow_tide', 'blind_candle', 'blood_loss', 'thunder_wedge')]


def balanced(s, i):
    """从 s[i] == '[' 起，返回配对括号内的内容（含外层）。"""
    depth, q, esc = 0, False, False
    for j in range(i, len(s)):
        ch = s[j]
        if q:
            if esc:
                esc = False
            elif ch == '\\':
                esc = True
            elif ch == '"':
                q = False
            continue
        if ch == '"':
            q = True
        elif ch == '[':
            depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0:
                return s[i:j + 1]
    return None


def render(node, out):
    if isinstance(node, str):
        out.append(node)
        return
    if isinstance(node, list):
        for x in node:
            render(x, out)
        return
    if isinstance(node, dict):
        t = node.get('text')
        if t:
            out.append(t)
        ex = node.get('extra')
        if ex:
            render(ex, out)


found = {}
for dirpath, _, fs in os.walk(ROOT):
    for fn in fs:
        if not fn.endswith('.mcfunction'):
            continue
        p = os.path.join(dirpath, fn)
        for line in io.open(p, encoding='utf-8'):
            ls = line.strip()
            if not ls.startswith('give '):
                continue
            m = re.search(r'zx:\["([a-z0-9_]+)",\s*"sword"', ls)
            if not m:
                continue
            cid = m.group(1)
            if cid in found:
                continue
            k = ls.find(',lore=')
            if k < 0:
                k = ls.find('minecraft:lore=')
            if k < 0:
                found[cid] = ['(无 lore 字段)']
                continue
            i = ls.find('[', k)
            body = balanced(ls, i)
            lines = []
            try:
                arr = json.loads(body)
                cur, buf = [], []
                for node in arr:
                    buf = []
                    render(node, buf)
                    lines.append(''.join(buf))
            except Exception as e:
                lines = ['(解析失败: %s)' % e, body[:400]]
            found[cid] = lines

with io.open(OUT, 'w', encoding='utf-8') as f:
    f.write('剑类 %d / 抽到 %d\n' % (len(SWORDS), len(found)))
    for cid in SWORDS:
        f.write('\n' + '=' * 70 + '\n')
        f.write('%s   现有标签: %s\n' % (cid, ' '.join(D.TAGS[cid]) or '(空)'))
        f.write('-' * 70 + '\n')
        for ln in found.get(cid, ['(未找到 give 行)']):
            f.write(ln.replace('\\n', '') + '\n')
print('写出', OUT, len(found))
missing = [c for c in SWORDS if c not in found]
print('未找到:', missing or '无')
