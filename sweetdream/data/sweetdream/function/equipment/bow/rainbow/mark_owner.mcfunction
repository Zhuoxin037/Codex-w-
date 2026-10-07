# ============================================================
# sweetdream:equipment/bow/rainbow/mark_owner —— 把施加者 UUID 记进生物计分项(宏 {u0,u1,u2,u3})
# ------------------------------------------------------------
# 【宏参数】zx:work rbu {u0,u1,u2,u3}
# 【执行者】被打中的那只生物
# 【为什么写计分项】生物的 NBT data 可能被别的包占用; 计分项是干净的。4 个 int
#   拼不出选择器, 但结算伤害时用它们反查玩家(internal/damage/deal 那套)。
# ============================================================

$scoreboard players set @s zx.rb_u0 $(u0)
$scoreboard players set @s zx.rb_u1 $(u1)
$scoreboard players set @s zx.rb_u2 $(u2)
$scoreboard players set @s zx.rb_u3 $(u3)
