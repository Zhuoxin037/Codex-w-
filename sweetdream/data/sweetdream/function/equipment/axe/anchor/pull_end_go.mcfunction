# 【★ 2026-10-23 卡顿修复 ★】目标由 "UUID NBT 反查" 改成 标签 zx.an_lock
#   + scores={zx.an_own=$(u0)}(同 pull_tick_go 的注释): 这里的三处反查虽然是一次性
#   的, 但它们和下面 visual/impact -> impact 同刻连跑, 凑起来正好压在"结算那一
#   刻"上 —— 玩家看到的就是"卡一下然后伤害一起出来"。
execute at @s run particle minecraft:cloud ~ ~0.3 ~ 0.4 0.3 0.4 0.05 12 normal
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.7 1.2
$execute unless entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/visual/end
$execute at @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/visual/impact
$execute at @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/impact
# 伤害回调可能改写共享self；这里原有宏uuid已经固定，不读回调留下的UUID。
$data remove storage zx:anchor players."$(uuid)".cast
