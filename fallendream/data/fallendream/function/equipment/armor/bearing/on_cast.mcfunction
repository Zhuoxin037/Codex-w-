# ============================================================
# fallendream:equipment/armor/bearing/on_cast —— 「阵成」期间技能冷却 −10%（cooldown_start）
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start（前置包在**冷却写入之后**抛出，
#   此刻正在冷却的那个技能已经落盘，读 get 拿到的就是本次总时长）
# 【执行者】施法者（玩家）
# 【★ 为什么不写 stats.cooldown_reduction ★】那条属性被 upgrade/api/cd_stat 独占：
#   它每次结算都会**整体覆盖**（reduction_set），我们写进去会被下一秒抹掉，
#   而且会连带改掉别人武器的冷却缩减。这里改成"对这一个技能 reduce 10%"。
# 【★ reduce 的单位是 tick ★】remaining/10 就是 10%（整数除法，最多差 1 刻）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
# 三份阵成各算一份减冷却: 套装 zx.br_zc + 超限枢自己的 zx.pv_zc(2026-11-22)
#   + 超限承自己那份 zx.brx_zc(2026-11-23)
scoreboard players set #br_on zx.meta 0
execute if score @s zx.br_zc > #now manacore.meta run scoreboard players set #br_on zx.meta 1
execute if score @s zx.pv_zc > #now manacore.meta run scoreboard players add #br_on zx.meta 1
execute if score @s zx.brx_zc > #now manacore.meta run scoreboard players add #br_on zx.meta 1
execute if score #br_on zx.meta matches 0 run return 0
execute unless data storage manacore:ctx skill run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 读该技能本次冷却总长
data modify storage zx:work cd.skill set from storage manacore:ctx skill
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cd.skill
function manacore:api/cooldown/get

scoreboard players set #br_rem zx.meta 0
execute store result score #br_rem zx.meta run data get storage manacore:out r.remaining
execute if score #br_rem zx.meta matches ..9 run return 0
scoreboard players set #br_10 zx.meta 10
scoreboard players operation #br_rem zx.meta /= #br_10 zx.meta
# 每份 10%，份数直接乘（2 份 ≈19%，3 份 ≈27%）
execute if score #br_on zx.meta matches 2.. run scoreboard players operation #br_rem zx.meta *= #br_on zx.meta

data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cd.skill
execute store result storage manacore:in arg.ticks int 1 run scoreboard players get #br_rem zx.meta
function manacore:api/cooldown/reduce
