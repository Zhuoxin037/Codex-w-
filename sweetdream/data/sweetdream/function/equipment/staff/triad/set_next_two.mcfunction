# ============================================================
# sweetdream:equipment/staff/triad/set_next_two —— 埋"下次攻击为空"(宏)
# ------------------------------------------------------------
# 【宏参数】entity @s data {u0..u3} —— 施法者 UUID
# 【与 set_next_one 同构】都是用 UUID 反查玩家、把状态位写回玩家身上。
#   zx.tri_next = 2 ⇒ 下一次普攻伤害归零(见 attack 第 ⑤ 步)。
# ============================================================

$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players set @s zx.tri_next 2
