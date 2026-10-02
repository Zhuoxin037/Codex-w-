# ============================================================
# 效果五: 时停 1 秒 + 附加「白昼梦」
# ------------------------------------------------------------
# 【执行者】被打中的那只生物
# 【时停】走 lib/timestop(NoAI 完全定格), 1 秒 = 20 tick。
#   它和"冷冻"(lib/freeze, 还能转身攻击)是两套, 计时也各走各的, 别混用。
# 【白昼梦】走公共的 sweetdream:tag/mark, mark 填五个英文名之一 "dream"。
#   这个标签是**五状态图标系统**的一员, 图标/显示那边早就认它了, 只是之前
#   没有任何装备去施加; 幻昼的被动和本效果都会用到它。
# 【★ 时停结束时会发生什么 ★】幻昼会接住"时停结束"这一瞬间(见
#   #sweetdream:event/timestop_end), 对 8 格内刚解时停的生物打真实伤害。
#   所以"异彩的效果五"其实是给幻昼铺路的 —— 两件是设计好的一套。
# ============================================================

data modify storage zx:work fz set value {target:"@s",ticks:20}
function sweetdream:lib/timestop with storage zx:work fz

data modify storage zx:work ic set value {target:"@s",mark:"dream"}
function sweetdream:tag/mark with storage zx:work ic
