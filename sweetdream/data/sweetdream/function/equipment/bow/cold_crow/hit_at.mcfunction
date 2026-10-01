# ============================================================
# sweetdream:equipment/bow/cold_crow/hit_at —— 探针探到了生物: 结算(宏 {uuid,tier,dmg,u0..u3})
# ------------------------------------------------------------
# 【执行者】射手(玩家)
# 【做什么】把"被探到的那只"填进宏参数 target, 再交给 fire 按层数结算
#   —— fire 里所有位置计算都是 execute at <target>, 所以范围/冰冻/伤害全部落在
#      **被射中的那只**身上(这正是要的效果)。
# ============================================================

data modify storage zx:work cc.target set value "@e[tag=zx.cc_touch,limit=1]"
function sweetdream:equipment/bow/cold_crow/fire with storage zx:work cc
