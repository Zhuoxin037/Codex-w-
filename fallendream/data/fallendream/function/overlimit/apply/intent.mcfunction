# ============================================================
# fallendream:overlimit/apply/intent —— 右键超限石敲副手「蓄意」
# 进度 consume_item -> 撤销 -> station/api/apply(kind=overlimit,of=intent)
# 成功改名换描述；失败退材料 + refuse 提示。
# ============================================================

advancement revoke @s only fallendream:overlimit/intent

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"intent"}
function fallendream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 蓄意已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/item/intent
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/api/refuse
