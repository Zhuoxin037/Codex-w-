# 宏 {u0..u3}; @s = 本包 /damage 刚打死的准确目标。
# 只检查该次伤害归属的玩家是否持有圣骸; 不取最近玩家, 不改 zx:work a/ob。
# ★ 2026-10-20: 归属反查从 @a[nbt={UUID:[…]}] 改成计分项（同 internal/damage/who）。
#   原本这里是一次全量玩家 NBT 序列化 ≈ 10 ms; 每次击杀都会走到, 属于高频路径。
#   ★ 这里**故意不走 internal/damage/who**: 那个函数读的是 zx:work who,
#     而本函数只被许读 ob、不许碰它。宏参数 $(u0).. 在调用时已固化,
#     直接当字面量写进计分项最省事, 也不产生任何跨函数契约。
scoreboard players set #sr_held zx.meta 0
$scoreboard players set #dby_0 zx.meta $(u0)
$scoreboard players set #dby_1 zx.meta $(u1)
$scoreboard players set #dby_2 zx.meta $(u2)
$scoreboard players set #dby_3 zx.meta $(u3)
tag @a[tag=zx.d_by] remove zx.d_by
execute as @a if score @s manacore.u0 = #dby_0 zx.meta if score @s manacore.u1 = #dby_1 zx.meta if score @s manacore.u2 = #dby_2 zx.meta if score @s manacore.u3 = #dby_3 zx.meta run tag @s add zx.d_by
execute as @a[tag=zx.d_by,limit=1] run function sweetdream:equipment/axe/sacred_relic/held
execute unless score #sr_held zx.meta matches 1 run return 0
execute if data entity @s {Health:0.0f} at @s run return run function sweetdream:equipment/axe/sacred_relic/relic_spawn
execute at @s run function sweetdream:equipment/axe/sacred_relic/observe
