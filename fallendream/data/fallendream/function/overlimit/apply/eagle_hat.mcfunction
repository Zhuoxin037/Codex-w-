# ============================================================
# fallendream:overlimit/apply/eagle_hat —— 右键超限石敲副手「鹰羽帽」
# 进度 consume_item -> 撤销 -> station/api/apply(kind=overlimit,of=eagle_hat)
# 成功改名换描述；失败退材料 + refuse 提示。
# ============================================================

advancement revoke @s only fallendream:overlimit/eagle_hat

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"eagle_hat"}
function fallendream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 鹰羽帽已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/item/eagle_hat
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/api/refuse
