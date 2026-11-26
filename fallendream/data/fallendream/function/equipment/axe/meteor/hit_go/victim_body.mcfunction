
# 掷骰子(无论走哪条分支都掷一次, 保持序列连续)
function fallendream:lib/rnd

# ★ 计分项"没分数 ≠ 0": 老存档里玩家身上可能还没有 mt_keep
scoreboard players add @s zx.mt_keep 0
scoreboard players add @s zx.mt_on 0

scoreboard players set #mt_p zx.meta 0

# ===== 超限·陨星(批 K6) =====
#   熔星形态: 100%(直接命中); 平时: 15%(#rnd %20 落在 0..2)
execute if score @s zx.mt_keep matches 1 if score @s zx.mt_on matches 1.. run scoreboard players set #mt_p zx.meta 1
execute if score @s zx.mt_keep matches 1 unless score @s zx.mt_on matches 1.. run scoreboard players operation #mt_r zx.meta = #rnd zx.meta
execute if score @s zx.mt_keep matches 1 unless score @s zx.mt_on matches 1.. run scoreboard players operation #mt_r zx.meta %= #20 zx.meta
execute if score @s zx.mt_keep matches 1 unless score @s zx.mt_on matches 1.. if score #mt_r zx.meta < #3 zx.meta run scoreboard players set #mt_p zx.meta 1

# ===== 普通版 =====
# ---- 熔星形态: 50% (取模 10, 落在 0..4) ----
execute if score @s zx.mt_keep matches 0 if score @s zx.mt_on matches 1.. run scoreboard players operation #mt_r zx.meta = #rnd zx.meta
execute if score @s zx.mt_keep matches 0 if score @s zx.mt_on matches 1.. run scoreboard players operation #mt_r zx.meta %= #10 zx.meta
execute if score @s zx.mt_keep matches 0 if score @s zx.mt_on matches 1.. if score #mt_r zx.meta < #5 zx.meta run scoreboard players set #mt_p zx.meta 1
# ---- 平时: 10% (取模 10, 落在 0) ----
execute if score @s zx.mt_keep matches 0 unless score @s zx.mt_on matches 1.. run scoreboard players operation #mt_r zx.meta = #rnd zx.meta
execute if score @s zx.mt_keep matches 0 unless score @s zx.mt_on matches 1.. run scoreboard players operation #mt_r zx.meta %= #10 zx.meta
execute if score @s zx.mt_keep matches 0 unless score @s zx.mt_on matches 1.. if score #mt_r zx.meta matches 0 run scoreboard players set #mt_p zx.meta 1

execute if score #mt_p zx.meta matches 1 run function fallendream:equipment/axe/meteor/fall

# 超限·熔星形态: 每次攻击再掷一次 30% -> 一颗「大陨石」(×8 / 缓慢Ⅴ)
#   ★ 必须排在"清 zx.victim"之前 —— 它要打"自身攻击的那只"。
execute if score @s zx.mt_keep matches 1 if score @s zx.mt_on matches 1.. run function fallendream:equipment/axe/meteor/ol_big

$tag $(vx_uuid) remove zx.victim
