# ============================================================
# sweetdream:equipment/axe/scorch_bone/convert —— 主目标「流火」->「夜火」+ 返还 40 魔力
# ------------------------------------------------------------
# 【谁调用它】scorch_bone/cast ⑥(只有在"主目标有流火、且没有夜火"时才调)
# 【执行者】施法者(玩家); 位置 = 自身
# 【★ 为什么"先摘再贴"★】「流火」在施加时给目标挂了**护甲 -20% 的属性修饰符**
#   (见 tag/mark_one); 摘标签必须走 tag/unmark —— 它会顺手 remove 那个修饰符,
#   否则修饰符会永久留在目标身上(不报错)。
# 【返还 40 魔力】走 manacore:api/mana/add(内部自动夹到上限, 不会溢出)。
# ============================================================

function sweetdream:tag/unmark {target:"@e[tag=zx.sc_t,distance=0..,limit=1]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[tag=zx.sc_t,distance=0..,limit=1]",mark:"yehuo"}

# 返还: 普通 40 / 超限 本次消耗 260 的 50% = 130
scoreboard players set #sc_r zx.meta 40
execute if score @s zx.scb_ol matches 1 run scoreboard players set #sc_r zx.meta 130
data modify storage manacore:in arg set value {uuid:"",value:40.0}
execute store result storage manacore:in arg.value double 1 run scoreboard players get #sc_r zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
execute if score @s zx.scb_ol matches 1 run tellraw @s [{"text":"焦骨: 「流火」化为「夜火」 · 返还 ","color":"gold"},{"score":{"name":"#sc_r","objective":"zx.meta"},"color":"aqua"},{"text":" 魔力","color":"gold"}]

# 表现: 流火被"烧成"夜火的那一下
execute at @e[tag=zx.sc_t,distance=0..,limit=1] run particle minecraft:soul_fire_flame ~ ~0.6 ~ 0.5 0.5 0.5 0.02 20 normal
