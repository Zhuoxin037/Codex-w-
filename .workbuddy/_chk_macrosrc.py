#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""_chk_macrosrc.py —— 「实体 data 当宏源」的参数对账(守门)

【守什么】
  Minecraft 的宏参数**只能取键名, 不能取列表下标**:
      data.zx = {a:[I;1,2,3,4]}   →   `$(a0)` 找不到键 "a0" ⇒ 缺少传入参数
      ⇒ **整个宏函数一次都不执行**, 而且几乎零日志。
  (想读列表元素得写 `a[0]`, 但宏参数名里不许出现方括号 —— 所以唯一正解就是
   "喂宏的 storage 逐键铺平": u0/u1/…/a0/…/b3。)

【真实事故 2026-10-12】
  超限·电弧的放电锚把配对两端 UUID 存成 data.zx.a=[I;…] 列表, 宏叶子
  ol_tick_go / ol_end_go 用 $(a0) 读 ⇒ 两条宏静默作废 ⇒ "超限电弧完全没效果"
  (锚永远不减秒、永不收尾、放电从不发生; 现场 3 个 marker 的 zx.arc_wt 恒为 3,
   两端 zx.status.dianci 还挂着)。

【怎么查】自动发现"实体 data → 宏叶子"的链, 逐键对账:
  ① 某函数 L 里有  `data modify storage zx:work <n> set from entity @… data.zx`
  ② 同一个 L 里又有 `function <叶子> with storage zx:work <n>`
     ⇒ 叶子吃的是"实体 data"这份东西
  ③ 找到这个实体是谁生成的: 全包搜 `run function <L>`, 从那一行里抠出选择器的
     `tag=<T>`(调度处, 如 lib/second 的 `as @e[type=marker,tag=zx.arc_w,…]`)
  ④ 全包搜同时含 `"<T>"` 与 `data:{` 的 summon/merge 行, 解析出 data.zx 下的**键**
  ⑤ 要求: 叶子引用的每个宏参数名 ∈ 那些键。缺 = 报错(宏静默作废)。

跳过(不算问题): 找不到调度处/找不到生成处 —— 那是"查不到契约", 不是"契约不符"。
"""
import io
import os
import re
import sys

ROOT = r'D:\数据包\sweetdream\data\sweetdream\function'

LOAD_RE = re.compile(r'data modify storage zx:work ([A-Za-z_][\w]*)\s+set from entity \S+ data\.zx\b')
LAYER_RE = re.compile(r'function ([a-z0-9_]+:[\w/:]+) with storage zx:work ([A-Za-z_][\w]*)')
ARG_RE = re.compile(r'\$\(([A-Za-z_][A-Za-z_0-9]*)\)')
CALL_RE = re.compile(r'run function ([a-z0-9_]+:[\w/:]+)')
TAG_RE = re.compile(r'tag=([A-Za-z0-9_.:]+)')


def brace_end(s, i):
    """s[i] == '{' -> 返回配对 '}' 的下标(跳过字符串里的括号)。"""
    depth = 0
    n = len(s)
    while i < n:
        c = s[i]
        if c == '"':
            i += 1
            while i < n and s[i] != '"':
                i += 2 if s[i] == '\\' else 1
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def top_keys(inner):
    """把 `{k:v,k2:v2,…}` 的最外层键抠出来(值里可以有嵌套的 {} / [] 与字符串)。"""
    keys = []
    depth = 0
    n = len(inner)
    i = 0
    start = 0
    while i < n:
        c = inner[i]
        if c == '"':
            i += 1
            while i < n and inner[i] != '"':
                i += 2 if inner[i] == '\\' else 1
        elif c in '{[':
            depth += 1
        elif c in '}]':
            depth -= 1
        elif c == ',' and depth == 0:
            piece = inner[start:i]
            if ':' in piece:
                keys.append(piece.split(':', 1)[0].strip().strip('"'))
            start = i + 1
        i += 1
    piece = inner[start:]
    if ':' in piece:
        keys.append(piece.split(':', 1)[0].strip().strip('"'))
    return keys


def zx_keys(line):
    """从一行里抠出 `data:{zx:{…}}` 的键集合(找不到就返回 None)。"""
    m = re.search(r'data:\{', line)
    if not m:
        return None
    j = brace_end(line, m.end() - 1)
    if j < 0:
        return None
    inner = line[m.end():j]
    if 'zx' not in top_keys(inner):
        return None
    # ★ 不要写 (?<=\{|,) 这种 lookbehind —— inner 正好以 "zx:" 开头时它匹配不到
    m2 = re.search(r'(?:^|,)\s*"?zx"?\s*:', inner)
    if not m2:
        return None
    k = inner.find('{', m2.end())
    if k < 0:
        return None
    j2 = brace_end(inner, k)
    if j2 < 0:
        return None
    return set(top_keys(inner[k + 1:j2]))


def main():
    files = {}
    for dirpath, _d, fs in os.walk(ROOT):
        for f in fs:
            if not f.endswith('.mcfunction'):
                continue
            p = os.path.join(dirpath, f)
            rel = os.path.relpath(p, ROOT).replace('\\', '/')[:-len('.mcfunction')]
            files['sweetdream:' + rel] = io.open(p, encoding='utf-8').read()

    problems = []
    for lfq, ltxt in sorted(files.items()):
        m = LOAD_RE.search(ltxt)
        if not m:
            continue
        node = m.group(1)
        leaves = {mm.group(1) for mm in LAYER_RE.finditer(ltxt) if mm.group(2) == node}
        if not leaves:
            continue
        for leaf in sorted(leaves):
            ltext = files.get(leaf)
            if ltext is None:
                problems.append((lfq, '找不到宏叶子 %s' % leaf))
                continue
            args = sorted(set(ARG_RE.findall(ltext)))
            if not args:
                continue
            # 调度处: 谁把实体喂给 L
            tags = set()
            for _f, t in files.items():
                for line in t.split('\n'):
                    if line.lstrip().startswith('#'):
                        continue
                    if lfq in line and 'run function' in line:
                        tags |= set(TAG_RE.findall(line))
            tags = {t for t in tags if not t.startswith('zx.status')}
            if not tags:
                continue
            # 生成处: 带这个 tag 的实体 NBT
            keys = set()
            found = False
            for _f, t in files.items():
                for line in t.split('\n'):
                    if line.lstrip().startswith('#'):
                        continue
                    if 'data:{' not in line:
                        continue
                    if not any('"%s"' % tg in line for tg in tags):
                        continue
                    ks = zx_keys(line)
                    if ks is not None:
                        keys |= ks
                        found = True
            if not found:
                continue
            miss = [a for a in args if a not in keys]
            if miss:
                problems.append((lfq,
                    '宏叶子 %s 的参数 %s 在该实体(tag=%s)的 data.zx 里**不是键**(data.zx 只有 %s) '
                    '⇒ 宏参数取不到值, 整段静默作废。宏参数只能取键、不能取列表下标; '
                    '喂宏的 storage 必须逐键铺平'
                    % (leaf, miss, ','.join(sorted(tags)), sorted(keys))))

    print('---- 扫描 %d 个函数' % len(files))
    for fp, msg in problems:
        print('[问题] %s : %s' % (fp, msg))
    print('---- 问题 %d 条' % len(problems))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
