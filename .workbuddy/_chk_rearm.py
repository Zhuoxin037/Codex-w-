# -*- coding: utf-8 -*-
"""枚举"自撤销型"进度(奖励函数首行 = advancement revoke @s only 自己),
  与 lib/rearm 里的撤销清单比对, 报告漏项/多项。纯标准库。"""
import json, re, sys, io
from pathlib import Path
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
ROOT = Path(r'D:/数据包')
PACKS = ['manacore-1.0.0', 'sweetdream']

functions = {}
for pack in PACKS:
    for nsdir in (ROOT / pack / 'data').iterdir():
        if not nsdir.is_dir():
            continue
        fdir = nsdir / 'function'
        if not fdir.exists():
            continue
        for f in fdir.rglob('*.mcfunction'):
            functions[f"{nsdir.name}:{f.relative_to(fdir).as_posix()[:-11]}"] = f

selfrevoke = {}   # 进度key -> 奖励函数
for pack in PACKS:
    for nsdir in (ROOT / pack / 'data').iterdir():
        adir = nsdir / 'advancement'
        if not adir.is_dir():
            continue
        for f in adir.rglob('*.json'):
            try:
                j = json.loads(f.read_text(encoding='utf-8'))
            except Exception:
                continue
            rw = (j.get('rewards') or {}).get('function')
            if not rw or rw not in functions:
                continue
            key = f"{nsdir.name}:{f.relative_to(adir).as_posix()[:-5]}"
            body = [l.strip() for l in functions[rw].read_text(encoding='utf-8').split('\n')
                    if l.strip() and not l.strip().startswith('#')]
            m = re.match(r'advancement\s+revoke\s+@s\s+only\s+([\w:.\-/]+)', body[0] if body else '')
            if m and m.group(1) == key:
                selfrevoke[key] = rw

rearm = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'lib' / 'rearm.mcfunction')
listed = set()
trig_rearm = []
for i, l in enumerate(rearm.read_text(encoding='utf-8').splitlines(), 1):
    s = l.strip()
    if s.startswith('#'):
        continue
    m = re.match(r'advancement\s+revoke\s+@a\s+only\s+([\w:.\-/]+)', s)
    if m:
        if m.group(1) in listed:
            trig_rearm.append('%s 第 %d 行 重复列出 %s' % (rearm.name, i, m.group(1)))
        listed.add(m.group(1))
    elif s:
        trig_rearm.append('%s 第 %d 行 不是标准的 revoke 行: %s' % (rearm.name, i, s[:60]))

missing = sorted(set(selfrevoke) - listed)
extra = sorted(listed - set(selfrevoke))
print('自撤销型进度共 %d 条, rearm 列出 %d 条' % (len(selfrevoke), len(listed)))
print('漏项(rearm 里没有, 会永久卡住): %s' % (missing or '无'))
print('多项(不是自撤销型, 列了也无害): %s' % (extra or '无'))
print('格式问题: %s' % (trig_rearm or '无'))
for k in sorted(selfrevoke):
    print('  %-52s -> %s' % (k, selfrevoke[k]))
