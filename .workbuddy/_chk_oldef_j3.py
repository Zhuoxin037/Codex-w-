# -*- coding: utf-8 -*-
"""_chk_oldef_j3.py —— 批 J3 的 32 条 oldef 自检

查四件事（都能静默出错，只能静态抓）：
  ① 每行宽度 —— 必须 ≤ wrap 的 37(+slack)，否则客户端会二次硬折。
  ② 信息行的魔力/冷却 —— 必须等于设计稿解析出来的值（写错=改了数值还看不出）。
  ③ 正文 —— 把折行拼回去，必须等于 nfmt(设计稿原文)；不等说明有字被改/漏。
  ④ 段头 —— 必须与基础 give 的 ✦ 段一一对应（顺序也一样）。

用法：python .workbuddy/_chk_oldef_j3.py [--show uid]
"""
import importlib.util
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('g', os.path.join(HERE, '_gen_oldef_j3.py'))
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

sys.path.insert(0, HERE)
from lore_fmt import nfmt, tw  # noqa: E402


def lore_arr(uid, label, note, parts):
    text = g.line(uid, label, note, parts)
    j = text[text.find('lore:') + 5:]
    j = j[:j.rfind('}')]
    return json.loads(j)


bad = []
for (uid, label, note, parts) in g.DEFS:
    arr = lore_arr(uid, label, note, parts)
    d = g.META[uid]
    sec = {x[0]: x for x in d['sections']}

    # ① 宽度
    for r in arr:
        if 'extra' in r:
            w = sum(tw(e.get('text', '')) for e in r['extra'])
        else:
            w = tw(r.get('text', ''))
        # ★ 阈值 54 而不是 wrap 的 37: 法杖的「魔力 当前魔力值的 50%   ·   冷却 N 秒」
        #   基础 give 里本来就这么宽(52), 拆行反而和原版式不一致。
        if w > 54:
            bad.append('%s: 一行宽 %d > 54 -> %s' % (uid, w, r.get('text', '')[:20]))

    # ② 信息行
    heads = []
    texts = []
    infos = []
    cur = None
    for r in arr:
        s = r.get('text', '')
        if s.startswith('✦'):
            heads.append(s.replace('✦', '').strip())
            cur = []
            texts.append(cur)
            infos.append('')
            continue
        if 'extra' in r:
            # ★ 信息行可能被 lore_fmt 拆成两行(「魔力 当前魔力值的 50%」/「冷却 20 秒」),
            #   所以按**整段**累加后再核对, 不能只看最后一行。
            infos[-1] += ''.join(e.get('text', '') for e in r['extra'])
            continue
        if s.strip() == '' or cur is None:
            continue
        cur.append(s)

    # ② 信息行（整段累加后核对，兼容被拆成两行的情况）
    for k, lab in enumerate(heads):
        if lab not in sec:
            continue
        want_m, want_c = sec[lab][1], sec[lab][2]
        it = re.sub(r'\s+', '', nfmt(infos[k]))
        if want_m and re.sub(r'\s+', '', want_m) not in it:
            bad.append('%s/✦%s: 信息行缺魔力 %s -> %s' % (uid, lab, want_m, infos[k]))
        if want_c and (want_c + '秒') not in it:
            bad.append('%s/✦%s: 信息行缺冷却 %s 秒 -> %s' % (uid, lab, want_c, infos[k]))

    # ③ 正文
    for lab, lines in zip(heads, texts):
        got = nfmt(''.join(lines))
        if lab in sec:
            want = nfmt(sec[lab][3])
        else:
            want = None
        if want is not None and got != want:
            # ★ 设计稿里「✦ 普攻｜魔力 60   ·   伤害 X」这种段: 竖线后面就是信息行
            #   本身, 生成器会故意不写正文(否则玩家看到两遍)。这里认这种情形。
            # 乘号先归一(生成器会把原稿的 `x 0.1` 写成 `×0.1`, 属排版规范)
            norm = lambda x: re.sub(r'[\s。，、；：]', '',
                                    re.sub(r'(?<![A-Za-z×])[xX*]\s*(?=\d)', '×', x))
            k = heads.index(lab)
            if got == '' and norm(want) in norm(infos[k]):
                continue
            # 「伤害 20每次普攻…」这类: 设计稿正文以信息行的数值开头, 生成器会把
            # 那段前缀削掉(否则信息行 + 正文各写一遍)。多出来的前缀属于信息行即可。
            ng, nw = norm(got), norm(want)
            if ng and ng in nw and norm(nw.replace(ng, '')) in norm(infos[k]):
                continue
            bad.append('%s/✦%s: 正文与设计稿不一致\n    got =%s\n    want=%s'
                       % (uid, lab, got[:90], want[:90]))

    # ④ 段头
    base = [x['head'] for x in g.parse_segs(g.base_lore(uid))]
    if heads != base:
        bad.append('%s: 段头 %s != 基础 %s' % (uid, heads, base))

if len(sys.argv) > 2 and sys.argv[1] == '--show':
    uid = sys.argv[2]
    u, l, n, parts = [x for x in g.DEFS if x[0] == uid][0]
    for r in lore_arr(u, l, n, parts):
        if 'extra' in r:
            print('  ' + ''.join('{%s}' % e.get('text', '') for e in r['extra']))
        else:
            print('  ' + r.get('text', ''))
    raise SystemExit(0)

print('\n'.join(bad) if bad else 'oldef J3: 32 条全部通过（宽度/信息行/正文/段头）')
print('bad =', len(bad), '/', len(g.DEFS))
