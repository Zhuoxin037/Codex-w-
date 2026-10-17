# ============================================================
# sweetdream:equipment/axe/deep_brine/dom_one —— 消耗一只的「渊海」并在其处开一个领域
# ------------------------------------------------------------
# 【谁调用它】cast ⑨(逐个)   【执行者】施法者   【位置】他所在处
# 【目标】zx.db_cur = 本轮被选中的那一个带「渊海」的命中者(场上最多一个)
# 【★ 身份不能换 ★】
#   消耗走统一入口 lib/mark_consume; 余烬只认 **@s**(消耗者), 而 by 默认也是 @s。
#   所以这里**绝不能** `as <目标>` —— 一旦换成生物, 余烬就认错了人。
#   目标只能写成**选择器字符串**塞进 zx:work a.target(与陈渊 mark_yuanhai 同一路子)。
# 【★ 只有真的摘掉才生成领域 ★】
#   · ok   = 它身上真有这个标签(防"选完到消耗之间被别的效果摘掉") -> 没有就收工。
#   · done = 穿「永恒」时把标签**补回来**了 = 不算消耗 -> 不生成领域。
#   两个字段都由 lib/mark_consume/mark_take 写, 见那两个文件。
# 【领域生成位置】就是**它所在处** —— field_one 用 ~ ~ ~, 所以这里用 `at` 搬位置。
# ============================================================

# ① 消耗它的「渊海」(执行者/身份仍是施法者本人)
data modify storage zx:work a set value {target:"@e[tag=zx.db_cur,distance=0..,limit=1]",mark:"yuanhai"}
function sweetdream:lib/mark_consume

# ② 它身上本来就没有 -> 收工
execute unless data storage zx:work mc{ok:1b} run return 0
# ③ 被「永恒」补回来了 = 没真的消耗 -> 不生成领域
execute if data storage zx:work mc{done:1b} run return 0

# ④ 在它所在处生成一个半径 3 / 持续 4 秒的领域(伤害与归属已由 cast ⑦ 备好)
execute at @e[tag=zx.db_cur,distance=0..,limit=1] run function sweetdream:equipment/axe/deep_brine/field_one with storage zx:work dbf
