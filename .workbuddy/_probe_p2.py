# -*- coding: utf-8 -*-
"""_probe_p2.py —— 反向探针: 逐条破坏 N05/N06 的守门形态, 证明 check.py 会报警。

约定(项目惯例): 每条破坏 -> 跑 check.py -> 断言目标桶非 0 -> 还原 -> 再跑一次确认 0。
"新锁必须反向证明会报警" —— 只看"合计 0"不算数。
"""
import io
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PY = sys.executable
CHK = os.path.join(ROOT, '.workbuddy', 'check.py')

REL = {
    'reset': 'sweetdream/data/sweetdream/function/event/player_reset.mcfunction',
    'join': 'manacore-1.0.0/data/manacore/function/internal/join/new.mcfunction',
    'reset_all': 'manacore-1.0.0/data/manacore/function/debug/reset_all.mcfunction',
    'tag_mc': 'manacore-1.0.0/data/manacore/tags/function/event/player_first_join.json',
    'tag_sd': 'sweetdream/data/manacore/tags/function/event/player_first_join.json',
    'handler': 'sweetdream/data/sweetdream/function/event/player_first_join.mcfunction',
}


def rd(key):
    with open(os.path.join(ROOT, REL[key]), encoding='utf-8') as f:
        return f.read().split('\n')


def wr(key, lines):
    with open(os.path.join(ROOT, REL[key]), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines))


def run_check():
    p = subprocess.run([PY, CHK], capture_output=True, text=True,
                       encoding='utf-8', errors='replace', cwd=ROOT)
    out = p.stdout
    res = {}
    for m in re.finditer(r'\[(.+?)\] (\d+) 条', out):
        res[m.group(1)[:24]] = int(m.group(2))
    tot = re.search(r'合计问题: (\d+)', out)
    res['__total__'] = int(tot.group(1)) if tot else -1
    res['__rc__'] = p.returncode
    return res, out


# ---- 每条 = (说明, 施加破坏的函数(返回还原信息), 期望命中的桶关键字, 期望桶) ----
def m_extra_reset():
    ls = rd('reset')
    ls.append('scoreboard players reset @s zx.probe_zzz')
    wr('reset', ls)


def m_drop_reset():
    ls = rd('reset')
    for i, l in enumerate(ls):
        if l.strip() == 'scoreboard players reset @s zx.meta':
            del ls[i]
            wr('reset', ls)
            return
    raise RuntimeError('找不到 zx.meta 行')


def m_blank_reset():
    ls = rd('reset')
    out, hit = [], False
    for l in ls:
        if l.strip().startswith('scoreboard players reset @s zx.'):
            if not hit:
                out.append('scoreboard players reset @s')
                hit = True
            continue
        out.append(l)
    if not hit:
        raise RuntimeError('清单里没有 reset @s zx.* 行')
    wr('reset', out)


def m_drop_first_join():
    ls = rd('join')
    for i, l in enumerate(ls):
        if l.strip() == 'function #manacore:event/player_first_join':
            del ls[i]
            wr('join', ls)
            return
    raise RuntimeError('找不到 player_first_join 调用行')


def m_reorder_first_join():
    ls = rd('join')
    call = 'function #manacore:event/player_first_join'
    reg = 'function manacore:internal/join/register with storage manacore:work a'
    ci = next(i for i, l in enumerate(ls) if l.strip() == call)
    del ls[ci]
    ri = next(i for i, l in enumerate(ls) if l.strip() == reg)
    ls.insert(ri, call)          # 插到 register 之前 = 顺序错
    wr('join', ls)


def m_drop_gen():
    ls = rd('reset_all')
    for i, l in enumerate(ls):
        if l.strip() == 'scoreboard players reset @a manacore.gen':
            del ls[i]
            wr('reset_all', ls)
            return
    raise RuntimeError('找不到 manacore.gen reset 行')


def m_tag_mc():
    ls = rd('tag_mc')
    wr('tag_mc', [l.replace('manacore:event/noop', 'manacore:event/nope') for l in ls])


def m_tag_sd():
    ls = rd('tag_sd')
    wr('tag_sd', [l.replace('sweetdream:event/player_first_join',
                            'sweetdream:event/player_reset') for l in ls])


def m_handler():
    ls = rd('handler')
    for i, l in enumerate(ls):
        if l.strip() == 'function sweetdream:event/player_reset':
            del ls[i]
            wr('handler', ls)
            return
    raise RuntimeError('找不到 handler 的调用行')


CASES = [
    ('A 清单多清一条(zx.probe_zzz)', m_extra_reset, 'N06 多清', 'resetset'),
    ('B 清单漏清一条(zx.meta)', m_drop_reset, 'N06 漏清', 'resetset'),
    ('C 退回无范围全清', m_blank_reset, 'N06 回归', 'resetset'),
    ('D join/new 少抛 first_join', m_drop_first_join, 'player_first_join', 'regress'),
    ('E join/new 抛在 register 之前', m_reorder_first_join, 'player_first_join', 'regress'),
    ('F reset_all 少清 manacore.gen', m_drop_gen, 'manacore.gen', 'regress'),
    ('G manacore 侧 tag 占位被改坏', m_tag_mc, 'noop', 'regress'),
    ('H sweetdream 侧 tag 没挂 handler', m_tag_sd, 'player_first_join', 'regress'),
    ('I handler 不再复用清单', m_handler, 'player_reset', 'regress'),
]


def main():
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8',
                                  errors='replace')
    snaps = {k: rd(k) for k in REL}
    base, _ = run_check()
    print('基线: 合计 %d' % base['__total__'])
    ok = True
    for desc, fn, needle, bucket in CASES:
        for k in REL:
            wr(k, snaps[k])
        fn()
        res, out = run_check()
        # ★ 桶标题关键字必须**唯一**: '清单' 会和 datarm 标题里的"可遍历清单"撞车
        #   (那次撞车导致解析到前一个桶的 0 条) —— 用各自标题的最前几个字最稳。
        key = '重置清账清单' if bucket == 'resetset' else '已修缺陷的'
        bcnt = None
        for l in out.split('\n'):
            if l.startswith('[') and key in l:
                bcnt = int(re.search(r'\] (\d+) 条', l).group(1))
                break
        hit = bcnt or 0
        if hit <= 0:
            ok = False
        print('%-34s bucket=%-9s 命中=%2s  rc=%s total=%s  %s'
              % (desc, bucket, hit, res['__rc__'], res['__total__'],
                 'OK' if hit > 0 else '!! 没报警'))
    for k in REL:
        wr(k, snaps[k])
    final, _ = run_check()
    print('还原后: 合计 %d' % final['__total__'])
    print('\n结论: %s' % ('全部探针命中且已还原(0)' if ok and final['__total__'] == 0
                          else '★ 有问题, 人工复核'))


if __name__ == '__main__':
    main()
