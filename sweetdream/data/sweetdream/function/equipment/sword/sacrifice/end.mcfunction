# ============================================================
# sweetdream:equipment/sword/sacrifice/end —— 牺牲：流血结束，撤加成
# ------------------------------------------------------------
# 按账本 zx.sc_atk（施放时基础攻击力 ×100）原样取负减回，系数 0.006 = ×0.6 ÷ 100。
# ============================================================

execute if score @s zx.sc_on matches 0 run return 0
scoreboard players set @s zx.sc_on 0

execute if score @s zx.sc_atk matches 1.. run function sweetdream:lib/uuid
execute if score @s zx.sc_atk matches 1.. unless data storage zx:data self{ok:1b} run scoreboard players set @s zx.sc_atk 0

scoreboard players operation #sc_neg zx.meta = @s zx.sc_atk
scoreboard players set #sc_m1 zx.meta -1
scoreboard players operation #sc_neg zx.meta *= #sc_m1 zx.meta
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.sc_atk matches 1.. store result storage manacore:in arg.value double 0.006 run scoreboard players get #sc_neg zx.meta
execute if score @s zx.sc_atk matches 1.. run function manacore:api/stats/add

scoreboard players set @s zx.sc_atk 0
scoreboard players set @s zx.sc_dps 0
scoreboard players set @s zx.sc_floor 0
