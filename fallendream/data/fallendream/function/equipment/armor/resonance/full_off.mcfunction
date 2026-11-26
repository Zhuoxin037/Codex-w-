# ============================================================
# fallendream:equipment/armor/resonance/full_off —— 超限·共振：魔耗倍率退回 1.0
# ------------------------------------------------------------
# 【执行者】玩家（resonance/passive 每秒对"没穿超限共振"的人调一次）
# 【为什么必须有这一支】mana_cost_multiplier 写的是**面板属性**, 不跟着装备走;
#   摘甲 / 换成普通共振 / 不再全满时如果不退, 那 15% 折扣会永久留在面板上
#   （重进世界只会清账本, 属性本身还挂着）。
# 【★ 只对"账本不是 1.0"的人动手 ★】绝大多数玩家这里是 1000, 不加门控等于每秒
#   给全服玩家白写一条 players.<uuid>.stats。
# 【★ 冷却 -15% 不在这里退 ★】它是按次减的(on_cast), 没有常驻状态可退。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

scoreboard players add @s zx.rs_mcm 0
scoreboard players set #rs_d zx.meta 1000
scoreboard players operation #rs_d zx.meta -= @s zx.rs_mcm
execute unless score @s zx.rs_mcm matches 1000 run function fallendream:equipment/armor/resonance/apply_mcm
