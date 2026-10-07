# ============================================================
# sweetdream:equipment/staff/begonia/vortex_tick —— 漩涡的每秒心跳
# ------------------------------------------------------------
# 【谁调用它】begonia/second(执行者 = 漩涡 marker, at @s 位置在中心)
# 【技能原文(lore 逐字)】漩涡每秒都会将 4 格内的全部生物拉回中心一段距离，持续 8 秒。
# 【"拉回中心"怎么实现】照 iridescent/eff_3 的 tp 式位移, 但方向相反(朝向中心走 1 格)。
#   中心 = @s(漩涡 marker); 目标 = 4 格内全部可伤害生物。目标格不是可替换方块就不动。
# ============================================================

# ① 中心 = 本漩涡
tag @e[tag=zx.bg_center,distance=0..] remove zx.bg_center
tag @s add zx.bg_center

# ② 圈 4 格内全部生物 -> 朝中心挪 1 格
tag @e[tag=zx.bg_pull,distance=0..] remove zx.bg_pull
tag @e[type=!#sweetdream:no_damage,distance=..4] add zx.bg_pull
execute as @e[tag=zx.bg_pull,distance=0..] at @s facing entity @e[tag=zx.bg_center,distance=0..,limit=1] feet positioned ^ ^ ^1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @e[tag=zx.bg_pull,distance=0..] remove zx.bg_pull
tag @e[tag=zx.bg_center,distance=0..] remove zx.bg_center

# ③ 表现(漩涡转水)
particle minecraft:bubble ~ ~0.5 ~ 2.0 0.5 2.0 0.0 14 normal
particle minecraft:nautilus ~ ~0.5 ~ 1.0 0.4 1.0 0.05 6 normal
playsound minecraft:entity.player.swim player @a ~ ~ ~ 0.5 1.5

# ④ 倒计时; 到 0 收尾(伤害 + 清「渊海」)
scoreboard players remove @s zx.bg_t 1
execute if score @s zx.bg_t matches ..0 run function sweetdream:equipment/staff/begonia/vortex_end
