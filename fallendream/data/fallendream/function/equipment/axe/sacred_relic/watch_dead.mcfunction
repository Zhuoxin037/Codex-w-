# @s = 观察 marker。宏 victim 是标准 UUID, 直接 UUID 查询不会加 @e 的存活过滤。
# 此处只清理, 不猜测谁击杀; 生成由真正的击杀进度 / 直接致死回调负责。
scoreboard players remove @s zx.sr_wt 1
execute if score @s zx.sr_wt matches ..0 run return run kill @s
$execute unless entity $(victim) run return run kill @s
$tp @s $(victim)
scoreboard players set #sr_done zx.meta 0
$execute as $(victim) if entity @s[tag=zx.sr_done] run scoreboard players set #sr_done zx.meta 1
execute if score #sr_done zx.meta matches 1 run kill @s
