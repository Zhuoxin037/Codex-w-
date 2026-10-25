tag @s add zx.bb_own
# 先携带至中心附近，保留来自哪一侧，再做落点爆发与向外击退。
$execute as @e[tag=zx.bb_path_$(uuid),distance=..64] at @s facing entity @a[tag=zx.bb_own,limit=1] feet rotated ~ 0 positioned as @a[tag=zx.bb_own,limit=1] positioned ^ ^ ^-0.1 run tp @s ~ ~ ~
execute at @s run function sweetdream:equipment/staff/burst_bank/land_dmg with storage zx:work bb
effect give @s minecraft:speed 2 1 true

# ★ 超限：激活水流地带（12 秒 = 240 刻，批 K8）★
#   【为什么在这里算到期】突进途中撒的点只是"痕迹"，从落地这一刻才开始计时 ——
#     文案是"之后在突进经过的位置留下水流…水流持续 12 秒"，起点就是落地。
execute if data storage zx:work bb{ol:1} run scoreboard players operation @s zx.bb_wt = #now manacore.meta
execute if data storage zx:work bb{ol:1} run scoreboard players add @s zx.bb_wt 240
playsound minecraft:entity.ravager.attack player @a ~ ~ ~ 0.9 1.1
particle minecraft:cloud ~ ~0.2 ~ 1.2 0.1 1.2 0.02 20 normal
tag @s remove zx.bb_own
$tag @e[tag=zx.bb_path_$(uuid)] remove zx.bb_path_$(uuid)
$kill @e[type=marker,tag=zx.bb_ctrl_$(uuid)]
