# ============================================================
# fallendream:overlimit/apply/light_pillow —— 右键超限石敲副手「轻枕」
# 进度 consume_item -> 撤销 -> station/api/apply(kind=overlimit,of=light_pillow)
# 成功改名换描述；失败退材料 + refuse 提示。
# ============================================================

advancement revoke @s only fallendream:overlimit/light_pillow

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"light_pillow"}
function fallendream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 轻枕已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/item/light_pillow
execute if data storage zx:out r{ok:0b} run function fallendream:overlimit/api/refuse
