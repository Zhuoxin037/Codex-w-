# ============================================================
# sweetdream:equipment/sword/everfrost/give —— 给一件「永霜」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "everfrost" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["everfrost"]}(部分匹配 + 独有标记)
# 【数值要和 cast 对上】魔力 200 / 冷却 30 秒 / 冰冻半径 5 / 最多 8 个 / 3 秒 /
#   结束伤害 ×0.1（吃**当前剩余魔力值**, 不是上限）。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s diamond_sword[item_name={text:"永霜",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"冰冻自身 5 格范围内的 8 个生物 3 秒，","color":"gray","italic":false},{"text":"并在结束后对被冰冻的生物造成相当于自","color":"gray","italic":false},{"text":"身当前剩余魔力值 ×0.1 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["everfrost","sword","itemreplace"],skill:"sweetdream:everfrost"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
