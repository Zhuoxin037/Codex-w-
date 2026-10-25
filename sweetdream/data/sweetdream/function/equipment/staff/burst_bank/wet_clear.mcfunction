# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_clear —— 决堤超限：重放前清掉上一次的水流
# ------------------------------------------------------------
# 【谁调用】skill 进门（拿完 uuid 之后）—— 同一把杖 25 秒冷却，理论上上一次早该到期，
#   但"提前结束 / 中途退回"这类路径会留下孤儿 marker，所以进门先无条件清一遍。
# 【宏参数】zx:work owner_arg（zx:data self 的整份拷贝，含 uuid 字符串）
# ============================================================
$kill @e[type=marker,tag=zx.bb_wet_$(uuid)]
scoreboard players set @s zx.bb_wt 0
scoreboard players set @s zx.bb_wd 0
