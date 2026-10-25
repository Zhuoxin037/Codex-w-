# ============================================================
# sweetdream:equipment/staff/fate_thread/line_mark —— 给一只生物留下 5 秒血丝
# ------------------------------------------------------------
# 【谁调用它】ball_hit ④(逐只)   【执行者】**被命中的生物**
# 【记法】zx.ft_ln = 有血丝(标签); zx.ft_ln_end = 到期绝对刻(5 秒 = 100 刻)。
#   判定一律 `if entity @s[tag=zx.ft_ln] if score @s zx.ft_ln_end > #now`。
#   重复命中 = 刷新到期刻, 不叠加。
# ============================================================

# 【时长分档（批 K8）】基础 5 秒 = 100 刻 / 超限 10 秒 = 200 刻。
#   判据 #ft_olx 由 ball_hit 从法球快照拍下来（命中时玩家可能已换手，不能现读主手）。
tag @s add zx.ft_ln
scoreboard players operation @s zx.ft_ln_end = #now manacore.meta
scoreboard players add @s zx.ft_ln_end 100
execute if score #ft_olx zx.meta matches 1 run scoreboard players add @s zx.ft_ln_end 100
particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.0} ~ ~1 ~ 0.2 0.2 0.2 0.01 4 normal
