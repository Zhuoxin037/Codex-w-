# -*- coding: utf-8 -*-
"""_gen_rarity.py —— 稀有度后处理生成器（幂等）。

真源：.workbuddy/rarity_20261107/rarity_truth.csv（由 make_truth.py 从用户定档表合并）。
写入两处：
  1. `custom_data.rarity:"t1".."t5"`（插在 custom_data 第一个字段，避开 _gen_tags.py
     的 tags 末尾 patch，两个生成器互不打回）。档位为「无」/ 空则删除该字段。
  2. lore 最前面加一行档位眉批 + 一个空行。眉批是 **bold 行**，
     lore_fmt.rebuild 的 _is_head 会原样保留（含颜色），无需改规范器；
     check.py 的 loresp 只对 `✦` 开头的 bold 行查前置空行，眉批不受影响。

不碰：item_name 主题色、底材、数值、段序、tags、skill、profession。

用法：
  python .workbuddy/_gen_rarity.py             # dry-run，打印将改多少件
  python .workbuddy/_gen_rarity.py --write     # 写盘
  python .workbuddy/_gen_rarity.py --check     # 守门：0 处 = 同步

★ 已登记进 _chk_gen_drift.py 的 GENERATORS：临时目录里也会跑一遍，
  否则那 8 个 give 生成器产出的文件不含眉批，会被误判成漂移。
  模块级 BASE 可被 _chk_gen_drift 覆盖。
"""
import csv
import io
import json
import os
import pathlib
import re
import sys
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parents[1]
TRUTH = ROOT / '.workbuddy' / 'rarity_20261107' / 'rarity_truth.csv'
BASE = str(ROOT / 'fallendream' / 'data' / 'fallendream' / 'function' / 'equipment')

TIERS = ['常器', '异器', '精器', '秘器', '禁器']
TIER_ID = {'常器': 't1', '异器': 't2', '精器': 't3',
           '秘器': 't4', '禁器': 't5'}
TIER_COLOR = {'常器': 'white', '异器': 'gray', '精器': 'aqua',
              '秘器': 'gold', '禁器': 'dark_red'}
JOB_CN = {'职业1': '魔导士', '职业2': '狂徒', '职业3': '歌者', '职业4': '同生'}
SLOT_CN = {'helmet': '头盔', 'chestplate': '胸甲',
           'leggings': '护腿', 'boots': '靴子'}

RE_CD = re.compile(r'custom_data=\{')
RE_RARITY_FIELD = re.compile(r'(?:\{)?,?\s*rarity\s*:\s*"t[1-5]"\s*,?', re.S)


def _array_end(t, start):
    """start 指向 '['，返回配对 ']' 的位置（跳过字符串内括号）。"""
    depth, ins, esc = 0, False, False
    for i in range(start, len(t)):
        c = t[i]
        if ins:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                ins = False
            continue
        if c == '"':
            ins = True
        elif c == '[':
            depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0:
                return i
    raise ValueError('lore 数组不配对')


def _brace_end(t, start):
    """start 指向 '{'，返回配对 '}' 的位置。"""
    depth, ins, esc = 0, False, False
    for i in range(start, len(t)):
        c = t[i]
        if ins:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                ins = False
            continue
        if c == '"':
            ins = True
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i
    raise ValueError('custom_data 不配对')


def split_top(s):
    """按顶层逗号切分 SNBT 对象内容（跳过字符串与嵌套 [] / {}）。"""
    parts, start, depth = [], 0, 0
    ins = esc = False
    for i, c in enumerate(s):
        if ins:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                ins = False
            continue
        if c == '"':
            ins = True
        elif c in '[{':
            depth += 1
        elif c in ']}':
            depth -= 1
        elif c == ',' and depth == 0:
            parts.append(s[start:i])
            start = i + 1
    parts.append(s[start:])
    return [p for p in parts if p.strip()]


def is_banner(e):
    return (isinstance(e, dict) and e.get('bold') is True and 'extra' not in e
            and any(str(e.get('text', '')).startswith(t + ' · ') for t in TIERS))


def banner_for(tier, row):
    cat = row['类别']
    if cat == '盔甲':
        for k, v in SLOT_CN.items():
            if k in row['底材']:
                cat = v
                break
    job = JOB_CN.get(row['标记'].split('·')[0].strip(), '通用')
    text = '%s · %s · %s' % (tier, cat, job)
    # 顺序与 lore_fmt._entry 输出一致，保证逐字收敛
    return {'text': text, 'color': TIER_COLOR[tier],
            'bold': True, 'italic': False}


def patch_give(src, row):
    """返回 (新文本, 动作列表)。幂等：先摘旧字段/旧眉批，再按真源写回。"""
    tier = (row['档位'] or '').strip()
    acts = []

    # ---------- 1) custom_data.rarity ----------
    m = RE_CD.search(src)
    if not m:
        raise ValueError('找不到 custom_data={')
    b = m.end() - 1                       # 指向 '{'
    e = _brace_end(src, b)
    cd = src[b + 1:e]
    parts = [p for p in split_top(cd)
             if not re.fullmatch(r'\s*rarity\s*:\s*"t[1-5]"\s*', p)]
    # ★ rarity 排第 2 个字段：`_chk_give.py` 要求 give 行含 `custom_data={zx:[`，
    #   把 rarity 放最前面会打断这个字面串（28 件旧装备报错）。
    #   末尾留给 tags（_gen_tags.py 会把 tags append 到 custom_data 末尾），互不干扰。
    if tier in TIERS:
        parts.insert(1, 'rarity:"%s"' % TIER_ID[tier])
    new_cd = '{' + ','.join(parts)
    if new_cd != '{' + cd:
        acts.append('rarity=' + (TIER_ID.get(tier, 'none')))
        src = src[:b] + new_cd + src[e:]

    # ---------- 2) lore 眉批 ----------
    s = src.find('lore=[')
    if s < 0:
        raise ValueError('找不到 lore=[')
    a = s + 5                              # 指向 '['
    z = _array_end(src, a)
    arr = json.loads(src[a:z + 1])
    # 删旧眉批及其后紧跟的一个空行（无论档位是否变化，先清干净）
    while arr and is_banner(arr[0]):
        arr.pop(0)
        acts.append('del-banner')
        if arr and isinstance(arr[0], dict) and 'extra' not in arr[0] \
                and str(arr[0].get('text', '')).strip() == '':
            arr.pop(0)
    if tier in TIERS:
        arr.insert(0, {'text': ' ', 'italic': False})
        arr.insert(0, banner_for(tier, row))
        acts.append('banner=' + tier)
    new_arr = json.dumps(arr, ensure_ascii=False, separators=(',', ':'))
    if new_arr != src[a:z + 1]:
        src = src[:a] + new_arr + src[z + 1:]
    return src, acts


def iter_truth():
    with TRUTH.open(encoding='utf-8-sig', newline='') as f:
        return {r['id']: r for r in csv.DictReader(f)}


def main():
    write = '--write' in sys.argv
    check = '--check' in sys.argv
    truth = iter_truth()
    base = pathlib.Path(BASE)
    stat = Counter()
    samples = []
    problems = []

    for eid, row in sorted(truth.items()):
        hits = list(base.rglob(eid + '/give.mcfunction'))
        if not hits:
            stat['skip-no-file'] += 1
            continue
        p = hits[0]
        src = p.read_text(encoding='utf-8')
        try:
            new, acts = patch_give(src, row)
        except Exception as ex:
            problems.append('%s: %s' % (eid, ex))
            continue
        if new == src:
            stat['unchanged'] += 1
            continue
        stat['changed'] += 1
        for a in acts:
            stat[a] += 1
        if len(samples) < 4:
            i = new.find('lore=[')
            samples.append((eid, row['档位'], new[i:i + 170]))
        if write:
            p.write_text(new, encoding='utf-8', newline='\n')

    print('稀有度生成器 %s | 真源 %d 件 | 改动 %d / 未变 %d / 无文件 %d'
          % ('--write' if write else ('--check' if check else 'dry-run'),
             len(truth), stat['changed'], stat['unchanged'], stat['skip-no-file']))
    for k in sorted(k for k in stat if k.startswith(('rarity=', 'banner=', 'del-'))):
        print('  %-16s %d' % (k, stat[k]))
    for eid, tier, seg in samples:
        print('  样例 %-18s %-4s %s' % (eid, tier or '-', seg))
    if problems:
        print('!! 失败 %d 件:' % len(problems))
        for x in problems[:20]:
            print('   ', x)
    if check and (stat['changed'] or problems):
        return 1
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
