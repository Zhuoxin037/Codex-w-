# 只接真实 shot_crossbow 事件；即使魔力不足，原版已射出的实体仍然存在。
scoreboard players set @s zx.bv_t 0
scoreboard players set @s zx.bv_seek 3
execute at @s anchored eyes positioned ^-0.32 ^-0.22 ^1.35 rotated ~180 ~ run function sweetdream:equipment/bow/burst_dawn/visual/muzzle
