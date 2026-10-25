# ============================================================
# sweetdream:equipment/axe/deep_brine/field_tick —— 「领域」每秒一跳(执行者 = 领域 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: 三维度各一行 as @e[tag=zx.db_field,distance=0..] at @s run ...
# 【每秒干什么】
#   ① 备好投递参数(dmg / type / 施法者 UUID)
#   ② 把半径 zx.db_r 读进 storage, 交给宏函数 field_hit(伤害 + 拉扯都带半径)
#   ③ 表现  ④ 计时 -1, 归零走 field_end(超限领域在那一下"超大力"地拉一次再收)
# 【★ 为什么拆出 field_hit ★】选择器里的 distance 只认字面量, 而半径现在会变
#   (普通 3 / 超限 5 / 合并后 8·11·14) ⇒ 必须用宏把数字拼进字符串。
#   拆出来的量很小(每秒一次), 不是热路径。
# 【★ 半径记住在计分项 zx.db_r ★】marker 的 NBT 每刻不写, 保持"不标脏"。
# ============================================================

# ① 伤害值 -> num_str
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain

# ② 伤害类型(可被 zx:config 覆盖)
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type

# ③ 归属: 施法者 UUID 四个整数
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]

# ④ 半径 -> storage(宏参数)
scoreboard players add @s zx.db_r 0
execute store result storage zx:work dbr.r int 1 run scoreboard players get @s zx.db_r

# ⑤ 伤害 + 朝中心拉一段(都在宏里, 因为要拼 distance)
function sweetdream:equipment/axe/deep_brine/field_hit with storage zx:work dbr

# ⑥ 表现: 一圈向内收拢的海水(合并过的领域画得更大)
execute if score @s zx.db_r matches ..7 run particle minecraft:bubble ~ ~0.3 ~ 2.6 0.4 2.6 0.0 16 normal
execute if score @s zx.db_r matches ..7 run particle minecraft:splash ~ ~0.1 ~ 2.2 0.2 2.2 0.02 10 normal
execute if score @s zx.db_r matches 8.. run particle minecraft:bubble ~ ~0.3 ~ 6.0 0.5 6.0 0.0 30 normal
execute if score @s zx.db_r matches 8.. run particle minecraft:splash ~ ~0.1 ~ 5.5 0.3 5.5 0.02 20 normal
playsound minecraft:entity.player.swim player @a ~ ~ ~ 0.35 0.9

# ⑦ 计时 -1; 归零走结束段(超限领域会先做一次超大力拉动)
scoreboard players remove @s zx.db_ft 1
execute if score @s zx.db_ft matches ..0 run function sweetdream:equipment/axe/deep_brine/field_end
