# 仅格式化显示：绝对值四舍五入到整数，再恢复符号；不改玩家实际属性。
scoreboard players operation #v_atk_abs zx.meta = #v_atk_m zx.meta
scoreboard players set #v_atk_neg zx.meta 0
execute if score #v_atk_m zx.meta matches ..-1 run scoreboard players operation #v_atk_neg zx.meta -= #v_atk_m zx.meta
execute if score #v_atk_m zx.meta matches ..-1 run scoreboard players operation #v_atk_abs zx.meta = #v_atk_neg zx.meta
scoreboard players operation #v_atk zx.meta = #v_atk_abs zx.meta
scoreboard players operation #v_atk zx.meta /= #1000 zx.meta
scoreboard players operation #v_atk_f zx.meta = #v_atk_abs zx.meta
scoreboard players operation #v_atk_f zx.meta %= #1000 zx.meta
execute if score #v_atk_f zx.meta matches 500.. run scoreboard players add #v_atk zx.meta 1
scoreboard players set #v_atk_neg zx.meta 0
execute if score #v_atk_m zx.meta matches ..-1 run scoreboard players operation #v_atk_neg zx.meta -= #v_atk zx.meta
execute if score #v_atk_m zx.meta matches ..-1 run scoreboard players operation #v_atk zx.meta = #v_atk_neg zx.meta
data modify storage zx:look atk set value {i:0}
execute store result storage zx:look atk.i int 1 run scoreboard players get #v_atk zx.meta
function fallendream:equipment/tool/look/attack_integer with storage zx:look atk
