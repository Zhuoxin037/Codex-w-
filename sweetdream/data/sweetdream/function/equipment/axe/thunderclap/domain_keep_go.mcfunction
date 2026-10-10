# ============================================================
# sweetdream:equipment/axe/thunderclap/domain_keep_go —— 领域孤儿兜底: 真正判定(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work td {u0,u1,u2,u3} = 本领域所属术阵 marker 的 UUID 四段
# 【执行者】领域 item_display(@s)
# 【规则】自己那座 marker 还在 -> 什么都不做; 不在了 -> 我是孤儿, 自杀。
# 【为什么不看距离】见 domain_kill / domain_keep 的头注释(修 F17):
#   按 marker UUID 精确认亲, 相距多近的两座术阵也不会互相干扰。
# 【正常路径不会走到这里】术阵到点由 field_end -> domain_kill 直接收;
#   这条只兜底"marker 被非正常清掉"(手动 /kill、区块异常等)。
# ============================================================

$execute unless entity @e[type=minecraft:marker,tag=zx.tc_field,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}] run kill @s
