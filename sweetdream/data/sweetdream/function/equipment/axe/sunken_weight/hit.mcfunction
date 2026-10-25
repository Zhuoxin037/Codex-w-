# ============================================================
# sweetdream:equipment/axe/sunken_weight/hit —— 沉砣（铁斧 · 普攻）
# ------------------------------------------------------------
# 【技能原文】
#   "每次命中额外造成 4 点固定伤害（不参与任何加成），并获得 1 层「砣」，最多 5 层。
#    每层「砣」使该固定伤害 +2 点，并使自身移动速度降低 4%。
#    自身受到任何伤害时，「砣」立即清零。"
# 【★ 顺序：先按"当前层数"算伤害，再加层 ★】
#   设计写的顺序就是"造成 4 点 → 获得 1 层"，所以第 1 次命中是 4 点（不是 6 点），
#   到满层后稳定在 4 + 2×5 = 14 点。
# 【固定伤害】绕开 api/damage/calc：a.num 直接写这个整数。
# ============================================================
advancement revoke @s only sweetdream:equipment/axe/sunken_weight_hit

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sunken_weight"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sunken_weight"]}] run return 0

function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=..16,limit=1] run return 0

# ---- ① 用**加层前**的层数算固定伤害：4 + 2×n ----
scoreboard players add @s zx.sw_n 0
scoreboard players set #sw_d zx.meta 4
scoreboard players operation #sw_t zx.meta = @s zx.sw_n
scoreboard players operation #sw_t zx.meta *= #2 zx.meta
scoreboard players operation #sw_d zx.meta += #sw_t zx.meta

data modify storage zx:work a set value {fixed:1b,target:"@e[tag=zx.victim,distance=..16,limit=1]",type:"minecraft:player_attack"}
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

execute at @e[tag=zx.victim,distance=..16,limit=1] run particle minecraft:block{block_state:"minecraft:iron_block"} ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @e[tag=zx.victim,distance=..16,limit=1] run playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.4 1.6
tag @e[tag=zx.victim] remove zx.victim
