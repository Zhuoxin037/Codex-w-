# ============================================================
# fallendream:equipment/bow/ember_string/ol_reward —— 烬弦·超限：三种集齐的回响
# ------------------------------------------------------------
# 【执行者】被命中那只生物
# 【入参】zx:work es {uuid, u0..u3}
# 【文案】"若对一个生物在 12 秒内触发了以上全部效果, 则对其造成一次相当于自身
#   最大魔力值 x 0.08 的伤害, 并使其随机附加一个除了「流火」和「夜火」的标签。"
# 【★ 先清三个时刻再打 ★】不清的话下一发只要再触发任意一种, 三个时刻仍在窗口内
#   ⇒ 每次都满足"集齐", 会变成永久触发。
# 【随机标签词表】噬心 / 渊海 / 白昼梦 —— 包内既有五种状态标签去掉「流火」「夜火」,
#   与苦痛超限、杂纹超限用的是同一套, 别另开新的。
# ============================================================

# ① 这一轮的回响发过 -> 三个时刻全部清掉, 等它重新攒
scoreboard players reset @s zx.es_t1
scoreboard players reset @s zx.es_t2
scoreboard players reset @s zx.es_t3

# ② 表现: 流火 / 夜火 / 第三种余烬合成一次回响
execute at @s run particle minecraft:dust{color:[1.0,0.55,0.15],scale:1.6} ~ ~1 ~ 0.8 0.9 0.8 0.05 30 normal
execute at @s run particle minecraft:soul_fire_flame ~ ~1 ~ 0.5 0.6 0.5 0.02 12 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.9 0.7
execute at @s run playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.8 0.6

# ③ 伤害 = 射手最大魔力值 ×0.08(与 ③-C 同一套顶点: 先 calc 再走 with_from)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:work es.uuid
function manacore:api/damage/calc

data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_damage set value {n:0,d:1}
data modify storage zx:work a.s2_b_damage set from storage manacore:out r.s2_b_damage
data modify storage zx:work a.u0 set from storage zx:work es.u0
data modify storage zx:work a.u1 set from storage zx:work es.u1
data modify storage zx:work a.u2 set from storage zx:work es.u2
data modify storage zx:work a.u3 set from storage zx:work es.u3
data modify storage zx:work a.num set from storage zx:work a.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work a.s2_b_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra

# ④ 随机附加一个除「流火」「夜火」之外的标签(三选一)
function fallendream:lib/rnd
scoreboard players operation #es_r zx.meta = #rnd zx.meta
scoreboard players operation #es_r zx.meta %= #3 zx.meta
data modify storage zx:work ic set value {target:"@s",mark:"shixin"}
execute if score #es_r zx.meta matches 1 run data modify storage zx:work ic.mark set value "yuanhai"
execute if score #es_r zx.meta matches 2 run data modify storage zx:work ic.mark set value "dream"
function fallendream:tag/mark with storage zx:work ic
