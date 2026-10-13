# ============================================================
# sweetdream:lib/dmg_add_put_any —— 往"加算池"里加一份"不挑口径"的百分比
# ------------------------------------------------------------
# 【宏参数】无(读 zx:work put.pct, 和 lib/dmg_add_put 的出参口径一致)
# 【和 lib/dmg_add_put 的区别】
#   dmg_add_put  : 调用方**指定**写哪条通道("挑口径"用: 漫步只写 mm、炽天使只写 atk)
#   dmg_add_put_any: 文案不挑通道(愿景升级 / 共振 / 桂冠), 由本函数**写满三条通道**
# 【★★ D01 口径 B(2026-10-11 用户定): 为什么改回"三条各写一份"★★】
#   伤害侧已经是**分量级**(lib/dmg_add_apply): 伤害 = Σ seg_i×(1+add_i) + seg_x。
#   文案是"本次技能伤害 +X%" —— 要让**整段** +X%, 就必须让每一条用到的段都 +X%:
#       Σ_i seg_i×(1+X) = (Σ_i seg_i)×(1+X) = 整段 ×(1+X)      ✔ 正是文案语义
#   所以这里对三条通道各写一份 X(不再读 zx:work ch 挑"第一条")。
#   ★ 写"没被用到的通道"是**安全**的: 那段 seg_i = 0, 乘不乘都一样 ⇒ 直接写满三条最简。
# 【★ 这不是把 F14 改回去 ★】
#   F14 的毛病是"**汇总式**加算下三条相加 ⇒ 重复计入 ×(1+2X)"(旧 apply 把 Σadd 乘整段)。
#   现在是**分段式**: 三条各乘各的段, 恰好正确 —— 同一个 X 不会落到同一段上两次。
# 【★ 附带收益: 面板更准 ★】
#   upgrade/api/dmg_held(愿景)也走本函数, 而**面板侧**没有"本次技能"、pop 出来若读
#   ch 快照会读的是**残留值**; 现在不再依赖快照 ⇒ 面板三条通道都能如实反映这份加成。
# 【量纲】调用方先写好 zx:work put.pct(整数百分点, 10 = +10%)。
# ============================================================

# --- 最大魔力值通道 ---
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put

# --- 基础攻击力通道 ---
data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put

# --- 其他通道(当前魔力结算那类) ---
data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put
