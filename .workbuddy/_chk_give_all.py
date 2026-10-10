# -*- coding: utf-8 -*-
"""校验 debug/give_all 的**覆盖面**: 不能漏件、不能越格。

【为什么单独一个检查】(2026-10-08 事故)
  give_all 是 `_gen_give_all.py` 生成的, 加了新装备/新石头之后**必须重跑**。
  批 E1 加了 3 块超限石后没重跑 -> 玩家在 giveall 里就是拿不到那 3 块,
  而 check.py 全绿(它只管语法, 不管"清单有没有跟上")。
  本检查补的就是这一层: **磁盘上有的 give / 石头, give_all 里必须都在**。

【查三件事】
  ① 漏件: 磁盘上有 give 函数 / 石头物品, give_all 里没调。
  ② 越格: 同一个盒子的 container.<i> 下标超过 26(潜影盒只有 27 格,
          超出的 item replace 不报错、界面也看不出来 —— 会**静默丢件**)。
  ③ 幽灵: give_all 里调了, 但磁盘上那个文件已经不在了(改 id / 删装备后残留)。
"""
import glob, io, os, re, sys

BASE = r'D:\数据包\sweetdream\data\sweetdream\function'
GIVE_ALL = BASE + r'\debug\give_all.mcfunction'
BOX_CAP = 27

problems = []


def fn_of(path):
    p = path.replace('\\', '/')
    rel = p[len(BASE) + 1:]
    rel = rel[:-len('.mcfunction')] if rel.endswith('.mcfunction') else rel
    return 'sweetdream:' + rel


# ---- 期望清单 ----
want = []
for cat in ('armor', 'sword', 'axe', 'bow', 'staff', 'tool'):
    want += sorted(glob.glob(BASE + '/equipment/%s/*/give.mcfunction' % cat))
want += sorted(glob.glob(BASE + '/upgrade/item/*.mcfunction'))
want += sorted(glob.glob(BASE + '/overlimit/item/*.mcfunction'))
want_fns = {fn_of(p): p for p in want}

if not os.path.isfile(GIVE_ALL):
    print('[x] 找不到 debug/give_all.mcfunction')
    sys.exit(1)

txt = io.open(GIVE_ALL, encoding='utf-8').read()
called = re.findall(r'^function (sweetdream:\S+)$', txt, re.M)

# ① 漏件
for f, p in sorted(want_fns.items()):
    if f not in called:
        problems.append('漏件: %s 没被 give_all 调用 -> 重跑 python .workbuddy/_gen_give_all.py' % f)

# ③ 幽灵
for f in sorted(set(called)):
    if f not in want_fns and f.startswith('sweetdream:'):
        # 只管"物品清单类"的调用(equipment/*/give + 两类石头), 别的工具函数跳过
        if '/give' in f or '/upgrade/item/' in f or '/overlimit/item/' in f:
            problems.append('幽灵: give_all 调了 %s, 但磁盘上没这个文件' % f)

# ② 越格: 同一个盒子(container 前的 block 坐标)的下标不得 >= 27
slots = {}
CHEST = '0 -60 2'   # 暂存箱(存玩家原本 hotbar.0 那格), 不是盒子
for pos, idx in re.findall(r'item replace block ([\d\- ]+) container\.(\d+) ', txt):
    if pos.strip() == CHEST:
        continue
    slots.setdefault(pos, set()).add(int(idx))
for pos, s in sorted(slots.items()):
    over = [i for i in s if i >= BOX_CAP]
    if over:
        problems.append('越格: 盒子 %s 用到了第 %s 格(潜影盒只有 %d 格) -> 会静默丢件'
                        % (pos, ','.join(str(i) for i in sorted(over)), BOX_CAP))

print('---- give_all 覆盖面: 应有 %d 件, 实调 %d 件, %d 个盒子'
      % (len(want_fns), len(called), len(slots)))
for p in problems:
    print('  [x] ' + p)
print('---- 问题 %d 件' % len(problems))
