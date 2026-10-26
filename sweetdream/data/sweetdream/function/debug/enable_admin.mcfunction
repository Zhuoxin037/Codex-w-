# ============================================================
# sweetdream:debug/enable_admin —— 重新打开"管理类" /trigger(C01)
# ------------------------------------------------------------
# 【执行者】玩家本人(由 debug/second 按权限挑选后 as 过来)。
# 【什么时候会被调到】
#   ① #dev zx.meta = 1(开发构建)  → 对**所有在线玩家**调一次;
#   ② #dev zx.meta = 0(发布构建)  → 只对带 zx.admin 标签的玩家调一次。
#   两种情形都只在这一个文件里维护启用清单, 免得两处走样。
# 【区分"管理类"与"只读类"的标准】
#   管理类 = 会**改动世界/背包/数值**(发物、回魔、清冷却、术阵 ±1) —— 就是这里的 5 条;
#   只读类 = 只给玩家看信息(stats/worn/raw/diff/menu) —— 直接在 debug/second 里 enable @a。
# 【★ 加了新的管理类入口, 只改这里一行 ★】
# ============================================================

scoreboard players enable @s zx.dbg_cd
scoreboard players enable @s zx.dbg_mana
scoreboard players enable @s zx.dbg_fadd
scoreboard players enable @s zx.dbg_fdel
scoreboard players enable @s zx.dbg_give

scoreboard players enable @s zx.dbg_dummy

scoreboard players enable @s zx.dbg_liuhuo

scoreboard players enable @s zx.dbg_yehuo

scoreboard players enable @s zx.dbg_shixin

scoreboard players enable @s zx.dbg_yuanhai

scoreboard players enable @s zx.dbg_dream
