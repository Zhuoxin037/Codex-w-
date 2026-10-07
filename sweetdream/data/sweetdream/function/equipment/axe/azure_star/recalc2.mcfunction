# ============================================================
# sweetdream:equipment/axe/azure_star/recalc2 —— 段②: 算 最大魔力值 ×0.1
# ------------------------------------------------------------
# 【谁调用它】azure_star/dmg2(每 0.35 秒后的第 2 段)
# 【执行者】施法者(玩家)
# 【★ 段② 也要吃"被动翻倍" ★】文案是"提升 1 倍**该武器**伤害倍率", 整把武器两段都算
#   —— 所以看玩家身上的存根 zx.as_db(段① 写下的), 而不是已经清零的 zx.as_x2。
# 【★ 为什么不在 recalc 里把 dmg2 一起算好 ★】两段隔 0.35 秒, 中间那份值要跨刻留在
#   zx:work asz 上 —— 会被别的施法者/技能覆盖(共享节点)。所以每段各自当场算。
# ============================================================

# 段2: 最大魔力值 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
# 本武器这次技能的伤害倍率翻倍 -> 段② 同样 ×2
execute if score @s zx.as_db matches 1.. run function sweetdream:equipment/axe/azure_star/double
function manacore:api/damage/calc
data modify storage zx:work asz.dmg2 set from storage manacore:out r.damage
