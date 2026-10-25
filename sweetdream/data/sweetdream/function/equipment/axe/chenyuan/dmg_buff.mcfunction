# ============================================================
# sweetdream:equipment/axe/chenyuan/dmg_buff —— 有增益: 最大魔力 ×0.08
# ------------------------------------------------------------
# 【执行者】施法者   【目标】zx.cy_hit
# 【通道】max_mana_mul(基数 = 面板最大魔力) -> 顺带吃「最大魔力值技能倍率」通用加成
#   ★ 2026-10-07 起"风声 / 忘川彼岸 / 无效"的加成走 lib/mm_add/hook_calc
#     (挂 damage_calc 事件, 往加算池 mm 通道写一份百分比), 不再是一次性消耗品 ——
#     所以这里不需要自己调一行, 加成也不会被这一下"吃掉"。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
# 超限: 0.08 -> 0.1(只在这条"有增益"分支里改 —— 文案的超限幅度就写在这一支上)
execute if data storage zx:work cy{ol:1} run data modify storage manacore:in arg.max_mana_mul set value 0.1
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.cy_hit]",read:"manacore"}
function sweetdream:api/damage
