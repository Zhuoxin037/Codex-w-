# -*- coding: utf-8 -*-
"""反向探针: 验证 check.py 的 upfield 规则真的会报警。
  T1 把 bonus_take 里 aspd 的 ① 减旧行注释掉 -> 应报"减旧/加回不成对"。
  T2 把 bonus_held 里 #up_aspd 的归零行注释掉 -> 应报"没把它归零"。
  每步跑完都还原。"""
import subprocess, sys
from pathlib import Path

ROOT = Path(r'D:/数据包')
BT = ROOT / 'sweetdream/data/sweetdream/function/upgrade/api/bonus_take.mcfunction'
BH = ROOT / 'sweetdream/data/sweetdream/function/upgrade/api/bonus_held.mcfunction'


def run_check():
    r = subprocess.run([sys.executable, str(ROOT / '.workbuddy/check.py')],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    return r.stdout


def probe(name, path, needle):
    orig = path.read_text(encoding='utf-8')
    assert needle in orig, '%s: 前提不成立(找不到 %r)' % (name, needle)
    path.write_text(orig.replace(needle, '# PROBE ' + needle, 1), encoding='utf-8')
    try:
        out = run_check()
        hits = [l.strip() for l in out.splitlines()
                if '不成对' in l or '没把它归零' in l or '却没在开头归零' in l]
        print('[%s] 命中 %d 条:' % (name, len(hits)))
        for h in hits:
            print('    ' + h)
    finally:
        path.write_text(orig, encoding='utf-8')
        print('[%s] 已还原: %s' % (name, needle in path.read_text(encoding='utf-8')))


probe('T1 bonus_take 减旧半', BT,
      'scoreboard players operation #up_aspd zx.meta -= #up_o zx.meta')
probe('T2 bonus_held 归零', BH,
      'scoreboard players set #up_aspd zx.meta 0')
