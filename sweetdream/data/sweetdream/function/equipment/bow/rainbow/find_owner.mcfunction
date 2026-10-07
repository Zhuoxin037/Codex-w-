# ============================================================
# sweetdream:equipment/bow/rainbow/find_owner —— 按 u0..u3 反查施加者, 读他的 max_health(宏 {u0..u3})
# ------------------------------------------------------------
# 【谁调它】consume_dmg ①(执行者不限)
# 【产出】#rb_mhp zx.meta = 施加者 max_health ×100(定点); 查不到人则 0。
# 【怎么做】
#   ① 用 nbt={UUID:[I;u0,u1,u2,u3]} 反查玩家(和 internal/damage/deal 同一套)
#   ② 拿到人后把他设成执行者, lib/uuid 取 uuid 文本, api/stats/get 读 max_health
#   ③ 面板值原量纲(点), ×100 存进 #rb_mhp
# ============================================================

scoreboard players set #rb_mhp zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/bow/rainbow/find_owner_go
