
# ② 它必须在时停里, 否则整个被动不触发
$execute unless data entity $(vx_uuid) {Tags:["zx.stop"]} run return 0

# ③ 剩余时停秒数 = (zx.ts_end − #now) ÷ 20
scoreboard players set #dr_rem zx.meta 0
$execute store result score #dr_rem zx.meta run scoreboard players get $(vx_uuid) zx.ts_end
scoreboard players operation #dr_rem zx.meta -= #now manacore.meta
execute if score #dr_rem zx.meta matches ..0 run scoreboard players set #dr_rem zx.meta 0
scoreboard players operation #dr_rem zx.meta /= #20 zx.meta

# ③' 是不是超限版(用法同 cast: 主手或副手那件带 ol:"dream_reader")
scoreboard players set #dr_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["dream_reader"],ol:"dream_reader"}] run scoreboard players set #dr_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["dream_reader"],ol:"dream_reader"}] run scoreboard players set #dr_ol zx.meta 1

# ③'' 伤害 = 基础版 5 × 剩余秒数 / 超限版 基础攻击力(最低 10) × 剩余秒数 ×0.5
#   ★ 超限版那段单独抽成 ol_hit_dmg(要读 manacore 的 base_attack), 出参 #dr_dmg = 攻击力×100×秒数,
#     最后统一 ×0.005 变回实数 ⇒ 攻击力 × 秒数 × 0.5。
execute if score #dr_ol zx.meta matches 1 run function fallendream:equipment/axe/dream_reader/ol_hit_dmg
execute if score #dr_ol zx.meta matches 0 run scoreboard players operation #dr_dmg zx.meta = #dr_rem zx.meta
execute if score #dr_ol zx.meta matches 0 run scoreboard players operation #dr_dmg zx.meta *= #5 zx.meta

# ④ 真实伤害(带玩家归属)
data modify storage zx:work a set value {damage:0.0}
execute if score #dr_ol zx.meta matches 0 store result storage zx:work a.damage double 1 run scoreboard players get #dr_dmg zx.meta
execute if score #dr_ol zx.meta matches 1 store result storage zx:work a.damage double 0.005 run scoreboard players get #dr_dmg zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work a.s2_b_damage
function fallendream:lib/num/plain
$data modify storage zx:work a.target set value "$(vx_uuid)"
data modify storage zx:work a.type set value "fallendream:true_damage"
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function fallendream:internal/attack/submit_extra

# ⑤ 解除其时停(逐只调用 lib/timestop_one)
$execute as $(vx_uuid) if data entity @s {Tags:["zx.stop"]} run function fallendream:lib/timestop_one

# ⑥ 表现: 梦醒的碎光
$execute at $(vx_uuid) run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.03 14 normal
$execute at $(vx_uuid) run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.7 1.4

# ⑦ 清标记
$tag $(vx_uuid) remove zx.victim
