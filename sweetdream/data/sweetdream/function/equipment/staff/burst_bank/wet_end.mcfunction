# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_end —— 决堤超限：水流到期收工
# ------------------------------------------------------------
# 【宏参数】zx:work bbw（uuid）
# 【执行者】施法者本人
# 【★ 三个数一起清 ★】zx.bb_wt（到期）/ zx.bb_wd（每秒伤害）不清，下一秒还会进来；
#   点不清，世界里会一直躺着 marker（看不见但永久占用实体槽）。
# ============================================================
$kill @e[type=marker,tag=zx.bb_wet_$(uuid)]
scoreboard players set @s zx.bb_wt 0
scoreboard players set @s zx.bb_wd 0
