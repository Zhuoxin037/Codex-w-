# -*- coding: utf-8 -*-
"""单点复现: 破坏 migrate 的登记行 -> 跑 check -> 打印 相关行 + 退出码。"""
import io, os, subprocess, sys

ROOT = r'D:\数据包'
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
CHECK = os.path.join(ROOT, '.workbuddy', 'check.py')

REL = 'manacore-1.0.0/data/manacore/function/internal/uuid/migrate.mcfunction'
TARGET = ('$execute if data storage manacore:players "$(h0)" unless data storage manacore:players '
          '"$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"')

p = os.path.join(ROOT, REL)
with open(p, encoding='utf-8') as f:
    orig = f.read()
lines = orig.split('\n')
print('目标行在文件里? ', TARGET in lines)
print('---- 文件里所有 append 行 ----')
for l in lines:
    if 'append' in l:
        print(repr(l))
lines.remove(TARGET)
with open(p, 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines))
try:
    r = subprocess.run([PY, CHECK], cwd=ROOT, capture_output=True, text=True,
                       encoding='utf-8', errors='replace')
    out = (r.stdout or '') + (r.stderr or '')
    print('---- check 退出码:', r.returncode)
    print('---- stdout 行数:', len((r.stdout or '').split('\n')))
    print('---- 命中 `终身清单登记必须` ?', '终身清单登记必须' in out)
    print('---- 命中 `migrate` ?', 'migrate' in out)
    print('---- 含 登记/终身/A03 的行 ----')
    for l in out.split('\n'):
        if '登记' in l or '终身' in l or 'A03' in l:
            print(l[:200])
    print('---- stdout 末 3 行 ----')
    for l in (r.stdout or '').strip().split('\n')[-3:]:
        print(l[:200])
    print('---- stderr 前 5 行 ----')
    for l in (r.stderr or '').strip().split('\n')[:5]:
        print(l[:200])
finally:
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(orig)
    print('---- 已还原')
