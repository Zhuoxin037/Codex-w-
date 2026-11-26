# ============================================================
# fallendream:equipment/armor/cease_war/end —— 止战：余勇结束（到期 / 换职业 / 死亡 / 摘甲）
# ============================================================
# ---- ① 撤属性（护甲 +6 / 击退抗性 +0.3）----
execute if entity @s[tag=zx.s2_cw] run attribute @s minecraft:armor modifier remove fallendream:cease_war
execute if entity @s[tag=zx.s2_cw] run attribute @s minecraft:knockback_resistance modifier remove fallendream:cease_war

# ---- ② 超限: 护甲韧性 +1 与"基础攻击力 +5%×N"一起退 ----
#   ★ 韧性用账本 zx.cw_t 门控（没挂过就不要去 remove —— 免得白报一次失败）。
scoreboard players add @s zx.cw_t 0
execute if score @s zx.cw_t matches 1 run attribute @s minecraft:armor_toughness modifier remove fallendream:cease_war_t
scoreboard players set @s zx.cw_t 0

#   加攻是差值账本(zx.cw_badd, ×1000)：取负一次性退回去，然后清账。
scoreboard players add @s zx.cw_badd 0
execute if score @s zx.cw_badd matches 1.. run function fallendream:lib/uuid
execute if score @s zx.cw_badd matches 1.. run data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
execute if score @s zx.cw_badd matches 1.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
scoreboard players set #cw_neg zx.meta 0
execute if score @s zx.cw_badd matches 1.. run scoreboard players operation #cw_neg zx.meta -= @s zx.cw_badd
execute if score @s zx.cw_badd matches 1.. run execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #cw_neg zx.meta
execute if score @s zx.cw_badd matches 1.. run function manacore:api/stats/add
scoreboard players set @s zx.cw_badd 0
scoreboard players set @s zx.cw_st 0
scoreboard players set @s zx.cw_b0 0
scoreboard players set @s zx.s2_cw_x 0

# ---- ③ 标记与计时 ----
tag @s remove zx.s2_cw
scoreboard players set @s zx.s2_cw_end 0
