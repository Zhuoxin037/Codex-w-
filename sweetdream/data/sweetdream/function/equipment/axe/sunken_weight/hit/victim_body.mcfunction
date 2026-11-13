$execute unless entity $(vx_uuid) run return 0

# ---- ① 用**加层前**的层数算固定伤害：4 + 2×n ----
scoreboard players add @s zx.sw_n 0
scoreboard players set #sw_d zx.meta 4
scoreboard players operation #sw_t zx.meta = @s zx.sw_n
scoreboard players operation #sw_t zx.meta *= #2 zx.meta
scoreboard players operation #sw_d zx.meta += #sw_t zx.meta

$data modify storage zx:work a set value {fixed:1b,target:"$(vx_uuid)",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 0.0
execute store result storage zx:work a.num double 1.0 run scoreboard players get #sw_d zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ---- ② 获得 1 层（上限 5），并同步移速 ----
execute if score @s zx.sw_n matches ..4 run scoreboard players add @s zx.sw_n 1
execute if score @s zx.sw_n matches 5.. run scoreboard players set @s zx.sw_n 5
function sweetdream:equipment/axe/sunken_weight/speed_sync

$execute at $(vx_uuid) run particle minecraft:block{block_state:"minecraft:iron_block"} ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
$execute at $(vx_uuid) run playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.4 1.6
$tag $(vx_uuid) remove zx.victim
