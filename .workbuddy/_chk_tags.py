# -*- coding: utf-8 -*-
"""_chk_tags.py —— 标签体系（批 A）守门。

四查：
  ① 词汇表自检：`_tags_data.TAGS` 里用到的词必须都在 `VOCAB` 里。
  ② 逐件 give：`custom_data.tags` 必须**逐字等于**表值（顺序也要一致）——
     生成器那 43 件由 batch5/6 写、手写那 40 件由 `_gen_tags.py` 写，这里统一复核。
  ③ `tg/def/load.mcfunction` 必须**逐字节等于** `_gen_tags.build_load()`（防漂移：
     有人手改了生成文件、或改了表没重跑生成器）。
  ④ 三张表自洽：`tge` 覆盖全部装备、`tgidx` 与 `tge` 互为反查。

【用法】python .workbuddy/_chk_tags.py   ->  "0 问题" 为通过
"""
import glob
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, '.workbuddy'))
from _tags_data import VOCAB_KEYS, TAGS          # noqa: E402
import _gen_tags as G                             # noqa: E402


def _give_line(p):
    for l in io.open(p, encoding='utf-8').read().split('\n'):
        if l.startswith('give '):
            return l
    return None


def _read_tags(line):
    blk = G.find_cd_block(line)
    if not blk:
        return None
    i, end = blk
    inner = line[i + len('custom_data={'):end]
    m = re.search(r'tags:\[([^\]]*)\]', inner)
    if not m:
        return []
    return re.findall(r'"([^"]*)"', m.group(1))


def main():
    problems = []

    # ---- ① 词汇表自检 ----
    for cid, ts in TAGS.items():
        for t in ts:
            if t not in VOCAB_KEYS:
                problems.append(('词汇表', '%s 用了词表外的标签 "%s"' % (cid, t)))

    # ---- ② 逐件 give ----
    n = 0
    for p in sorted(glob.glob(os.path.join(G.GIVE_ROOT, '*', '*', 'give.mcfunction'))):
        n += 1
        line = _give_line(p)
        rel = os.path.relpath(p, G.GIVE_ROOT)
        if line is None:
            problems.append(('give', '%s 没有 give 行' % rel))
            continue
        m = re.search(r'zx:\["([a-z0-9_]+)"', line)
        cid = m.group(1) if m else None
        if cid not in TAGS:
            problems.append(('give', '%s 取不到 id 或表里没有(%r)' % (rel, cid)))
            continue
        got = _read_tags(line)
        want = TAGS[cid]
        if got is None:
            problems.append(('give', '%s 没有 custom_data={...}' % rel))
        elif got != want:
            problems.append(('give', '%s 的 tags 与表不符: 磁盘 %s ≠ 表 %s' % (rel, got, want)))

    # ---- ③ tg/def/load 漂移 ----
    disk = io.open(G.LOAD_PATH, encoding='utf-8').read() if os.path.exists(G.LOAD_PATH) else None
    want = G.build_load()
    if disk != want:
        problems.append(('load', 'tg/def/load.mcfunction 与生成器不符(改表后没重跑 _gen_tags.py, '
                                 '或有人手改了生成文件)'))

    # ---- ④ 三表自洽 ----
    if disk:
        def _ids_of(key):
            return set(re.findall(r'"([a-z0-9_]+)"', key))
        tge_lines = re.findall(r'tge\."([a-z0-9_]+)" set value \[([^\]]*)\]', disk)
        tge = {k: _ids_of(v) for k, v in tge_lines}
        tgidx_lines = re.findall(r'tgidx\."([a-z0-9_]+)" set value \[([^\]]*)\]', disk)
        tgidx = {k: _ids_of(v) for k, v in tgidx_lines}
        if set(tge) != set(TAGS):
            problems.append(('表', 'tge 覆盖的装备与 TAGS 不一致: 缺 %s / 多 %s'
                             % (sorted(set(TAGS) - set(tge)), sorted(set(tge) - set(TAGS)))))
        for cid, ts in TAGS.items():
            if set(tge.get(cid, set())) != set(ts):
                problems.append(('表', 'tge."%s" 与 TAGS 不符' % cid))
        # 反查一致性
        for key in VOCAB_KEYS:
            exp = {c for c, ts in TAGS.items() if key in ts}
            got = tgidx.get(key, set())
            if exp != got:
                problems.append(('表', 'tgidx."%s" 反查不符: 期望 %s 实得 %s'
                                 % (key, sorted(exp), sorted(got))))
        # 每个装备 id 至少出现在一条 tgidx 里(除非空标签)
        for cid, ts in TAGS.items():
            if ts and not any(cid in v for v in tgidx.values()):
                problems.append(('表', '%s 有标签却没出现在任何 tgidx 里' % cid))

    print('---- 装备 %d 件 / 词表 %d 词; 问题 %d 条' % (n, len(VOCAB_KEYS), len(problems)))
    for kind, why in problems:
        print('  [×][%s] %s' % (kind, why))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
