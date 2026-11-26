# 附伤和持续伤害会重新计算无伤害间隔，但不触发「静息」。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.head *[minecraft:custom_data~{zx:["empty_pillow"]}] run scoreboard players operation @s zx.ep_hit = #now manacore.meta
