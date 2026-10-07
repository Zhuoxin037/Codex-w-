# ============================================================
# sweetdream:equipment/staff/begonia/second —— 海棠的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】每个"漩涡": vortex_tick(每秒把 4 格内生物拉回中心 + 倒计时 + 表现)
# 【★ 裸 @e 在这里是安全的】event/second 每秒只跑一次(不是"每维度各跑一次"),
#   裸 @e 会跨维度搜索, 每个漩涡恰好被处理一次。
# 【公共输入口】vortex_end 要用 manacore:in arg, 所以整段夹在 in_bak / in_restore 之间。
# ============================================================

function sweetdream:lib/in_bak

execute as @e[tag=zx.bg_vtx] at @s run function sweetdream:equipment/staff/begonia/vortex_tick

function sweetdream:lib/in_restore
