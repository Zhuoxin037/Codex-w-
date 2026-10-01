# ============================================================
# sweetdream:equipment/sword/liaoyuan/end —— 18 秒到, 光环收工(以玩家身份)
# ------------------------------------------------------------
# 【为什么把两个计分项都清掉】留着的话下次施法前会读到旧值;
#   清掉之后 second 的筛选条件(ly_aura >= 1)就不再包含这个人了, 开销归零。
# ============================================================

scoreboard players reset @s zx.ly_aura
scoreboard players reset @s zx.ly_timer
scoreboard players reset @s zx.ly_times
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.8 1.0
