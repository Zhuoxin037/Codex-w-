# ============================================================
# sweetdream:equipment/staff/twilight/give —— 给一件「暮光」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "twilight" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["twilight"]}(部分匹配 + 独有标记)
# 【普攻 + 主动】普攻 50 / 伤害 最大魔力值 ×0.03; 命中后 20% 附加「噬心」, 成功则再补一次伤害。
#   主动 350 / 100 秒 -> 术阵; 12 格内最多 3 个带「噬心」的目标护甲/韧性减半 + 抗性提升失效, 8 秒。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"暮光",bold:true,color:dark_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"50","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身最大魔力值 ×0.03","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后有 20% 的概率使其附加","color":"gray","italic":false},{"text":"「噬心」效果。若成功附加则额外对其造","color":"gray","italic":false},{"text":"成一次伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"350","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"100 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后使自身 12 格","color":"gray","italic":false},{"text":"内最多 3 个带有「噬心」效果的生物的护","color":"gray","italic":false},{"text":"甲值及护甲韧性减半，且其抗性提升效果","color":"gray","italic":false},{"text":"失效。持续 8 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["twilight","staff","itemreplace"],skill:"sweetdream:twilight"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
