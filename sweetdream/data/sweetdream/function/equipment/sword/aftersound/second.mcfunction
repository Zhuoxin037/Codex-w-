# ============================================================
# sweetdream:equipment/sword/aftersound/second —— 余响：5 秒判第二阵 / 12 秒窗口收尾
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a at @s run ...
# 【执行者】玩家
# 【时间线】
#   施放当刻  zx.as_t2   = now + 100（5 秒）
#   now≥t2    → second_form（术阵未满就再召唤一个），并把 as_win=1、as_end=now+240
#   now≥as_end→ close（关窗口）
# ============================================================

# 【门】@a 广播调用：既不拿余响、也不在余响的 12 秒窗口里 → 直接跳过。
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aftersound"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aftersound"]}] unless score @s zx.as_on matches 1 run return 0
execute unless score @s zx.as_on matches 1 run return 0

execute if score @s zx.as_win matches 0 if score @s zx.as_t2 <= #now manacore.meta run function sweetdream:equipment/sword/aftersound/second_form
execute if score @s zx.as_win matches 1 if score @s zx.as_end <= #now manacore.meta run function sweetdream:equipment/sword/aftersound/close
