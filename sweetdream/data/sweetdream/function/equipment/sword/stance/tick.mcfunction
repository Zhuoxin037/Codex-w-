# ============================================================
# sweetdream:equipment/sword/stance/tick —— 3 秒窗口到期检测 + 结算（叶子函数）
# ------------------------------------------------------------
# 【谁调用它】core/tick 每刻（需主对话加一行）：
#   execute as @a[scores={zx.stc_on=1}] at @s run function sweetdream:equipment/sword/stance/tick
# 【执行者】玩家   【频率】每刻（到期刻精确到刻，放每秒会拖到 3~4 秒）
# 【为什么每刻】窗口是绝对到期刻 zx.stc_until；每刻比较 #now 才能准时收
# 【结算】记录值 ×50%（mul_permille #mp_mul=500）→ 整点 double → burst 投给 3 格内生物
# ============================================================

execute unless score @s zx.stc_on matches 1 run return 0
execute if score @s zx.stc_until > #now manacore.meta run return 0

# 记录值 ×0.5（×1000 单位 → ×1000 单位）
scoreboard players operation #mp_src zx.meta = @s zx.stc_sum
scoreboard players set #mp_mul zx.meta 500
function sweetdream:lib/math/mul_permille

# 冻结整点伤害数值
execute store result storage zx:work stc.dmg double 0.001 run scoreboard players get #mp_out zx.meta

# 有伤害才投一次给自身 3 格内全部生物
execute if score #mp_out zx.meta matches 1.. run function sweetdream:equipment/sword/stance/burst

# 复位窗口
scoreboard players set @s zx.stc_on 0
scoreboard players set @s zx.stc_sum 0
