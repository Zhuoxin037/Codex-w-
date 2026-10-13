#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""D01 口径 B 的反向探针: 逐条破坏 -> 确认守门报警 -> 还原。

原则(踩过的坑):
  · "删行"型破坏必须**真的写回文件**再跑 check(上批有人只改内存, 当然 0 报警);
  · 定位输出行用**唯一关键词**(别用会撞车的词);
  · 每个 case 之后**回读自检**(文件确实变了), 跑完再还原并确认归 0。
"""
import os
import re
import subprocess
import sys

ROOT = r'D:/数据包'
PY = r'C:/Users/qq303/.workbuddy/binaries/python/versions/3.13.12/python.exe'
CHK = os.path.join(ROOT, '.workbuddy', 'check.py')

CALC = 'manacore-1.0.0/data/manacore/function/internal/damage/calc.mcfunction'
HP = 'manacore-1.0.0/data/manacore/function/internal/damage/health_part.mcfunction'
APP = 'sweetdream/data/sweetdream/function/lib/dmg_add_apply.mcfunction'
PUT = 'sweetdream/data/sweetdream/function/lib/dmg_add_put_any.mcfunction'
REL = [CALC, HP, APP, PUT]

KEY_DMG = '本通道分量'        # dmgseg 桶标题关键词
KEY_REG = '形态锁定'          # regress 桶标题关键词


def _full(rel):
    return os.path.join(ROOT, rel)


def rd(rel):
    with open(_full(rel), encoding='utf-8') as f:
        return f.read()


def wr(rel, txt):
    """写回: 先写临时文件再 os.replace 顶替 —— 避开偶发的 Windows OSError EINVAL。"""
    import time
    dst = _full(rel)
    tmp = dst + '.tmp'
    last = None
    for _ in range(6):
        try:
            with open(tmp, 'w', encoding='utf-8', newline='\n') as f:
                f.write(txt)
            os.replace(tmp, dst)
            return
        except OSError as e:          # 偶发锁/参数错 -> 退避重试
            last = e
            time.sleep(0.4)
    if os.path.exists(tmp):
        try:
            os.remove(tmp)
        except OSError:
            pass
    raise last


def run_check():
    p = subprocess.run([PY, CHK], capture_output=True, text=True,
                       encoding='utf-8', errors='replace', cwd=ROOT)
    counts = {}
    for m in re.finditer(r'^\[(.+?)\] (\d+) 条$', p.stdout, re.M):
        counts[m.group(1)] = int(m.group(2))
    tot = re.search(r'合计问题: (\d+)', p.stdout)
    return counts, (int(tot.group(1)) if tot else -1)


def bucket(counts, key):
    for title, n in counts.items():
        if key in title:
            return n
    return -1


# ---------------- 破坏动作 ----------------

def drop_line(rel, needle):
    ls = rd(rel).split('\n')
    out = [l for l in ls if needle not in l]
    assert len(out) < len(ls), 'needle 未找到: %r in %s' % (needle, rel)
    wr(rel, '\n'.join(out))
    assert needle not in rd(rel), '删行没写回!'


def append_line(rel, line):
    txt = rd(rel)
    if not txt.endswith('\n'):
        txt += '\n'
    wr(rel, txt + line + '\n')
    assert line in rd(rel), '追加没写回!'


def sub_line(rel, old, new):
    txt = rd(rel)
    assert old in txt, 'old 未找到: %r in %s' % (old, rel)
    wr(rel, txt.replace(old, new))
    assert new in rd(rel), '替换没写回!'


CASES = [
    ('calc 删 r.seg_x 出参',
     lambda: drop_line(CALC, 'storage manacore:out r.seg_x'), KEY_DMG),
    ('calc 删 r.im 出参',
     lambda: drop_line(CALC, 'storage manacore:out r.im'), KEY_DMG),
    ('calc 删 r.seg_m 出参',
     lambda: drop_line(CALC, 'storage manacore:out r.seg_m'), KEY_DMG),
    ('health_part 删 #seg_x 累加',
     lambda: drop_line(HP, '#seg_x manacore.math +='), KEY_REG),
    ('apply 去掉全部 mul_pct 调用',
     lambda: drop_line(APP, 'damage/mul_pct'), KEY_DMG),
    ('apply 又读 zx:work ch',
     lambda: append_line(APP, 'execute if data storage zx:work ch run return 0'), KEY_DMG),
    ('apply 删 r.seg_m 读取',
     lambda: drop_line(APP, 'storage manacore:out r.seg_m'), KEY_DMG),
    ('put_any 第③条改回 mm(只写两条)',
     lambda: sub_line(PUT, 'set value "oth"', 'set value "mm"'), KEY_DMG),
    ('put_any 又读 zx:work ch',
     lambda: append_line(PUT, 'execute if data storage zx:work ch run return 0'), KEY_DMG),
]


def main():
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass
    snaps = {r: rd(r) for r in REL}

    base, btot = run_check()
    print('基线: dmgseg=%d regress=%d 合计=%d'
          % (bucket(base, KEY_DMG), bucket(base, KEY_REG), btot))
    if btot != 0:
        print('★ 基线不是 0, 先修好再跑探针')
        for r in REL:
            wr(r, snaps[r])
        return

    ok = True
    for desc, fn, key in CASES:
        fn()
        counts, tot = run_check()
        hit = bucket(counts, key)
        good = hit > 0
        ok = ok and good
        print('%-36s bucket=%-10s 命中=%-3s %s'
              % (desc, key, hit, 'OK' if good else '★ 没报警'))
        for r in REL:
            wr(r, snaps[r])
        # 还原自检(逐文件回读)
        for r in REL:
            assert rd(r) == snaps[r], '还原失败: %s' % r

    final, ftot = run_check()
    print('还原后: dmgseg=%d regress=%d 合计=%d'
          % (bucket(final, KEY_DMG), bucket(final, KEY_REG), ftot))
    print('\n结论: %s'
          % ('全部探针命中且已还原' if ok and ftot == 0 else '★ 有问题, 人工复核'))


if __name__ == '__main__':
    main()
