# ============================================================
# sweetdream:equipment/staff/fate_thread/ol_pre_end —— 命缕超限：第一组 12 秒到期的处理
# ------------------------------------------------------------
# 【谁调用】watch ②（zx.ft_end 过期且 zx.ft_tg1 还没立）
# 【执行者】施法者
# 【做什么】① 第一组绷紧一次（10 × 连接数 固定真伤 + 附噬心）
#           ② 摘掉第一组的相连者，主目标留着继续（它是第二组触发的锚点）
#           ③ 立 zx.ft_tg1 —— 不然每刻都会进来重新绷一遍
# 【★ 基础版直接收工 ★】只有超限才会走到这里（zx.ft_end 过期时基础版会先被
#   watch ② 的"两组都到期"那句收场）。这里再判一次 zx.ft2_end 兜底。
# ============================================================

execute unless score @s zx.ft2_end matches 1.. run return 0

function sweetdream:equipment/staff/fate_thread/ol_tighten

# 摘第一组：先清它们的连接数，再把"还在第二组的"统一改回 1 条（见 ol_drop1 头注）
scoreboard players operation #ft_iid zx.meta = @s zx.ft_mine
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta run scoreboard players set @s zx.ft_cn 0
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta run tag @s remove zx.ft_lk
execute as @e[tag=zx.ft_lk2] if score @s zx.ft2n = #ft_iid zx.meta run scoreboard players set @s zx.ft_cn 1

scoreboard players set @s zx.ft_tg1 1
tellraw @s [{"text":"第一组丝线绷紧（12 秒）—— 第二组还在延续","color":"light_purple"}]
