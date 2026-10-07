# ============================================================
# sweetdream:lib/skill_mul/gear —— "在身装备(主手武器)给的那份乘区"
# ------------------------------------------------------------
# 【执行者】玩家本人
# 【读】主手物品 custom_data.zx[0] + overlimit/api/bonus_held
# 【做什么】把主手武器敲出来的超限伤害换算成"倍率", 再按口径表(lib/skill_mul/def)
#   写进 zx:work pl 上对应的通道(smul_mm / smul_atk / smul_oth)。
# 【前置】调用方(lib/skill_mul/scan)已经确认主手是本包装备(有 custom_data.zx)。
#
# 【★ 为什么单独拆一个文件 ★】
#   下面有两处"拿不到就收工"的提前 return(没 zx[0]、没敲超限)。
#   而 scan 在后面还要折"待生效的风声加成" —— 那是**玩家身上的 buff**,
#   与主手拿什么、敲没敲超限都无关。return 只在当前函数内生效,
#   所以把这段隔离出来, scan 的主干就无论如何都能走到风声那一步。
#   ⚠️ 2026-10-04 真实事故: 玩家没敲超限(has=0)时这段 return 掉,
#      连风声折入一起被跳过 -> 放完风行技能, 面板"最大魔力值技能倍率"还是 ×1。
# ============================================================

data remove storage zx:work sm
data modify storage zx:work sm.id set from entity @s SelectedItem.components."minecraft:custom_data".zx[0]
execute unless data storage zx:work sm.id run return 0

# 超限伤害(0.25 = +25%) -> 换算成"倍率"(1.25) 存进 sm.v
#   超限在 x1000 定点上算: bonus×1000 + 1000, 再写回 double(×0.001)。
function sweetdream:overlimit/api/bonus_held
execute unless data storage zx:out r{has:1b} run return 0
scoreboard players set #sm_v zx.meta 1000
execute store result score #sm_v zx.meta run data get storage zx:out r.dmg 1000
scoreboard players add #sm_v zx.meta 1000
execute store result storage zx:work sm.v double 0.001 run scoreboard players get #sm_v zx.meta

# 按口径表把这份倍率写进对应的通道(宏: 路径里有 $(id))
function sweetdream:lib/skill_mul/apply with storage zx:work sm
