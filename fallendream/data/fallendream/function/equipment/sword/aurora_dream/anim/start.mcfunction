# 只由成功施法入口调用；技能数值、目标与钟声保持原逻辑。
scoreboard players set @s zx.ad_cast 0
scoreboard players set @s zx.ad_idle 0
scoreboard players set @s zx.ad_wait 0
scoreboard players set @s zx.ad_pulse 0
tag @s add zx.ad_cast
