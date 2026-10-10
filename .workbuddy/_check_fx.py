# -*- coding: utf-8 -*-
"""逐行校验 sweep/fx 下的粒子指令（check.py 只管"老式 dust"，这里管结构）。"""
import glob, os, re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

NUM = re.compile(r'^-?\d+(\.\d+)?$')
DUST = re.compile(r'^minecraft:dust\{color:\[[0-9.]+,[0-9.]+,[0-9.]+\],scale:[0-9.]+\}$')
OK = {'dust', 'sonic_boom', 'soul', 'sculk_soul', 'end_rod', 'witch', 'enchanted_hit'}
MODES = {'normal', 'force', 'min', 'reduced'}
CATS = {'master', 'music', 'record', 'weather', 'block', 'hostile',
        'neutral', 'player', 'ambient', 'voice'}

root = sys.argv[1] if len(sys.argv) > 1 else \
    r'D:\数据包\sweetdream\data\sweetdream\function\equipment\sword\sickle_dreams\sweep\fx'

bad = n = 0
tp = set()
for f in sorted(glob.glob(os.path.join(root, '*.mcfunction'))):
    for i, l in enumerate(open(f, encoding='utf-8').read().splitlines(), 1):
        if not l or l.startswith('#'):
            continue
        n += 1
        t = l.split()
        try:
            if t[0] == 'particle':
                hid = t[1].split('{')[0].replace('minecraft:', '')
                if hid not in OK:
                    raise ValueError('未知粒子 ' + hid)
                tp.add(hid)
                coords, rest = t[2:5], t[5:]
                if len(coords) != 3 or not all(
                        c.startswith('^') and NUM.match(c[1:]) for c in coords):
                    raise ValueError('坐标 ' + str(coords))
                if len(rest) != 7:
                    raise ValueError('尾巴 %d 个: %s' % (len(rest), rest))
                for v in rest[:4]:
                    if not NUM.match(v):
                        raise ValueError('数值 ' + v)
                if not rest[4].isdigit():
                    raise ValueError('count ' + rest[4])
                if rest[5] not in MODES:
                    raise ValueError('mode ' + rest[5])
                if not rest[6].startswith('@a[distance=..'):
                    raise ValueError('viewers ' + rest[6])
                if hid == 'dust' and not DUST.match(t[1]):
                    raise ValueError('dust 参数 ' + t[1])
            elif t[0] == 'playsound':
                if len(t) != 9:
                    raise ValueError('playsound 参数 %d 个' % len(t))
                if t[2] not in CATS:
                    raise ValueError('channel ' + t[2])
                if not t[3].startswith('@a[distance=..'):
                    raise ValueError('viewers ' + t[3])
                if t[4:7] != ['~', '~1', '~']:
                    raise ValueError('坐标 ' + str(t[4:7]))
                if not (NUM.match(t[7]) and NUM.match(t[8])):
                    raise ValueError('vol/pitch')
            else:
                raise ValueError('既不是 particle 也不是 playsound')
        except Exception as e:
            print('!!', os.path.basename(f), i, e, '|', l[:100])
            bad += 1
print('检查 %d 行, 异常 %d 条' % (n, bad))
print('用到的粒子:', sorted(tp))
