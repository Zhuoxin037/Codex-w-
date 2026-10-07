# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_dmg —— 受击范围真伤结算
# ------------------------------------------------------------
# 【谁调它】hit_extra ③(执行者 = 被标记的生物, 刚挨了打)
# 【伤害】施法者(max_mana)×0.01×X -> 打在该生物 2 格内的所有生物身上。
# 【范围】以自己为圆心 2.5 格的球(distance 选择器, 见 ④)。
# 【归属】用 zx.ld_u0..u3 反查施法者(同 rainbow/consume_dmg 一套)。
# ============================================================

# ① X = 该生物身上的 ld_x(= 触发时的梦回层数)
execute store result score #ld_x zx.meta run scoreboard players get @s zx.ld_x

# ② 反查施法者并读其 max_mana -> #ld_mm
scoreboard players set #ld_mm zx.meta 0
data modify storage zx:work ldsu set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work ldsu.u0 int 1 run scoreboard players get @s zx.ld_u0
execute store result storage zx:work ldsu.u1 int 1 run scoreboard players get @s zx.ld_u1
execute store result storage zx:work ldsu.u2 int 1 run scoreboard players get @s zx.ld_u2
execute store result storage zx:work ldsu.u3 int 1 run scoreboard players get @s zx.ld_u3
function sweetdream:equipment/bow/lucid_dream/hit_extra_find with storage zx:work ldsu

# ③ 伤害 = 最大魔力 ×0.01×X = 最大魔力 × X ÷100
scoreboard players set #ld_ed zx.meta 0
scoreboard players operation #ld_ed zx.meta = #ld_mm zx.meta
scoreboard players operation #ld_ed zx.meta *= #ld_x zx.meta
scoreboard players set #100 zx.meta 100
scoreboard players operation #ld_ed zx.meta /= #100 zx.meta
execute if score #ld_ed zx.meta matches ..0 run return 0

# ④ 打范围真伤(2 格内所有生物)
# 【★ 范围怎么取 ★】以前写的是 `as @e[dx=5,dy=5,dz=5,distance=..2.5]` —— 两个错:
#   ① 没有 `at @s`(dx 方框从"当前执行位置"起算, 而核心 tick 传进来的位置是
#      世界原点) -> 整段打在原点附近的生物身上, 实际一次都打不到;
#   ② dx 方框从自己脚下往 +x/+y/+z 方向长, 就算位置对上也只剩 1/8 个象限。
#   全包惯例是 `at @s positioned ~-r ~-r ~-r ... dx=2r`, 但那会把 distance 的
#   圆心也挪走 —— 所以这里直接用 distance 球, 不叠 dx 方框, 语义就是"2 格内"。
data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:generic",num:"0",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work a.u0 set from storage zx:work ldsu.u0
data modify storage zx:work a.u1 set from storage zx:work ldsu.u1
data modify storage zx:work a.u2 set from storage zx:work ldsu.u2
data modify storage zx:work a.u3 set from storage zx:work ldsu.u3
execute store result storage zx:work a.damage double 1 run scoreboard players get #ld_ed zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute at @s as @e[distance=..2.5,type=!#sweetdream:no_damage] run function sweetdream:equipment/bow/lucid_dream/hit_extra_hit with storage zx:work a

# 表现
particle minecraft:soul_fire_flame ~ ~1 ~ 1.0 0.8 1.0 0.05 15 normal
