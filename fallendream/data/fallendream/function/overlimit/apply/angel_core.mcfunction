# ============================================================
# fallendream:overlimit/apply/angel_core —— 右键超限石敲副手「天使核心」
# 进度 consume_item -> 撤销 -> station/api/apply(kind=overlimit,of=angel_core)
# 成功改名换描述；失败退材料 + refuse 提示。
# ============================================================

advancement revoke @s only fallendream:overlimit/angel_core

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"angel_core"}
function fallendream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 天使核心已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/item/angel_core
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/api/refuse
