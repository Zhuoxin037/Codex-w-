# ============================================================
# sweetdream:equipment/bow/cold_crow/hit_at —— 探针探到了生物: 结算(宏 {uuid,tier,dmg,u0..u3})
# ------------------------------------------------------------
# 【执行者】射手(玩家)
# 【做什么】把"被探到的那只"填进宏参数 target, 再交给 fire 按层数结算
#   —— fire 里所有位置计算都是 execute at <target>, 所以范围/冰冻/伤害全部落在
#      **被射中的那只**身上(这正是要的效果)。
# ============================================================

data modify storage zx:work cc.target set value "@e[tag=zx.cc_touch,limit=1]"
# 这条是**备用路线**(射击瞬间沿准星探), 根本没经过附魔回调, 所以没有"箭"可认。
# 给一个匹配不到的选择器, snap_prep 会跳过它、退回用射手名下那一份。字段必须存在,
# 否则宏函数会因为"变量没提供"整支不跑。
data modify storage zx:work cc.arrow set value "@e[tag=zx.cc_arr,limit=1]"
function sweetdream:equipment/bow/cold_crow/snap_prep with storage zx:work cc
function sweetdream:equipment/bow/cold_crow/fire with storage zx:work cc
