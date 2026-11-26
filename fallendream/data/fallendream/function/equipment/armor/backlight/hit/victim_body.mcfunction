$execute unless entity $(vx_uuid) run return 0

# ⑤ 它带「夜火」吗？不带就收工
$execute as $(vx_uuid) unless entity @s[tag=zx.status.yehuo] run tag $(vx_uuid) remove zx.victim
$execute unless entity $(vx_uuid) run return 0

# ⑥ 消耗它的「夜火」
$data modify storage zx:work a set value {target:"$(vx_uuid)",mark:"yehuo",by:"@s",src:"equip"}
function fallendream:lib/mark_consume

# ⑦ 被「永恒」补回来了 → 不算消耗，不给「回照」
$tag $(vx_uuid) remove zx.victim
execute if data storage zx:work mc{done:1b} run return 0

# ⑧ 获得「回照」5 秒（100 刻）
scoreboard players operation @s zx.bk_wd = #now manacore.meta
scoreboard players add @s zx.bk_wd 100

# ⑨ 20 秒节流记账（400 刻）
scoreboard players operation @s zx.bk_cd = #now manacore.meta
scoreboard players add @s zx.bk_cd 400

# ⑩ 表现：头盔位置闪一圈暖光，提示"回照已就绪"
execute at @s run particle minecraft:dust{color:[1.0,0.85,0.45],scale:1.4} ~ ~1.5 ~ 0.35 0.3 0.35 0.02 14 normal
execute at @s run particle minecraft:end_rod ~ ~1.6 ~ 0.2 0.2 0.2 0.02 4 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.8
