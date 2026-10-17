# ============================================================
# sweetdream:equipment/staff/late_court/lt_seen —— 记下"这只在本领域里带过缓慢"
# ------------------------------------------------------------
# 【谁调用它】late_court/field_tick ③, 执行者 = 那只生物, #ltc_iid = 本次领域实例号
# 【干什么】给它打标签 zx.ltc_slow 并把实例号写进 zx.ltc_fid。
#   下一秒 field_tick 就是靠这两样判"它是不是在本领域里刚把缓慢走完"。
# 【幂等】重复跑只是重复写同样的值, 没有副作用。
# ============================================================

scoreboard players operation @s zx.ltc_fid = #ltc_iid zx.meta
tag @s add zx.ltc_slow
