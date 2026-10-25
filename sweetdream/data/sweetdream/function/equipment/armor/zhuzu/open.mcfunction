# ============================================================
# sweetdream:equipment/armor/zhuzu/open —— 展开驻足领域
# ------------------------------------------------------------
# 【执行者】玩家
# 【产物】脚下 1 个 marker：Tags=[zx.zz_field]、zx.zz_ft=10（秒）、zx.zz_own=玩家UUID[0]
#         marker 的 data.zx.u[0..3] 存完整 UUID，用来给伤害补"攻击者归属"
# 【归属为什么存在 marker 上而不是玩家身上】领域在 10 秒里要独立结算每秒伤害，
#   期间玩家可能离开/退出；伤害的 by 必须能独立取到。
# ============================================================
scoreboard players set @s zx.zz_on 1
scoreboard players set @s zx.zz_w 0
scoreboard players set @s zx.zz_t 0
scoreboard players operation @s zx.zz_cd = #now manacore.meta
scoreboard players add @s zx.zz_cd 600

scoreboard players set #zz_me zx.meta 0
execute store result score #zz_me zx.meta run data get entity @s UUID[0]
# 玩家这边也留一份归属（field_end 到期时靠它反查"这是谁的领域"）
scoreboard players operation @s zx.zz_me = #zz_me zx.meta

data modify storage zx:work zz set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work zz.u0 set from entity @s UUID[0]
data modify storage zx:work zz.u1 set from entity @s UUID[1]
data modify storage zx:work zz.u2 set from entity @s UUID[2]
data modify storage zx:work zz.u3 set from entity @s UUID[3]
execute at @s run function sweetdream:equipment/armor/zhuzu/open_summon with storage zx:work zz

execute at @s run particle minecraft:dust{color:[0.62,0.72,0.55],scale:1.4} ~ ~0.15 ~ 2.2 0.1 2.2 0.01 40 normal
execute at @s run particle minecraft:end_rod ~ ~0.2 ~ 1.6 0.1 1.6 0.02 20 normal
execute at @s run playsound minecraft:block.stone.place player @a ~ ~ ~ 0.9 0.6
execute at @s run playsound minecraft:block.respawn_anchor.charge player @a ~ ~ ~ 0.6 1.2
