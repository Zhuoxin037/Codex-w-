# -*- coding: utf-8 -*-
"""反向探针: 验证 check.py 的 panelrow 规则不是假绿

面板上「加算(通道倍率)」和「独立乘区」是两处不同的行, 装备的 scan_mul 折错行
= 玩家按 stats 看到的倍率和实伤对不上(2026-10-06 用户反馈"愠怒是独立乘区")。

探针 A: 只把 wrath/scan_mul 的声明 independent_multiplier 改成 smul_mm -> 应报 1 条
探针 B: 删掉 styx_walk/scan_mul 的 `# @panel:` 声明行                  -> 应报 1 条
探针 C: 只把 styx_walk/scan_mul 代码里的写入键 smul_mm 改成 independent_multiplier
        (声明不动)                                                      -> 应报 1 条
每次探针后都还原, 全部跑完必须回到 0 条。
"""
import io, os, subprocess

ROOT = r'D:\数据包'
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
FN = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment')
WRATH = os.path.join(FN, 'tool', 'wrath', 'scan_mul.mcfunction')
STYX = os.path.join(FN, 'armor', 'styx_walk', 'scan_mul.mcfunction')


def run():
    p = subprocess.run([PY, os.path.join(ROOT, '.workbuddy', 'check.py')],
                       capture_output=True, text=True, encoding='utf-8', errors='ignore')
    n = None
    for line in p.stdout.splitlines():
        if line.startswith('[scan_mul 头部'):
            n = int(line.rsplit(']', 1)[1].strip().split()[0])
    return n


wrath0 = io.open(WRATH, encoding='utf-8').read()
styx0 = io.open(STYX, encoding='utf-8').read()


def restore():
    io.open(WRATH, 'w', encoding='utf-8', newline='\n').write(wrath0)
    io.open(STYX, 'w', encoding='utf-8', newline='\n').write(styx0)


def probe(name, fn, expect=1):
    fn()
    n = run()
    print('%-34s -> 报 %s 条 (期望 %s) %s' % (name, n, expect, 'OK' if n == expect else 'FAIL'))
    restore()


def a():                                    # 声明与代码不符
    io.open(WRATH, 'w', encoding='utf-8', newline='\n').write(
        wrath0.replace('# @panel: independent_multiplier', '# @panel: smul_mm'))


def b():                                    # 声明整个缺失
    io.open(STYX, 'w', encoding='utf-8', newline='\n').write(
        styx0.replace('# @panel: smul_mm\n', ''))


def c():                                    # 代码改了、声明没跟着改
    io.open(STYX, 'w', encoding='utf-8', newline='\n').write(
        styx0.replace('storage zx:work pl.smul_mm double', 'storage zx:work pl.independent_multiplier double'))


print('基线(未篡改) ->', run(), '条')
probe('探针 A(声明改成 smul_mm)', a)
probe('探针 B(删掉声明行)', b)
probe('探针 C(代码改键、声明不动)', c)
restore()
print('还原后 ->', run(), '条')
