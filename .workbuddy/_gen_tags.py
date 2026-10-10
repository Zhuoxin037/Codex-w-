# -*- coding: utf-8 -*-
"""_gen_tags.py —— 标签（批 A）回填器 + 反查表生成器（幂等，可反复跑）。

做两件事：
  ① 给**每一件**装备的 give 补 `custom_data.tags`（值取自 `_tags_data.TAGS`）。
     · 生成器产出的 43 件（batch5/6）已经在 build() 里写了 —— 本脚本跑到它们时
       "算出来一样"，0 改动（等于再校验一遍）；
     · 另外 40 件**手写** give 由本脚本插入。
     · 幂等：先把旧的 `,tags:[...]` 段整段摘掉，再按表重写；连跑两遍第二遍 0 改动。
  ② 生成 `sweetdream/data/sweetdream/function/tg/def/load.mcfunction`：
     · `zx:config tgdef."<词>"` = {cat,label,desc}  —— 词汇表（人读 / 校验）
     · `zx:config tge."<装备id>"` = [标签…]        —— 装备→标签（地图直读）
     · `zx:config tgidx."<词>"` = [装备id…]        —— 标签→装备（反查索引，`tg/api/ids` 用）

【字段名】物品上的键叫 **`tags`**（不是 `tg`）—— 本包 `tg` 已是 trigger 菜单的简称。
【用法】
    python .workbuddy/_gen_tags.py            # 试运行(只报告)
    python .workbuddy/_gen_tags.py --write    # 真写
"""
import io
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, '.workbuddy'))
from _tags_data import VOCAB, VOCAB_KEYS, TAGS        # noqa: E402

GIVE_ROOT = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment')
LOAD_PATH = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                         'tg', 'def', 'load.mcfunction')


# ------------------------------------------------------------------ 工具
def find_cd_block(line, key='custom_data={'):
    """返回 (key 起索引, custom_data 闭合 '}' 索引)。找不到返回 None。"""
    i = line.find(key)
    if i < 0:
        return None
    j = i + len(key) - 1                      # '{'
    depth, inq, esc = 0, False, False
    for k in range(j, len(line)):
        c = line[k]
        if inq:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                inq = False
            continue
        if c == '"':
            inq = True
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i, k
    return None


def _strip_seg(text, startkey='tags:['):
    """从 text 里摘掉 `,<startkey>…]` 这一段(含前导逗号)。返回 (新文本, 是否摘了)。"""
    i = text.find(',' + startkey)
    if i < 0:
        return text, False
    j = i + len(startkey)              # '[' 的位置
    depth, inq, esc = 0, False, False
    k = j
    while k < len(text):
        c = text[k]
        if inq:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                inq = False
        else:
            if c == '"':
                inq = True
            elif c == '[':
                depth += 1
            elif c == ']':
                depth -= 1
                if depth == 0:
                    break
        k += 1
    return text[:i] + text[k + 1:], True


def patch_line(line, tags):
    """把 give 行的 custom_data 里的 tags 段重写成 tags（表值）。返回新行。"""
    blk = find_cd_block(line)
    if not blk:
        return None
    i, end = blk
    head = line[:i] + 'custom_data={'
    inner = line[i + len('custom_data={'):end]
    inner, _had = _strip_seg(inner)
    if tags:
        inner += ',tags:' + json.dumps(tags, ensure_ascii=False, separators=(',', ':'))
    return head + inner + '}' + line[end + 1:]


def extract_id(line):
    import re
    r = re.search(r'zx:\["([a-z0-9_]+)"', line)
    return r.group(1) if r else None


# ------------------------------------------------------------------ ① 回填 give
def patch_gives(write):
    import glob
    changed, total, bad = [], 0, []
    for p in sorted(glob.glob(os.path.join(GIVE_ROOT, '*', '*', 'give.mcfunction'))):
        total += 1
        txt = io.open(p, encoding='utf-8').read()
        lines = txt.split('\n')
        gi = [n for n, l in enumerate(lines) if l.startswith('give ')]
        if len(gi) != 1:
            bad.append((p, 'give 行 %d 条' % len(gi)))
            continue
        n = gi[0]
        cid = extract_id(lines[n])
        if not cid or cid not in TAGS:
            bad.append((p, '取不到 id 或表里没有: %r' % cid))
            continue
        new = patch_line(lines[n], TAGS[cid])
        if new is None:
            bad.append((p, 'give 行没有 custom_data={...}'))
            continue
        if new != lines[n]:
            lines[n] = new
            changed.append(os.path.relpath(p, GIVE_ROOT))
            if write:
                io.open(p, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
    print('---- ① give 扫描 %d 件; 改动 %d 件; 异常 %d 件' % (total, len(changed), len(bad)))
    for rel in changed:
        print('      改 %s' % rel)
    for p, why in bad:
        print('  [×] %-52s %s' % (os.path.relpath(p, GIVE_ROOT), why))
    return len(bad)


# ------------------------------------------------------------------ ② 反查表
def build_load():
    L = []
    A = L.append
    A('# ============================================================')
    A('# sweetdream:tg/def/load —— 标签体系的运行时反查表(批 A)')
    A('# ------------------------------------------------------------')
    A('# 【这个文件是生成的】改词表/逐件标签请改 .workbuddy/_tags_data.py')
    A('#   再跑 `python .workbuddy/_gen_tags.py --write`。守门: _chk_tags.py')
    A('# 【三张表】')
    A('#   tgdef."<词>"      = {cat,label,desc}  词汇表(人读 / 校验)')
    A('#   tge."<装备id>"    = ["标签",…]        装备→标签(地图可直接 data get)')
    A('#   tgidx."<词>"      = ["装备id",…]      标签→装备(反查; tg/api/ids 用)')
    A('# 【匹配】物品上 custom_data.tags 是列表, 谓词列表匹配=「包含」语义:')
    A('#   custom_data~{zx:["staff"],tags:["dash"]}  类别+语义一条谓词同时查(AND)')
    A('#   any / at_least:N  跑 N 次单标签判定再并集 / 计数')
    A('# ============================================================')
    A('')
    A('# ---- 词汇表(tgdef): 27 词 ----')
    A('data modify storage zx:config tgdef set value {}')
    for key, cat, label, desc in VOCAB:
        A('data modify storage zx:config tgdef."%s" set value {cat:"%s",label:"%s",desc:"%s"}'
          % (key, cat, label, desc))
    A('')
    A('# ---- 装备→标签(tge): 83 件 ----')
    A('data modify storage zx:config tge set value {}')
    for cid in sorted(TAGS):
        A('data modify storage zx:config tge."%s" set value [%s]'
          % (cid, ','.join('"%s"' % t for t in TAGS[cid])))
    A('')
    A('# ---- 标签→装备(tgidx): 反查索引 ----')
    A('data modify storage zx:config tgidx set value {}')
    for key in VOCAB_KEYS:
        ids = [c for c in sorted(TAGS) if key in TAGS[c]]
        if ids:
            A('data modify storage zx:config tgidx."%s" set value [%s]'
              % (key, ','.join('"%s"' % i for i in ids)))
    A('')
    return '\n'.join(L)


def write_load(write):
    txt = build_load()
    old = io.open(LOAD_PATH, encoding='utf-8').read() if os.path.exists(LOAD_PATH) else None
    same = (old == txt)
    print('---- ② tg/def/load: %s (%d 行)' % ('未变' if same else '有变化', txt.count('\n')))
    if write and not same:
        os.makedirs(os.path.dirname(LOAD_PATH), exist_ok=True)
        io.open(LOAD_PATH, 'w', encoding='utf-8', newline='\n').write(txt)
    return 0 if same else 1


def main(write=False):
    print('词汇表 %d 词 / 装备 %d 件' % (len(VOCAB_KEYS), len(TAGS)))
    b = patch_gives(write)
    write_load(write)
    return b


if __name__ == '__main__':
    main('--write' in sys.argv)
