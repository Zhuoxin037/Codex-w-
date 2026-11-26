# -*- coding: utf-8 -*-
"""批 20-A：通用设施（临时生命 lib/thp、术阵位读取 lib/fm）

一次写出全部文件，内容逐字进包。可以重复跑（覆盖式）。
"""
import os
ROOT = r'D:/数据包/fallendream/data/fallendream/function'

F = {}

# ============================================================
# lib/thp —— 临时生命值（吸收血池）的唯一入口
# ============================================================
F['lib/thp/set.mcfunction'] = r'''# ============================================================
# fallendream:lib/thp/set —— 把「临时生命值」设成指定点数（本包唯一写吸收的地方）
# ------------------------------------------------------------
# 【入参】#thp_v zx.meta = 目标点数（整数，≥0；0 = 清空）
# 【执行者】玩家(@s)
# 【实现】原版没有"精确 N 点吸收"的接口，只有 `effect absorption <等级>`（每级 4 点）。
#   ⇒ 用两级拼：等级 = ceil(N/4)（吸收 4×等级），再用 `minecraft:max_absorption`
#      属性往下压 (4×等级 − N)，总上限正好落在 N 点（黄心数 = N/2）。
#      N=5 → 等级 2(8 点) + max_absorption −3 = 5 点。
# 【★ 这套独占 absorption 效果 ★】原版吸收只有一个值，本件与"法师预言·新生"那类
#   直接给 absorption 的效果**不能同时成立**（后写的一方会覆盖）。目前包内只有
#   profession/mage/p_rebirth 用它，两者同时触发的概率极低，暂按独占处理。
# 【★ 为什么先摘再挂 ★】同一 id 的 modifier 重复 add 会失败；摘不存在的会失败但
#   不截断后续命令，所以用标签 zx.thp_on 当"挂过"的判据。
# 【★ 时长 60 秒 / 到期由 lib/thp/tick 收 ★】不每秒刷新效果 —— absorption 效果
#   每 tick 会把吸收量重置到满级，每秒刷新等于"永远打不空"。所以给一次性长时长，
#   被打空 / 到期都由 tick 那边检测后 clear。
# ============================================================

# ① 目标点数落到玩家账本（负数/没分数一律按 0）
scoreboard players set @s zx.thp 0
execute if score #thp_v zx.meta matches 1.. run scoreboard players operation @s zx.thp = #thp_v zx.meta

# ② 摘掉上一轮的修饰符（挂过才摘）
execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove fallendream:thp_cap
tag @s remove zx.thp_on

# ③ 目标是 0 ⇒ 收工（连效果一起清）
execute if score @s zx.thp matches 0 run function fallendream:lib/thp/clear_soft
execute if score @s zx.thp matches 0 run return 0

# ④ 等级 = ceil(N/4) = (N+3)/4
scoreboard players operation #thp_lv zx.meta = #thp_v zx.meta
scoreboard players add #thp_lv zx.meta 3
scoreboard players operation #thp_lv zx.meta /= #4 zx.meta

# ⑤ 等级给的总吸收 = 4×等级；mod = N − 4×等级（≤0，作为 max_absorption 的增量）
scoreboard players operation #thp_all zx.meta = #thp_lv zx.meta
scoreboard players operation #thp_all zx.meta *= #4 zx.meta
scoreboard players operation #thp_mod zx.meta = #thp_v zx.meta
scoreboard players operation #thp_mod zx.meta -= #thp_all zx.meta

# ⑥ amplifier = 等级 − 1（原版从 0 起算）
scoreboard players remove #thp_lv zx.meta 1

# ⑦ 交给宏件（modifier 的数值与 effect 的等级都只能是字面量）
data modify storage zx:work thp set value {amp:0,mod:0}
execute store result storage zx:work thp.amp int 1 run scoreboard players get #thp_lv zx.meta
execute store result storage zx:work thp.mod int 1 run scoreboard players get #thp_mod zx.meta
function fallendream:lib/thp/apply with storage zx:work thp

# ⑧ 记到期刻（60 秒后；重置时刷新）
scoreboard players operation @s zx.thp_end = #now manacore.meta
scoreboard players add @s zx.thp_end 1200
'''

F['lib/thp/apply.mcfunction'] = r'''# ============================================================
# fallendream:lib/thp/apply —— 挂 max_absorption 上限 + 发吸收药水（宏 {amp,mod}）
# ------------------------------------------------------------
# 【宏参数】zx:work thp {amp:<amplifier,0 起>, mod:<≤0 的增量>}
# 【执行者】玩家(@s)
# 【★ 数值只能字面量 ★】`attribute ... modifier add` 与 `effect give` 的等级都
#   吃不了计分项，只能靠宏展开（同 lib/heal_up / lib/mana/* 的写法）。
# ============================================================

$attribute @s minecraft:max_absorption modifier add fallendream:thp_cap $(mod) add_value
$effect give @s minecraft:absorption 60 $(amp) true
tag @s add zx.thp_on
'''

F['lib/thp/add.mcfunction'] = r'''# ============================================================
# fallendream:lib/thp/add —— 在现有临时生命上"加 N 点"（带最大生命 ×2 的硬上限）
# ------------------------------------------------------------
# 【入参】#thp_v zx.meta = 增量（整数，≥0）
# 【执行者】玩家(@s)
# 【上限口径】「溢流」「蓄意」的文案都写了"最多有相当于自身最大生命值 ×2 的
#   临时生命值" ⇒ 这里统一夹到 最大生命×2（int 取整，和 lib/max_health_score 一致）。
#   ★ 本函数被 lib/heal（溢流）与蓄意每刻调用，属**热路径**，只做几次计分板运算。
# ============================================================

# ① 增量为 0 / 负数 ⇒ 什么都不做（只加不减；扣是 lib/thp/clear 的事）
execute if score #thp_v zx.meta matches ..0 run return 0

# ② 新值 = 旧值 + 增量
scoreboard players operation #thp_v zx.meta += @s zx.thp

# ③ 上限 = 最大生命 ×2（#max_hp 单位是 ×1000，先降到点）
function fallendream:lib/max_health_score
scoreboard players set #2 zx.meta 2
scoreboard players set #thp_cap zx.meta 0
scoreboard players operation #thp_cap zx.meta = #max_hp zx.meta
scoreboard players operation #thp_cap zx.meta /= #1000 zx.meta
scoreboard players operation #thp_cap zx.meta *= #2 zx.meta
execute if score #thp_v zx.meta > #thp_cap zx.meta run scoreboard players operation #thp_v zx.meta = #thp_cap zx.meta

# ④ 真正落值
function fallendream:lib/thp/set
'''

F['lib/thp/clear.mcfunction'] = r'''# ============================================================
# fallendream:lib/thp/clear —— 清空临时生命（硬清：连 absorption 效果一起撤）
# ------------------------------------------------------------
# 【谁调用它】lib/thp/tick（到期 / 被打空）
# 【执行者】玩家(@s)
# 【★ 为什么要清 effect ★】账本归零之后如果吸收还挂在身上，玩家会白拿一层黄心，
#   而我们的账本是"这层黄心归谁"的唯一真相 —— 两边不一致就是白送血。
#   `effect clear` 会连"法师预言·新生"给的吸收一起清掉：两者本来就互斥（见
#   lib/thp/set 文件头），这里按独占处理。
# ============================================================

execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove fallendream:thp_cap
tag @s remove zx.thp_on
effect clear @s minecraft:absorption
scoreboard players set @s zx.thp 0
scoreboard players set @s zx.thp_end 0
'''

F['lib/thp/clear_soft.mcfunction'] = r'''# ============================================================
# fallendream:lib/thp/clear_soft —— 账本归零时只撤吸收，不动 zx.thp（set 内部用）
# ------------------------------------------------------------
# 【为什么不直接用 lib/thp/clear】set 走到这里时 @s zx.thp 已经写成 0，再调 clear
#   会多读两次计分项；而且 set 之后还要继续判断"是否 return"，用轻量版更清楚。
# ============================================================

execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove fallendream:thp_cap
tag @s remove zx.thp_on
effect clear @s minecraft:absorption
scoreboard players set @s zx.thp_end 0
'''

F['lib/thp/tick.mcfunction'] = r'''# ============================================================
# fallendream:lib/thp/tick —— 临时生命每秒维护（到期 / 被打空）
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a[scores={zx.thp=1..}] run ...
# 【执行者】玩家(@s)
# 【两件事】
#   ① 到期：zx.thp_end ≤ #now ⇒ clear（效果 60 秒的兜底）。
#   ② 被打空：读 AbsorptionAmount（×100），≤0 而账本还在 ⇒ 视为清空。
#      ★ 这是全包唯一读玩家 NBT 的每秒路径，且只对"身上真挂着临时生命"的人跑
#        （选择器先按 zx.thp 过滤），通常 0~2 人。
# 【★ 检测顺延一拍 ★】清空发生在本刻受伤时，吸收值要到本刻 tickEffects 之后才变；
#   这里每秒检查一次，最晚 1 秒后被发现 —— 蓄意的"清空后给抗性/迅捷"按秒粒度
#   触发是文案允许的（"该效果每 12 秒最多触发一次"，没有更细的要求）。
# ============================================================

# ① 到期
execute if score @s zx.thp_end <= #now manacore.meta run function fallendream:lib/thp/clear

# ② 被打空（账本还在才读 NBT）
execute unless entity @s[tag=zx.thp_on] run return 0
scoreboard players set #thp_real zx.meta 0
execute store result score #thp_real zx.meta run data get entity @s AbsorptionAmount 100
execute if score #thp_real zx.meta matches ..0 run function fallendream:lib/thp/clear
'''

# ============================================================
# lib/fm —— 术阵位读数（占用 / 上限）
# ============================================================
F['lib/fm/read.mcfunction'] = r'''# ============================================================
# fallendream:lib/fm/read —— 每秒把"术阵位占用 / 上限"读进玩家计分项
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a run ...
# 【执行者】玩家(@s)
# 【出参】@s zx.fm_u = 已占用术阵位数
#         @s zx.fm_c = 当前术阵位上限（= stats.formation_limit，默认 3）
# 【为什么每秒一次】枢/承/屏息/独行 的判据全是"占用几个 / 满没满"，而术阵的增删
#   本来就只有技能施放那几个瞬间 ⇒ 秒级完全够；每刻去问前置包等于每刻读一遍
#   玩家记录（卡顿坑 1）。
# 【★ 术阵是纯占位 ★】本读数只反映"玩家名下登记了几个术阵"，与它有没有实体无关
#   （见 _tags_data.py 口径 5）。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 没分数 = 0 个（store 读不到时不会执行 ⇒ 先归零）
scoreboard players set @s zx.fm_u 0
scoreboard players set @s zx.fm_c 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count

execute store result score @s zx.fm_u run data get storage manacore:out r.count
execute store result score @s zx.fm_c run data get storage manacore:out r.limit
'''

for rel, txt in F.items():
    p = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(txt)
    print('wrote', rel, len(txt))
print('total', len(F))
