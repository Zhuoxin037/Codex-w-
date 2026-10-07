# ============================================================
# sweetdream:equipment/bow/rainbow/expire_hit —— 漫彩 5 秒内结束: 范围伤害
# ------------------------------------------------------------
# 【谁调它】expire ①(执行者 = 带漫彩的那只生物)
# 【文案】对其 2 格内的生物造成 其最大生命值 ×0.2 的伤害。
# 【"其最大生命值"用谁的】"其" = 被打中的那只 = 执行者自己(@s)。
#   非玩家生物没有 manacore 面板, 直接读原版 attribute max_health。
# 【范围怎么圈】以自己为中心 2 格(判定箱相交)。
# 【伤害归属】用自己身上的 zx.rb_u0..u3 反查施加者。
# ============================================================

# ① 自己最大生命值 ×0.2(读 ×100 定点 -> ×0.2 即 /5)
scoreboard players set #rb_mh zx.meta 0
execute store result score #rb_mh zx.meta run attribute @s minecraft:max_health get 100
scoreboard players set #5 zx.meta 5
scoreboard players operation #rb_mh zx.meta /= #5 zx.meta
execute if score #rb_mh zx.meta matches ..0 run return 0

# ② 圈范围: 2 格内
tag @e[tag=zx.rb_aoe] remove zx.rb_aoe
execute at @s positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.rb_aoe

# ③ 打伤害(带施加者归属)
data modify storage zx:work a set value {target:"@e[tag=zx.rb_aoe]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #rb_mh zx.meta
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s zx.rb_u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s zx.rb_u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s zx.rb_u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s zx.rb_u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现
#   【★ entity_effect 必须带 color ★】1.21.5 起它的选项是 {color:[r,g,b,a]} 四个 0~1 的浮点,
#   不写就整条命令解析失败(踩过一次)。这里给的是亮粉紫。
execute at @s run particle minecraft:flash ~ ~1 ~ 0.0 0.0 0.0 0.0 1 normal
execute at @s run particle minecraft:entity_effect{color:[1.0,0.4,1.0,1.0]} ~ ~1 ~ 1.5 0.8 1.5 1.0 40 normal
execute at @s run playsound minecraft:block.amethyst_cluster.break player @a ~ ~ ~ 1.0 1.2

# ⑤ 收尾
tag @e[tag=zx.rb_aoe] remove zx.rb_aoe
