# ============================================================
# sweetdream:equipment/armor/step_load —— 把本玩家这个槽位的记录读进 zx:step cur
# ------------------------------------------------------------
# 【宏参数】zx:step ctx {u0,u1,u2,u3}
# 【输出】zx:step cur = {skill,uuid,x,y,z}；没有记录时整个 cur 被清掉
# 【为什么先清 cur】`set from` 在源不存在时会**失败并保留旧值**，
#   不清就会拿到上一个人的技能 id —— 那会把冷却减到别人身上（静默错）。
# ============================================================

data remove storage zx:step cur
$data modify storage zx:step cur set from storage zx:step casts."$(u0)_$(u1)_$(u2)_$(u3)"
