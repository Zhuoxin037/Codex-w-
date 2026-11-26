$execute unless entity $(vx_uuid) run return 0

# ② 它带「噬心」吗? 不带就收工
$execute as $(vx_uuid) unless entity @s[tag=zx.status.shixin] run tag $(vx_uuid) remove zx.victim
$execute unless entity $(vx_uuid) run return 0

# ③ 已经满 3 层 -> 收工(不白扣别人的「噬心」)
scoreboard players add @s zx.bld_n 0
$execute if score @s zx.bld_n matches 3.. run tag $(vx_uuid) remove zx.victim
execute if score @s zx.bld_n matches 3.. run return 0

# ④ 消耗它身上的「噬心」
$data modify storage zx:work a set value {target:"$(vx_uuid)",mark:"shixin",by:"@s",src:"equip"}
function fallendream:lib/mark_consume

# ⑤ 被「永恒」补回来了 -> 不算消耗, 不给层数
$execute if data storage zx:work mc{done:1b} run tag $(vx_uuid) remove zx.victim
execute if data storage zx:work mc{done:1b} run return 0

# ⑥ 积攒 1 层「心血」
scoreboard players add @s zx.bld_n 1

# ⑦ 表现: 心血浮上来一层
execute at @s run particle minecraft:dust{color:[0.6,0.02,0.05],scale:1.2} ~ ~1.2 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.player.breath player @a ~ ~ ~ 0.5 0.7

# ⑧ 收尾
$tag $(vx_uuid) remove zx.victim
