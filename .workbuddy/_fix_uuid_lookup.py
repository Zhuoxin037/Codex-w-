# -*- coding: utf-8 -*-
"""
把包内所有 `@a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}]` 反查改成
「灌 storage zx:work ub + 调 lib/u_by + 认 @a[tag=zx.ub]」的零 NBT 写法。

用法:
    python .workbuddy/_fix_uuid_lookup.py            # 干跑, 只打印计划
    python .workbuddy/_fix_uuid_lookup.py --write    # 真写
"""
import os
import re
import sys

ROOT = r'D:/数据包/sweetdream/data/sweetdream/function'

# 形如 nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}
UUID_PAT = re.compile(r'nbt=\{UUID:\[I;\$\((?P<a>[A-Za-z0-9_.]+)\),\$\((?P<b>[A-Za-z0-9_.]+)\),\$\((?P<c>[A-Za-z0-9_.]+)\),\$\((?P<d>[A-Za-z0-9_.]+)\)\]\}')

# $execute store result score #ay zx.meta run data get entity @a[nbt={UUID...},limit=1] Pos[1] 100
GET_PAT = re.compile(
    r'^(?P<ind>\s*)\$(?P<mid>.*?)store result score (?P<holder>\S+) (?P<obj>\S+) run '
    r'data get entity @a\[(?P<sel>[^\]]*)\] (?P<path>Pos\[\d\])(?P<scale> \d+)?\s*$')


def plan_file(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    out = []
    changed = 0
    for line in lines:
        stripped = line.strip()
        if not stripped.startswith('$') or '@a[' not in line or 'nbt={UUID' not in line:
            out.append(line)
            continue
        m = UUID_PAT.search(line)
        if not m:
            out.append(line)
            continue
        a, b, c, d = m.group('a'), m.group('b'), m.group('c'), m.group('d')
        ind = line[:len(line) - len(line.lstrip())]
        feed = ind + '$data modify storage zx:work ub set value {u0:$(%s),u1:$(%s),u2:$(%s),u3:$(%s)}' % (a, b, c, d)
        call = ind + 'function sweetdream:lib/u_by'

        gm = GET_PAT.match(line)
        if gm:
            sel = gm.group('sel')
            sel2 = UUID_PAT.sub('tag=zx.ub', sel)
            newline = (ind + '$' + gm.group('mid') + 'as @a[' + sel2 + '] store result score '
                       + gm.group('holder') + ' ' + gm.group('obj') + ' run data get entity @s '
                       + gm.group('path') + (gm.group('scale') or ''))
            out.append(feed)
            out.append(call)
            out.append(newline)
            changed += 1
            continue

        newline2 = UUID_PAT.sub('tag=zx.ub', line)
        out.append(feed)
        out.append(call)
        out.append(newline2)
        changed += 1
    return out, changed


def main():
    write = '--write' in sys.argv
    total_files = 0
    total_lines = 0
    for dp, dn, fn in os.walk(ROOT):
        for f in sorted(fn):
            if not f.endswith('.mcfunction'):
                continue
            p = os.path.join(dp, f)
            txt = open(p, encoding='utf-8').read()
            if 'nbt={UUID' not in txt or '@a[' not in txt:
                continue
            out, changed = plan_file(p)
            if not changed:
                continue
            total_files += 1
            total_lines += changed
            rel = os.path.relpath(p, ROOT).replace('\\', '/')
            print('%-70s  %d 行' % (rel, changed))
            if write:
                open(p, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
    print('---- 合计 %d 个文件 / %d 行 ----' % (total_files, total_lines))
    print('模式:', 'WRITE' if write else 'DRY-RUN')


if __name__ == '__main__':
    main()
