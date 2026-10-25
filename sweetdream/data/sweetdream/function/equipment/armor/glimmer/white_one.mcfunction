# ============================================================
# sweetdream:equipment/armor/glimmer/white_one —— 白：对单只生物附加「白昼梦」+ 时停 1 秒
# ------------------------------------------------------------
# 【执行者】@s = 目标生物（at @s）
# 【★ 走公共入口 ★】状态一律 lib/tag/mark, 时停一律 lib/timestop —— 不自己写
#   `tag add` / `NoAI`, 否则图标、租约、解除流程都会漏。
# ============================================================

# ① 附加「白昼梦」（会刷新 15 秒 TTL, 并带上攻击力 -20% 的通用效果）
data modify storage zx:work gl_t set value {target:"@s", mark:"dream"}
function sweetdream:tag/mark with storage zx:work gl_t

# ② 时停 1 秒 = 20 刻
data modify storage zx:work fz set value {target:"@s", ticks:20}
function sweetdream:lib/timestop with storage zx:work fz
