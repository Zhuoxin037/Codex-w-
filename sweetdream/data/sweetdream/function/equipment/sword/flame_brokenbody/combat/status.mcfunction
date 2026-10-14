# 命中后的原夜火逻辑：先吸收原有夜火，再转化流火，最后刷新冷却。
# 先记"这次该不该刷冷却": 圈里有「夜火」(基础版就有的条件),
#    超限版再加一条「流火」(超限文案: 攻击到的生物附有「流火」**或**「夜火」)。
#    ★ 为什么单独记: 冷却刷新要覆盖"只有流火、一个夜火都没有"的情况 ——
#      那种情况下 ⑧-1 的 night 根本不会跑, 冷却就漏刷了。
scoreboard players set @s zx.fb_refresh 0
execute if entity @e[tag=zx.fb_hit,tag=zx.status.yehuo,distance=0..] run scoreboard players set @s zx.fb_refresh 1
execute if score @s zx.fb_ol matches 1 if entity @e[tag=zx.fb_hit,tag=zx.status.liuhuo,distance=0..] run scoreboard players set @s zx.fb_refresh 1

# ⑧-1 吸收圈里**原本就有**的「夜火」: 每有一个积 1 点熔浆, 然后把它们消耗掉
tag @e[tag=zx.fb_night] remove zx.fb_night
execute as @e[tag=zx.fb_hit] if entity @s[tag=zx.status.yehuo] run tag @s add zx.fb_night
execute if entity @e[tag=zx.fb_night] run function sweetdream:equipment/sword/flame_brokenbody/night

# ⑧-2 【超限】把圈里剩下的「流火」转成「夜火」—— **只转化, 本次不吸收**
#   ★ 2026-10-08 改(玩家口径): 原来是"转化完立刻一起吸收 + 积熔浆",
#     现在改成只转化。转化出来的这批夜火留着, **下一次**技能才会被吸收。
#     实现上就是把 torchify 从"挑夜火之前"挪到"吸收之后"。
execute if score @s zx.fb_ol matches 1 run function sweetdream:equipment/sword/flame_brokenbody/torchify

function sweetdream:lib/uuid

# ⑧-3 命中带「流火」或「夜火」-> 该技能冷却时间立即结束(统一在这里刷, night 里不再刷)
execute if score @s zx.fb_refresh matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:flame_brokenbody"}
execute if score @s zx.fb_refresh matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.fb_refresh matches 1 run function manacore:api/cooldown/reset
