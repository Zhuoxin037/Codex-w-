execute at @s run particle minecraft:cloud ~ ~0.3 ~ 0.4 0.3 0.4 0.05 12 normal
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.7 1.2
$execute unless entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/visual/end
$execute at @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/visual/impact
$execute at @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/impact
# 伤害回调可能改写共享self；这里原有宏uuid已经固定，不读回调留下的UUID。
$data remove storage zx:anchor players."$(uuid)".cast
