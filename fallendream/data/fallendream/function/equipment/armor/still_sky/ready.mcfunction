# ============================================================
# fallendream:equipment/armor/still_sky/ready —— 满额够时长: 得一层「星帷」
# ------------------------------------------------------------
# 【执行者】玩家
# 【基础】单层: zx.s2_sky_end = 现在 + 240 刻(12 秒)
# 【超限】三层: 往 zx.s2_sky1/2/3 里第一个空位写 现在 + 320 刻(16 秒)
# ============================================================
scoreboard players set @s zx.s2_sky_full 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["still_sky"],ol:"still_sky"}] run return run function fallendream:equipment/armor/still_sky/layer_add
scoreboard players operation @s zx.s2_sky_end = #now manacore.meta
scoreboard players add @s zx.s2_sky_end 240
particle minecraft:enchant ~ ~1 ~ .4 .3 .4 0 12 normal
