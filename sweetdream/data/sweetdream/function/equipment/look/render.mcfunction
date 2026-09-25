# ============================================================
# sweetdream:equipment/look/render —— 刷新数值面板(以玩家身份执行)
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick 对带 test_look_on 标签的玩家每刻调用一次
# 【为什么要拆两层】后面的数据路径都按 UUID 索引, 而宏变量只能通过
#   "with storage" 传进去。所以这一层先取 UUID, 再把参数交给宏函数。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:equipment/look/render_go with storage zx:work a
