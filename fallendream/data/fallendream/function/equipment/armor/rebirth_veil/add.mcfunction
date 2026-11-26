execute unless score @s zx.job matches 4 run return 0
execute unless score @s zx.j_form matches 0 run return 0
execute unless score @s zx.j_reborn matches 1.. run return 0
execute unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run return 0
scoreboard players operation @s zx.s2_veil_rec += #s2_veil_before zx.meta
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #s2_veil_req zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #mp_src zx.meta = #s2_veil_req zx.meta
# 【超限】门槛 6×基础攻击力 → 4×基础攻击力(4000 千分), 每单位缩短 1 秒 → 2 秒
scoreboard players set #mp_mul zx.meta 6000
execute if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run scoreboard players set #mp_mul zx.meta 4000
function fallendream:lib/math/mul_permille
scoreboard players operation #s2_veil_req zx.meta = #mp_out zx.meta
execute unless score #s2_veil_req zx.meta matches 1.. run return 0
scoreboard players operation #s2_veil_count zx.meta = @s zx.s2_veil_rec
scoreboard players operation #s2_veil_count zx.meta /= #s2_veil_req zx.meta
scoreboard players operation @s zx.s2_veil_rec %= #s2_veil_req zx.meta
# 每凑满一个门槛: 基础版 20 刻(1 秒) / 超限 40 刻(2 秒)
scoreboard players set #s2_twenty zx.meta 20
execute if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run scoreboard players set #s2_twenty zx.meta 40
scoreboard players operation #s2_veil_count zx.meta *= #s2_twenty zx.meta
scoreboard players operation @s zx.j_reborn -= #s2_veil_count zx.meta
execute if score @s zx.j_reborn matches ..0 run scoreboard players set @s zx.j_reborn 0
