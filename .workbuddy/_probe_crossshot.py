# -*- coding: utf-8 -*-
"""反向探针: 临时把 arc/shot 里的扣蓝调用注释掉, 跑 check.py, 应报 crossshot;
   无论成败都还原文件。"""
import subprocess, sys
from pathlib import Path

P = Path(r'D:/数据包/sweetdream/data/sweetdream/function/equipment/bow/arc/shot.mcfunction')
ORIG = P.read_text(encoding='utf-8')
NEEDLE = 'function manacore:api/mana/consume'
assert NEEDLE in ORIG, '找不到扣蓝调用, 探针前提不成立'
BAD = ORIG.replace(NEEDLE, '# PROBE-DISABLED ' + NEEDLE, 1)
P.write_text(BAD, encoding='utf-8')
try:
    r = subprocess.run([sys.executable, r'D:/数据包/.workbuddy/check.py'],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    hit = [l for l in r.stdout.splitlines()
           if '射击进度 + shot' in l or '没有调用 manacore:api/mana/consume' in l]
    print('命中行数: %d' % len(hit))
    for l in hit:
        print('  ' + l.strip())
finally:
    P.write_text(ORIG, encoding='utf-8')
    print('已还原:', NEEDLE in P.read_text(encoding='utf-8'))
