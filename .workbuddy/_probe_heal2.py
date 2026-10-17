# -*- coding: utf-8 -*-
"""
_probe_heal2.py —— 2026-10-16「回血时序修复 + 沸痕细雪灭火」的**反向探针**。

规矩: 一次只改一处 -> 跑 check -> 必须**精确命中对应那一条** -> 还原 -> 复验 0。
不用 shell 管道滤 traceback(坑 148): 直接读 check 的完整 stdout/stderr。
"""
import subprocess
import sys
import io
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

ROOT = Path(r'D:\数据包')
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
SD = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'

P = {
    'up':     SD / 'lib' / 'heal_up.mcfunction',
    'off':    SD / 'lib' / 'heal_off.mcfunction',
    'tick':   SD / 'core' / 'tick.mcfunction',
    'onhurt': SD / 'equipment' / 'armor' / 'boil_trace' / 'on_hurt.mcfunction',
    'pwoff':  SD / 'equipment' / 'armor' / 'boil_trace' / 'pw_off.mcfunction',
}
ORIG = {k: v.read_text(encoding='utf-8') for k, v in P.items()}


def restore():
    for k, v in P.items():
        v.write_text(ORIG[k], encoding='utf-8')


def check():
    r = subprocess.run([PY, str(ROOT / '.workbuddy' / 'check.py')],
                       capture_output=True, text=True,
                       encoding='utf-8', errors='replace')
    return (r.stdout or '') + (r.stderr or '')


def find_line(text, needle):
    for i, l in enumerate(text.split('\n')):
        if needle in l and not l.strip().startswith('#'):
            return i
    return None


def probe(name, expect_sub, mutate):
    restore()
    mutate()
    out = check()
    total = next((l.strip() for l in out.split('\n') if '合计问题' in l), '?')
    hits = [l.strip()[:170] for l in out.split('\n')
            if '|' in l and expect_sub in l]
    print('----- 探针 %s' % name)
    print('     %s' % total)
    if hits:
        for h in hits[:3]:
            print('     HIT %s' % h)
    else:
        print('     ★★ 无命中 —— 规则没起作用!')
    return bool(hits)


print('===== 基线（应 0 且本轮文件无命中）=====')
restore()
out = check()
print('   %s' % next((l.strip() for l in out.split('\n') if '合计问题' in l), '?'))
bad = [l.strip()[:170] for l in out.split('\n')
       if '|' in l and ('heal' in l or 'boil_trace' in l)]
print('   相关命中: %d' % len(bad))
for b in bad[:6]:
    print('     B %s' % b)

ok = []


def m1():
    lines = ORIG['up'].split('\n')
    i = find_line(ORIG['up'], 'effect give @s minecraft:instant_health')
    lines.insert(i + 1, 'attribute @s minecraft:max_health modifier remove sweetdream:heal_cap')
    P['up'].write_text('\n'.join(lines), encoding='utf-8')


ok.append(('1  heal_up 药水后加裸 remove', probe('1', '没有门控的裸 remove', m1)))


def m2():
    P['up'].write_text(ORIG['up'].replace('tag @s add zx.heal_p', 'tag @s add zx.heal_pX'),
                       encoding='utf-8')


ok.append(('2  heal_up 去掉 heal_p 标签', probe('2', 'zx.heal_p', m2)))


def m3():
    lines = ORIG['tick'].split('\n')
    a = find_line(ORIG['tick'], 'run function sweetdream:lib/heal_off')
    b = find_line(ORIG['tick'], 'run tag @s add zx.heal_on')
    lines[a], lines[b] = lines[b], lines[a]
    P['tick'].write_text('\n'.join(lines), encoding='utf-8')


ok.append(('3  core/tick 两行反转', probe('3', '两行回血收尾不能反', m3)))


def m4():
    lines = ORIG['off'].split('\n')
    a = find_line(ORIG['off'], 'tag @s remove zx.heal_on')
    b = find_line(ORIG['off'], 'modifier remove sweetdream:heal_cap')
    lines[a], lines[b] = lines[b], lines[a]
    P['off'].write_text('\n'.join(lines), encoding='utf-8')


ok.append(('4  heal_off 两行反转', probe('4', '先摘标签', m4)))


def m5():
    P['pwoff'].write_text(
        ORIG['pwoff'].replace('minecraft:air replace minecraft:powder_snow',
                              'minecraft:air replace air'), encoding='utf-8')


ok.append(('5  pw_off replace 写坏', probe('5', 'replace minecraft:powder_snow', m5)))


def m6():
    P['onhurt'].write_text(ORIG['onhurt'].replace('minecraft:powder_snow', 'minecraft:snow_block'),
                           encoding='utf-8')


ok.append(('6  on_hurt 缺 powder_snow', probe('6', 'minecraft:powder_snow', m6)))


def m7():
    P['onhurt'].write_text(ORIG['onhurt'] + '\ndata merge entity @s {Fire:-20s}\n', encoding='utf-8')


ok.append(('7  on_hurt 又写 Fire', probe('7', '{Fire', m7)))

restore()
out = check()
print()
print('===== 还原后复验（必须 0）=====')
print('   %s' % next((l.strip() for l in out.split('\n') if '合计问题' in l), '?'))
print()
print('===== 汇总 =====')
for n, r in ok:
    print('   %s  %s' % ('命中✓' if r else '漏报✗', n))
