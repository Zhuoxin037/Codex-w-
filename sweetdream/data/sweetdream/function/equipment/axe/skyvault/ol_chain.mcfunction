# ============================================================
# sweetdream:equipment/axe/skyvault/ol_chain —— 超限·天穹: 消耗 ≥10 层「升痕」后的连锁
# ------------------------------------------------------------
# 【谁调用它】skyvault/impact 的 ⑪(第一段结算完 + #sv_tot ≥ 10 + 超限)
# 【执行者】玩家(刚落地)
# 【文案】"若此次俯冲至少消耗 10 层「升痕」，则自身再次跃升 6 格并在 0.5 秒后
#   向自身准星位置俯冲，并在落地后对半径 5 格内的生物造成一次相当于自身当前
#   魔力值 ×0.1 的伤害并使受到伤害的生物获得一层「升痕」。"
# 【★ 自动俯冲怎么实现 ★】第二次跃升**不给** zx.sv_air(那是"等玩家再按一次"的
#   窗口)。跃升结束时 rise_end 看到 zx.sv_cn = 1, 直接调 dive_ready —— 0.5 秒
#   跃升走完就地俯冲, 玩家不用再按右键。
# 【★ 6 格怎么来 ★】rise_step 看到 sv_cn = 1 时每刻抬 0.6 格(核心 tick 固定 10 刻),
#   0.6 × 10 = 6 格。超限第一段是 0.8 × 10 = 8 格。
# ============================================================

scoreboard players set @s zx.sv_cn 1
tag @s remove zx.sv_air
tag @s remove zx.sv_dive
tag @s add zx.sv_rising
scoreboard players set @s zx.sv_rise 1
# 自身给一段缓降: 否则刚跃起来就往下掉, 那 6 格根本攒不够
effect give @s minecraft:slow_falling 5 0 true

execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.9 0.6 0.9 0.06 26 normal
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.9 0.4 0.9 0.03 18 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.7 1.4
execute at @s run playsound minecraft:item.trident.riptide_3 player @a ~ ~ ~ 0.9 1.1
tellraw @s [{"text":"天穹·升痕共鸣: 已消耗 10 层以上, 再次跃升(0.5 秒后自动俯冲)","color":"aqua"}]
