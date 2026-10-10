# ============================================================
# sweetdream:equipment/axe/pyre/give —— 给一件「葬火」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "pyre" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["pyre"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【魔力量纲特殊】消耗的是"100%"(放空前魔力), X = 本次消耗的魔力总量。
#   落下: 2 格内 X 点 + 燃烧 X×0.05 秒; 2 秒后 5 格内 X×0.5 点。
# 【X 是变量】实装时把"放掉的魔力"记下来当代入值, 别烘死。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_axe[item_model="sweetdream:pyre",item_name={text:"葬火",bold:true,color:dark_red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"100%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"240 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后下一次攻击额外对自身 2 格内的全","color":"gray","italic":false},{"text":"部生物造成 X 点伤害并使其燃烧 X×0.05","color":"gray","italic":false},{"text":"秒。2 秒后再对自身 5 格范围内的全部生","color":"gray","italic":false},{"text":"物造成 X×0.5 点伤害。X 为使用技能所消","color":"gray","italic":false},{"text":"耗的魔力。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["pyre","axe","itemreplace"],skill:"sweetdream:pyre",tags:["cur_mana","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
