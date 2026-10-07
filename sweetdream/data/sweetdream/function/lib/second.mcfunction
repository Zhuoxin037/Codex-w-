# ============================================================
# sweetdream:lib/second —— 公共件们的每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【备份公共输入口】下面这些都会读/写 manacore:in arg, 见 lib/in_bak。
# ============================================================

# 【进度的安全网不在这里】lib/rearm 是"每刻"跑的, 挂在 core/tick 最前面, 不挂这里
#   —— 理由见那两个文件; 别在本文件里再调一次(会变成每刻 + 每秒各一次, 无意义)。

function sweetdream:lib/in_bak

# 「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)的每秒衰减 ——
#   2026-10-08: mm_add 改成"打出一次最大魔力值技能才清零", 不再需要每秒推进;
#   lib/mm_add/tick 那份文件已删(原来的按秒衰减作废, 见 lib/mm_add/take)。
#   ★ 只给"还有剩余秒数"的人跑(没有这个分数的人不必每小时都进去走一趟)。

# 冻结/时停到点解冻
# 流光: 每秒扫"到点结算"的人 —— 取代一次性 schedule, 多人同时施法不会互相顶掉(第 3 条)
execute as @a[tag=zx.lg_casting] at @s run function sweetdream:equipment/sword/liuguang/hit_self
# 超限·流光: 同上, 每秒扫"到点结算"的人(4 个目标的延迟伤害)
execute as @a[tag=zx.lgo_casting] at @s run function sweetdream:equipment/sword/liuguang/ol_hit_self

# 游星(2026-10-07 批1): 每秒扫"到点结算"的人 —— 锁定 3 秒后对被锁目标 2 格内全部生物打 基础攻击力×4
execute as @a[tag=zx.rs_casting] at @s run function sweetdream:equipment/sword/rogue_star/hit_self

# 永霜(2026-10-07 批1): 同上 —— 冰冻 3 秒后对被冻住的那批打 当前剩余魔力×0.1
execute as @a[tag=zx.ef_casting] at @s run function sweetdream:equipment/sword/everfrost/hit_self

# 神裁(2026-10-07 批1): 「领域」每秒一跳 —— 领域内(半径 2)生物吃 基础攻击力×3;
#   领域是 marker 实体, 计时 zx.vd_ft 归零就 kill 自己。
#   ★ 三维度各写一遍 + 每行 distance=0.. (event/second 默认在主世界跑; 裸 @e 会跨维度重复处理)
execute in minecraft:overworld as @e[type=marker,tag=zx.vd_field,distance=0..] at @s run function sweetdream:equipment/sword/verdict/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.vd_field,distance=0..] at @s run function sweetdream:equipment/sword/verdict/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.vd_field,distance=0..] at @s run function sweetdream:equipment/sword/verdict/field_tick

# 崩裂(2026-10-07 批2): 「裂缝」每秒一跳 —— 裂缝内(半径 3)全部生物吃 施放者基础攻击力×1;
#   裂缝是 marker, 计时 zx.fi_ft 归零就 kill 自己。★ 三维度各写一遍 + distance=0..(同神裁领域)。
execute in minecraft:overworld as @e[type=marker,tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/field_tick

# 威霆(2026-10-07 批2): 「术阵」每秒推进 —— 计时 zx.tc_ft 归零就收阵(field_end 反查施法者清 zx.tc_on)。
execute in minecraft:overworld as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick

# 饮鸩(2026-10-07 批2): 攻击力加成每秒 -1 秒, 到点撤除(strip 把账本减回去)
execute as @a[scores={zx.dg_on=1..}] run function sweetdream:equipment/axe/draught/expire

# 火种(2026-10-07 批1): 手持自动点燃 —— 每秒对所有人跑一次(没拿火种/已燃烧/魔力不足都自己 return)
execute as @a run function sweetdream:equipment/sword/tinder/second

# 深海: 正在施法的人每秒补画一次范围环(同上)
execute if entity @a[tag=zx.de_run] run function sweetdream:equipment/sword/deepsea_echo/fx

# 升级: 穿着的盔甲上的升级(魔力上限 / 每秒回魔) —— 见 upgrade/second
function sweetdream:upgrade/second

function sweetdream:lib/unfreeze_sweep

# 虹彩: 漫彩每秒推进(吞噬效果 / 到点结束触发范围伤) —— 只对带 zx.rb_rainbow 的生物跑
execute as @e[tag=zx.rb_rainbow] run function sweetdream:equipment/bow/rainbow/second

# 常驻状态特效(圣痕=金 / 升痕=天蓝, 按层数分档) —— 见 status/aura
function sweetdream:status/aura

# 生物身上「武器专属标签」的到期衰减(圣痕 15 秒消失 / 升痕 每 15 秒 −1 层) —— 见 status/decay
function sweetdream:status/decay

# 极光与幻梦: 时停期间每隔 3 秒的飘渺钟声 + 持续极光粒子
execute as @a[scores={zx.ad_bell=1..}] run function sweetdream:equipment/sword/aurora_dream/bell

# 魔力上限下限保护 —— 必须放在所有装备结算之后(脑髓蛭/脊骨共生会把上限算成负数)
execute as @a run function sweetdream:lib/mana_floor

function sweetdream:lib/in_restore
