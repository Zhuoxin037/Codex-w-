# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_form_go —— 刷新术阵(执行者 = 施法者)
# ------------------------------------------------------------
# 【谁调它】hit_extra_form_find 反查到的那名玩家
# 【干什么】把「清醒梦」术阵的到期时间改成"现在 + X 秒"(api/formation/refresh
#   的语义是**改写成** now+时长, 不是叠加 —— 这里要的就是这个)。
#   X = #ld_x zx.meta(hit_extra_form 读出来的梦回层数)
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:lucid_dream",duration_seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.duration_seconds double 1 run scoreboard players get #ld_x zx.meta
function manacore:api/formation/refresh
