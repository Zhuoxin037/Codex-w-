# ============================================================
# sweetdream:equipment/staff/sail/find_rec —— 按记录里的 UUID 找出"被记录的生物"
# ------------------------------------------------------------
# 【宏参数】zx:work slu {u0,u1,u2,u3}   【执行者】施法玩家(位置无所谓)
# 【出参】那只生物被打上 zx.sl_found 标签(找不到就没有)。
# 【★ 先清全场 ★】免得上一次调用留下的标签被当成这一次的目标。
# ============================================================

tag @e[tag=zx.sl_found,distance=0..] remove zx.sl_found
$tag @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] add zx.sl_found
