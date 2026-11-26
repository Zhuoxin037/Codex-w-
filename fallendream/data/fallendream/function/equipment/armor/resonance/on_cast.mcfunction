# ============================================================
# fallendream:equipment/armor/resonance/on_cast —— 超限·共振：技能冷却 −15%
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start（前置包在**冷却写入之后**抛出，
#   此刻正在冷却的那个技能已经落盘，get 拿到的就是本次总时长）
# 【执行者】施法者（玩家）
# 【文案】术阵位全满时，…自身释放技能所需魔耗及技能冷却时间 -15%。
# 【★ 为什么不写 stats.cooldown_reduction ★】那条属性被 upgrade/api/cd_stat 独占：
#   它每次结算都会整体覆盖（reduction_set），我们写进去会被下一秒抹掉，而且会连带
#   改掉别人武器的冷却缩减。改成"对这一个技能 reduce 15%"（与 bearing/on_cast 同款）。
# 【★ reduce 的单位是 tick ★】remaining/100*15 就是 15%（整数除法，最多差 1 刻）。
# 【★ 术阵全满要现算 ★】cooldown_start 那一刻的术阵数才是文案说的"自身当前"。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"],ol:"resonance"}] run return 0
execute unless data storage manacore:ctx skill run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
scoreboard players set #rs_c zx.meta 0
scoreboard players set #rs_l zx.meta 0
execute store result score #rs_c zx.meta run data get storage manacore:out r.count
execute store result score #rs_l zx.meta run data get storage manacore:out r.limit
execute unless score #rs_l zx.meta matches 1.. run return 0
execute unless score #rs_c zx.meta >= #rs_l zx.meta run return 0

# 读该技能本次冷却总长
data modify storage zx:work cd.skill set from storage manacore:ctx skill
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cd.skill
function manacore:api/cooldown/get
scoreboard players set #rs_rem zx.meta 0
execute store result score #rs_rem zx.meta run data get storage manacore:out r.remaining
execute if score #rs_rem zx.meta matches ..19 run return 0

# 15% = remaining × 15 ÷ 100（先除后乘，避免中间量溢出）
scoreboard players set #rs_15 zx.meta 15
scoreboard players operation #rs_rem zx.meta *= #rs_15 zx.meta
scoreboard players set #rs_100 zx.meta 100
scoreboard players operation #rs_rem zx.meta /= #rs_100 zx.meta
execute if score #rs_rem zx.meta matches 0 run return 0

data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cd.skill
execute store result storage manacore:in arg.ticks int 1 run scoreboard players get #rs_rem zx.meta
function manacore:api/cooldown/reduce
