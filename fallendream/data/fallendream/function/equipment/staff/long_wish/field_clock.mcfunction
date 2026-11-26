# @s = 长愿领域 marker, 挂 core/tick 三维度。标签转移是被动(走 on_consume hook),
# 这里只管 16 秒到期收掉领域。
execute if score @s zx.lw_end <= #now manacore.meta run return run function fallendream:equipment/staff/long_wish/field_end
particle minecraft:enchant ~ ~0.2 ~ 4 0.1 4 0.01 4 normal
