# 只在每秒兜底一次。逻辑 marker 被 /kill 时清掉无主的显示。
scoreboard players set #el_passenger zx.meta 0
execute on passengers if entity @s[type=minecraft:marker,tag=zx.el_wisp] run scoreboard players set #el_passenger zx.meta 1
execute unless score #el_passenger zx.meta matches 1 run kill @s
