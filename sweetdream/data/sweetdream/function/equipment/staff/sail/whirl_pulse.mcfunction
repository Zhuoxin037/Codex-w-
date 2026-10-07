# ============================================================
# sweetdream:equipment/staff/sail/whirl_pulse —— 旋风每 3 秒的一次脉冲
# ------------------------------------------------------------
# 【谁调用它】whirl_tick 第 ① 步; 【执行者/位置】旋风 marker
# 【技能原文(lore 逐字)】旋风每 3 秒都会吸引一次其 5 格内的生物并使其附加被自身
#   记录的生物的随机一种属性。
# 【"吸引"】照 iridescent/eff_3 的 tp 式位移, 但方向相反(朝中心走 1 格)。
# 【"随机一种属性"】从 marker 上存的属性码列表 data.zx.sl.m 里等概率取一个(见 mark_pick)。
#   列表为空(记录的生物当时没有那四种标记)则这一拍只吸引、不附加。
# ============================================================

# ① 吸引 5 格内全部生物(朝中心挪 1 格)
tag @e[tag=zx.sl_center,distance=0..] remove zx.sl_center
tag @s add zx.sl_center
tag @e[tag=zx.sl_area,distance=0..] remove zx.sl_area
tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.sl_area
execute as @e[tag=zx.sl_area,distance=0..] at @s facing entity @e[tag=zx.sl_center,distance=0..,limit=1] feet positioned ^ ^ ^1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @e[tag=zx.sl_center,distance=0..] remove zx.sl_center

# ② 附加"随机一种被记录的属性"(列表为空就跳过)
execute store result score #sl_n zx.meta run data get entity @s data.zx.sl.n
execute if score #sl_n zx.meta matches 1.. run function sweetdream:equipment/staff/sail/mark_pick

# ③ 重置脉冲计时 + 表现: 半径 5 的一圈 dust(把"吸引 5 格"的范围画出来,
#   颜色 = 本拍刚附着的那种属性; 见 whirl_col / whirl_pulse_fx)
scoreboard players set @s zx.sl_p 3
function sweetdream:equipment/staff/sail/whirl_pulse_fx
playsound minecraft:entity.breeze.idle_ground player @a ~ ~ ~ 0.6 1.4
