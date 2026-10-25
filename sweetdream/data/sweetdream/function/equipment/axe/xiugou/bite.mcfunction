# ============================================================
# sweetdream:equipment/axe/xiugou/bite —— 咬 3 格内最近的一个敌人
# ------------------------------------------------------------
# 【执行者】marker（锈犬）
# 【★ 目标怎么选】`sort=nearest,limit=1` 一次只咬一个 —— 不是范围伤害。
#   "3 格内最近的敌人"是设计里的原话，别改成 AOE。
# 【★ 不写实体 NBT】标记目标这一步不需要 tag：直接把 marker 的 dmg/UUID
#   复制进 storage，再 as 目标跑宏。2026-10-20 那条延迟坑就是"每刻给生物加 tag"。
# ============================================================
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..3,sort=nearest,limit=1] run return 0

data modify storage zx:work xg set value {dmg:0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work xg.dmg set from entity @s data.zx.dmg
data modify storage zx:work xg.u0 set from entity @s data.zx.u[0]
data modify storage zx:work xg.u1 set from entity @s data.zx.u[1]
data modify storage zx:work xg.u2 set from entity @s data.zx.u[2]
data modify storage zx:work xg.u3 set from entity @s data.zx.u[3]
execute as @e[type=!#sweetdream:no_damage,distance=0.1..3,sort=nearest,limit=1] at @s run function sweetdream:equipment/axe/xiugou/bite_one with storage zx:work xg

scoreboard players add @s zx.xg_n 1
execute at @s run particle minecraft:crit ~ ~0.25 ~ 0.3 0.2 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.wolf.bite player @a ~ ~ ~ 0.7 1.0
