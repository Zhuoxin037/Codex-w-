# ============================================================
# fallendream:overlimit/apply/gather_energy —— 右键超限石敲副手「聚能」
# 进度 consume_item -> 撤销 -> station/api/apply(kind=overlimit,of=gather_energy)
# 成功改名换描述；失败退材料 + refuse 提示。
# ============================================================

advancement revoke @s only fallendream:overlimit/gather_energy

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"gather_energy"}
function fallendream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 聚能已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/item/gather_energy
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/api/refuse
