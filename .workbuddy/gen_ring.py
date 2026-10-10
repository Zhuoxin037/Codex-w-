# -*- coding: utf-8 -*-
"""生成幻昼"每层独立到期"环形记账的三组分支代码 + load 注册块。"""
import io, sys
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

ROOT = Path(r'D:/数据包/sweetdream/data/sweetdream/function/equipment/armor/mirage')

A_N, A_TOTAL, A_IDX = 6, 'zx.mr_atk1', '#mr_ra'
B_N, B_TOTAL, B_IDX = 9, 'zx.mr_atk2', '#mr_rb'


def expire_block(n, pref, total, idx):
    out = []
    for i in range(n):
        out.append(f'execute if score {idx} zx.meta matches {i} run scoreboard players operation @s {total} -= @s {pref}{i}')
        out.append(f'execute if score {idx} zx.meta matches {i} run scoreboard players set @s {pref}{i} 0')
    return out


def add_block(n, pref, idx):
    return [f'execute if score {idx} zx.meta matches {i} run scoreboard players add @s {pref}{i} 1'
            for i in range(n)]


# ---------- expire.mcfunction ----------
exp = []
exp.append('# ============================================================')
exp.append('# sweetdream:equipment/armor/mirage/expire —— 每秒收掉"到寿"的那一格')
exp.append('# ------------------------------------------------------------')
exp.append('# 【执行者】玩家(由 passive 在算加成**之前**调进来)')
exp.append('# 【为什么要有"格子"】套装的两条加成都是"每次触发 +1 层, 每层各活 5 / 8 秒",')
exp.append('#   而且**先加的先掉**—— 不能像以前那样只写一个"剩余秒数": 那样第二次')
exp.append('#   触发只是把时间刷回去, 层数永远只有 1 层(就是用户说的"重置时间")。')
exp.append('#   所以做成**环形记账**: 每一格记"那一秒内加了几层", 每秒把"该到寿的那')
exp.append('#   一格"清掉, 并从总层数里扣回去。总层数 = 所有格子之和。')
exp.append('# 【格数 = 时长 + 1】到第 T 秒清的是"第 T-格数 秒"那一格, 它的年龄是')
exp.append('#   (格数-1) ~ 格数 秒。取"时长+1"才能保证每层**至少**活满 5 / 8 秒。')
exp.append('# 【下标谁推进】mirage/second 每秒把 #mr_ra / #mr_rb 各 +1 取模; 这里只读')
exp.append('#   它: 清"当前这一格", 而这一秒里新加的层也写进"当前这一格" —— 两者')
exp.append('#   必须同格, 否则新层会被下一轮提前清掉。')
exp.append('# ============================================================')
exp.append('')
exp.append('# ① +1 环: 6 格, 每层至少活 5 秒(受伤一次 +1 层)')
exp += expire_block(A_N, 'zx.mr_a', A_TOTAL, A_IDX)
exp.append('')
exp.append('# ② +2 环: 9 格, 每层至少活 8 秒(打到带白昼梦的生物 +1 层, 最多 10 层)')
exp += expire_block(B_N, 'zx.mr_b', B_TOTAL, B_IDX)
exp.append('')
exp.append('# ③ 保险: 总层数不该为负(理论上不会, 出现就归零, 免得加成算出负数)')
exp.append(f'execute if score @s {A_TOTAL} matches ..-1 run scoreboard players set @s {A_TOTAL} 0')
exp.append(f'execute if score @s {B_TOTAL} matches ..-1 run scoreboard players set @s {B_TOTAL} 0')
(ROOT / 'expire.mcfunction').write_text('\n'.join(exp) + '\n', encoding='utf-8')

# ---------- add_a.mcfunction ----------
a = []
a.append('# ============================================================')
a.append('# sweetdream:equipment/armor/mirage/add_a —— 受伤一次: +1 层(不设上限)')
a.append('# ------------------------------------------------------------')
a.append('# 【执行者】玩家(由 hurt 调进来; 套装判定在调用方做完了)')
a.append('# 【为什么要写两处】总层数 zx.mr_atk1 用来算加成, 环形格子用来记"这层什么时候')
a.append('#   到期"。两者必须在同一个条件下一起加 —— 只加一个会导致"层数掉不干净"或')
a.append('#   "加成还在但格子已经空了"。')
a.append('# 【不设上限】文案里 +2 那条写了"最多叠加 10 次", +1 这条**没写**, 用户明确')
a.append('#   说了这条"不受限": 受到伤害就 +1, 而不是把时间刷回去。')
a.append('# ============================================================')
a.append('')
a.append(f'scoreboard players add @s {A_TOTAL} 1')
a += add_block(A_N, 'zx.mr_a', A_IDX)
(ROOT / 'add_a.mcfunction').write_text('\n'.join(a) + '\n', encoding='utf-8')

# ---------- add_b.mcfunction ----------
b = []
b.append('# ============================================================')
b.append('# sweetdream:equipment/armor/mirage/add_b —— 打到带白昼梦的生物: +1 层(上限 10 层 = +20)')
b.append('# ------------------------------------------------------------')
b.append('# 【执行者】玩家(由 hit_dream 调进来)')
b.append('# 【上限 10 层】文案写的是"+2(最多叠加 10 次)", 也就是最多 +20 攻击力。')
b.append('#   ⚠️ 上限必须判在**加之前**: 满了就一层都不加(总层数和格子都不动),')
b.append('#   否则"层数封顶但格子还在涨", 到期时会把总层数扣成负数。')
b.append('# ============================================================')
b.append('')
b.append('execute if score @s zx.mr_atk2 matches 10.. run return 0')
b.append('')
b.append(f'scoreboard players add @s {B_TOTAL} 1')
b += add_block(B_N, 'zx.mr_b', B_IDX)
(ROOT / 'add_b.mcfunction').write_text('\n'.join(b) + '\n', encoding='utf-8')

# ---------- load 注册块 ----------
blk = []
blk.append('# 幻昼套装"每层独立到期"的环形记账格(见 equipment/armor/mirage/expire):')
blk.append('#   +1 环 6 格(每层活 5 秒, 不设上限)  +2 环 9 格(每层活 8 秒, 上限 10 层)')
for i in range(A_N):
    blk.append(f'execute unless data storage zx:config obj_mr_a{i} run scoreboard objectives add zx.mr_a{i} dummy')
    blk.append(f'execute unless data storage zx:config obj_mr_a{i} run data modify storage zx:config obj_mr_a{i} set value 1b')
for i in range(B_N):
    blk.append(f'execute unless data storage zx:config obj_mr_b{i} run scoreboard objectives add zx.mr_b{i} dummy')
    blk.append(f'execute unless data storage zx:config obj_mr_b{i} run data modify storage zx:config obj_mr_b{i} set value 1b')
blk.append('# 环形下标取模用的模数: #6(+1 环) / #9(+2 环); #10 = +2 环的层数上限')
blk.append('scoreboard players set #6 zx.meta 6')
blk.append('scoreboard players set #9 zx.meta 9')
blk.append('scoreboard players set #10 zx.meta 10')
Path(r'D:/数据包/.workbuddy/ring_load.txt').write_text('\n'.join(blk) + '\n', encoding='utf-8')

print('生成完毕:')
for p in ['expire.mcfunction', 'add_a.mcfunction', 'add_b.mcfunction']:
    print('  ', ROOT / p, (ROOT / p).stat().st_size, 'bytes')
print('  load 块 ->', len(blk), '行')
