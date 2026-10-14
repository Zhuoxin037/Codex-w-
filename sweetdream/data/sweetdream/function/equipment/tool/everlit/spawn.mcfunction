# ============================================================
# sweetdream:equipment/tool/everlit/spawn —— 召一只「灯灵」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work el {uu, u0, u1, u2, u3}
# 【执行者】持「长明」的玩家; 位置 = 自己(second 里用 at @s 送进来)
# 【为什么用 marker】它不产碰撞、不能被打、不会挡路, 也不在可伤害名单里;
#   自带 data 复合正好拿来存主人 uuid。
# 【攻击倒计时 2 秒】由 wisp_tick 每秒 -1(驱动方计时, 坑 120); 这里只赋初值。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.el_wisp","zx.el_new"],data:{zx:{el:{uu:"$(uu)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}

execute as @e[tag=zx.el_new,distance=..2,limit=1] run scoreboard players set @s zx.el_cd 2
execute as @e[type=minecraft:marker,tag=zx.el_new,distance=0..,limit=1] at @s run function sweetdream:equipment/tool/everlit/visual/tick
execute as @e[type=minecraft:marker,tag=zx.el_new,scores={zx.el_mana=200..},distance=0..,limit=1] on vehicle at @s run particle minecraft:small_flame ~ ~ ~ 0.08 0.09 0.06 0.005 2 normal
execute as @e[type=minecraft:marker,tag=zx.el_new,scores={zx.el_mana=200..},distance=0..,limit=1] on vehicle at @s run playsound minecraft:block.candle.light player @a ~ ~ ~ 0.35 1.7
tag @e[tag=zx.el_new,distance=..2] remove zx.el_new
