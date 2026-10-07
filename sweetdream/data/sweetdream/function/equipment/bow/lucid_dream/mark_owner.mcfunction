# ============================================================
# sweetdream:equipment/bow/lucid_dream/mark_owner —— 记施法者 UUID(宏 {u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调它】big ⑧(执行者 = 被标记的那只生物)
# 【干什么】把施法者 UUID 写进生物自己的计分项 zx.ld_u0..u3(结算真伤时反查)。
# ============================================================

$scoreboard players set @s zx.ld_u0 $(u0)
$scoreboard players set @s zx.ld_u1 $(u1)
$scoreboard players set @s zx.ld_u2 $(u2)
$scoreboard players set @s zx.ld_u3 $(u3)
