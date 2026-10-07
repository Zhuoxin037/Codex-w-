# ------------------------------------------------------------
# 超限版: 真的低于 80% -> 每秒回 3% 魔力值(按**上限**算, 走 api/mana/add 不会超上限)
#   ★ 3% 是"最大魔力的 3%", 不是"当前魔力的 3%" —— 后者越缺蓝回得越少, 反直觉。
# ------------------------------------------------------------
scoreboard players set #dd_p zx.meta 0
execute store result score #dd_p zx.meta run data get storage manacore:out r.max
scoreboard players operation #dd_p zx.meta *= #3 zx.meta
scoreboard players operation #dd_p zx.meta /= #100 zx.meta
execute unless score #dd_p zx.meta matches 1.. run return 0

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #dd_p zx.meta
function manacore:api/mana/add

scoreboard players operation @s zx.regen_extra += #dd_p zx.meta
