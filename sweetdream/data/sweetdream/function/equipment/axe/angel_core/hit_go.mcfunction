# ============================================================
# sweetdream:equipment/axe/angel_core/hit_go —— 被动主体: 给"还没有圣痕"的铺「圣痕」
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【文案】每次攻击后若自身有 80 及以上的魔力值, 则消耗 80 魔力值并使离自身
#   8 格内最近的 3 个生物附加「圣痕」。
# 【★ 2026-10-04 规则调整 ★】「圣痕」**同一只只能给一次**:
#   8 格内最近的 3 个里如果**全都已经带圣痕**, 这一次整个不触发(不扣蓝、不铺)。
#   带圣痕的生物会一直有金色常态特效(由 status/aura 每秒画)。
# 【顺序】先钉候选 -> 数"还没圣痕的" -> 有才查/扣魔力 -> 只给没圣痕的加。
# 【★ 每条提前 return 之前都要把 zx.ac_t 清掉 ★】不然残留标签会被下一次攻击当成目标。
# ============================================================

# ① 钉住"8 格内最近的 3 个生物"
#   【为什么先打标签】@e[sort=nearest,limit=3] 每次求值都会重挑, 不冻结的话
#   后面"打粒子"和"贴标签"可能作用在不同的三只身上。
tag @e[tag=zx.ac_t] remove zx.ac_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=3] add zx.ac_t
execute unless entity @e[tag=zx.ac_t] run return 0

# ② 其中"还没有圣痕"的有几个? 一个都没有 -> 不触发(圣痕只能给一次)
scoreboard players set #ac_new zx.meta 0
execute as @e[tag=zx.ac_t] unless entity @s[tag=zx.status.shenghen] run scoreboard players add #ac_new zx.meta 1
execute if score #ac_new zx.meta matches ..0 run tag @e[tag=zx.ac_t] remove zx.ac_t
execute if score #ac_new zx.meta matches ..0 run return 0

# ③ 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tag @e[tag=zx.ac_t] remove zx.ac_t
execute unless data storage zx:data self{ok:1b} run return 0

# ④ 读当前魔力(不到 80 就整个不动, 也不扣蓝)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #ac_m zx.meta 0
execute store result score #ac_m zx.meta run data get storage manacore:out r.value 1
execute if score #ac_m zx.meta matches ..79 run tag @e[tag=zx.ac_t] remove zx.ac_t
execute if score #ac_m zx.meta matches ..79 run return 0

# ⑤ 消耗 80 魔力(扣不动就什么都不做)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tag @e[tag=zx.ac_t] remove zx.ac_t
execute if data storage manacore:out r{success:0b} run return 0

# ⑥ 只给"还没有圣痕"的加(已有的不重复给), 音效响一次
execute as @e[tag=zx.ac_t] unless entity @s[tag=zx.status.shenghen] run function sweetdream:equipment/axe/angel_core/mark
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.6
tag @e[tag=zx.ac_t] remove zx.ac_t
