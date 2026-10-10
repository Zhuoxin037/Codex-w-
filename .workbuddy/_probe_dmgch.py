# -*- coding: utf-8 -*-
"""反向探针: 验证 check.py 的 dmgch 规则不是假绿

探针 A: 把 damage_calc.json 的第一条从 lib/dmg_ch 换成别的 -> 应报 1 条
探针 B: 让 seraph_wing/hook_calc 直接读 manacore:work a -> 应报 1 条
两次都要还原, 还原后必须 0 条。
"""
import io, json, subprocess, sys, os

ROOT = r'D:\数据包'
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
TAG = os.path.join(ROOT, 'sweetdream', 'data', 'manacore', 'tags', 'function', 'event', 'damage_calc.json')
HOOK = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment', 'tool', 'seraph_wing', 'hook_calc.mcfunction')


def run():
    p = subprocess.run([PY, os.path.join(ROOT, '.workbuddy', 'check.py')],
                       capture_output=True, text=True, encoding='utf-8', errors='ignore')
    out = p.stdout
    n = None
    for line in out.splitlines():
        if line.startswith('[damage_calc 事件里没先拍'):
            n = int(line.rsplit(']', 1)[1].strip().split()[0])
    return n


def probe(name, fn, expect):
    fn()
    n = run()
    print('%s -> 报 %s 条 (期望 %s) %s' % (name, n, expect, '✓' if n == expect else '✗'))
    restore()


tag0 = io.open(TAG, encoding='utf-8').read()
hook0 = io.open(HOOK, encoding='utf-8').read()


def a():
    v = json.loads(tag0)['values']
    v2 = v[1:] + [v[0]]
    io.open(TAG, 'w', encoding='utf-8', newline='\n').write(json.dumps({"values": v2}, indent=2) + '\n')


def b():
    io.open(HOOK, 'w', encoding='utf-8', newline='\n').write(
        hook0.replace('storage zx:work ch.attack_mul', 'storage manacore:work a.attack_mul'))


def restore():
    io.open(TAG, 'w', encoding='utf-8', newline='\n').write(tag0)
    io.open(HOOK, 'w', encoding='utf-8', newline='\n').write(hook0)


probe('探针 A(顺序被改)', a, 1)
probe('探针 B(直读 manacore:work a)', b, 1)
restore()
print('还原后 ->', run(), '条')
