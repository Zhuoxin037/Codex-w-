# ============================================================
# sweetdream:equipment/staff/gu_poison/give —— 给一件「蛊毒」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "gu_poison" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["gu_poison"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【普攻 + 主动】普攻 80 / 伤害 当前魔力 ×0.04; 命中后给目标「噬心」+ 3 秒缓慢Ⅱ。
#   主动 500 / 120 秒 -> 术阵; 8 格内最多 2 个带「噬心」的每秒吃 最大生命 ×0.1, 之后移除「噬心」, 持续 6 秒。
#   ★ 若目标的「噬心」提前掉了, 该目标本轮也提前失效。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_model="sweetdream:gu_poison",item_name={text:"蛊毒",bold:true,color:green},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身当前魔力 ×0.04","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后都会使其获得「噬心」效","color":"gray","italic":false},{"text":"果和 3 秒的缓慢Ⅱ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"120 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后使自身 8 格内","color":"gray","italic":false},{"text":"的最多 2 个带有「噬心」效果的生物每秒","color":"gray","italic":false},{"text":"受到相当于自身最大生命值 ×0.1 的伤害，","color":"gray","italic":false},{"text":"之后移除「噬心」。持续 6 秒。（若","color":"gray","italic":false},{"text":"「噬心」效果提前结束则技能效果也提前","color":"gray","italic":false},{"text":"失效）","color":"gray","italic":false}],unbreakable={},custom_data={zx:["gu_poison","staff","itemreplace"],skill:"sweetdream:gu_poison",tags:["shixin","max_hp","cur_mana","apply","slow","debuff","consume","formation"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
