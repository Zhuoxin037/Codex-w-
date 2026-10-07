# ============================================================
# sweetdream:equipment/axe/angel_core/dmg2 —— 第二段: 最大魔力 ×0.08, 重复 2 次
# ------------------------------------------------------------
# 【执行者】施法者
# 【目标】自身 6 格内带「圣痕」的生物 2 格内的全部生物(= 并集, 不重复打同一只)
# 【通道】max_mana_mul(基数 = 面板最大魔力) -> 顺带吃「下一次技能加成」(风声)
# 【收尾】清掉"触发了第二段效果的圣痕" = 6 格内那些做过中心的
# 【谁调用它】core/tick —— cast 放完第一段后给玩家挂 zx.ac_delay + zx.ac_d=10,
#   倒计时走到 0 由每刻钩子调这里(0.5 秒的"技能间隔")。
# ============================================================

# ⓪ ★ 第一件事: 摘掉"延后"标记 ★
#   本函数可能在 ①/② 提前 return, 标记若不在最前面摘掉, core/tick 会**每刻重复调用**它。
tag @s remove zx.ac_delay
scoreboard players reset @s zx.ac_d

# ① 中心: 6 格内带「圣痕」的
tag @e[tag=zx.ac_c] remove zx.ac_c
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6,tag=zx.status.shenghen] add zx.ac_c
execute unless entity @e[tag=zx.ac_c] run return 0

# ② 每个中心的 2 格内全部生物并成 zx.ac_aoe(先清空再收, 免得留上一轮的)
tag @e[tag=zx.ac_aoe] remove zx.ac_aoe
execute at @e[tag=zx.ac_c] run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.ac_aoe
execute unless entity @e[tag=zx.ac_aoe] run return 0

# ③ 算伤害: 最大魔力 ×0.08
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 打两次(文案: 重复 2 次)
data modify storage zx:in arg set value {target:"@e[tag=zx.ac_aoe]",read:"manacore"}
# dup-ok: 文案"重复 2 次", 这里刻意打两遍
execute at @s run function sweetdream:api/damage
execute at @s run function sweetdream:api/damage

# ⑤ 清除触发了第二段效果的「圣痕」(就是这些中心) —— 连同它的计时一起清(与 status/decay_shenghen 一致)
tag @e[tag=zx.ac_c] remove zx.status.shenghen
scoreboard players reset @e[tag=zx.ac_c] zx.sh_t
execute at @e[tag=zx.ac_c] run particle minecraft:enchant ~ ~1 ~ 0.3 0.3 0.3 0.05 12 normal
execute at @s run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.7 1.3

tag @e[tag=zx.ac_c] remove zx.ac_c
tag @e[tag=zx.ac_aoe] remove zx.ac_aoe
