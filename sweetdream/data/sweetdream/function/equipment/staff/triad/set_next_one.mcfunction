# ============================================================
# sweetdream:equipment/staff/triad/set_next_one —— 埋"下次攻击额外 2 次"(宏)
# ------------------------------------------------------------
# 【宏参数】entity @s data {u0..u3} —— 法球上带着的施法者 UUID
# 【为什么必须走宏】状态位 zx.tri_next 记在**玩家**身上, 而调用方是法球;
#   只能用 UUID 四段拼出选择器反查玩家(全包同款写法, 见 internal/damage/deal)。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players set @s zx.tri_next 1
