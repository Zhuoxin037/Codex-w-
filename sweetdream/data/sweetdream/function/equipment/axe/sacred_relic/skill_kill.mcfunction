# 宏 {u0..u3}; @s = 本包 /damage 刚打死的准确目标。
# 只检查该次伤害归属的玩家是否持有圣骸; 不取最近玩家, 不改 zx:work a/ob。
scoreboard players set #sr_held zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/axe/sacred_relic/held
execute unless score #sr_held zx.meta matches 1 run return 0
execute if data entity @s {Health:0.0f} at @s run return run function sweetdream:equipment/axe/sacred_relic/relic_spawn
execute at @s run function sweetdream:equipment/axe/sacred_relic/observe
