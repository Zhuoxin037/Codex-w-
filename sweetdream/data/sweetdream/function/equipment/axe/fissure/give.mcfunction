# ============================================================
# sweetdream:equipment/axe/fissure/give —— 给一件「崩裂」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "fissure" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["fissure"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值要和 cast 对上】魔力 150 / 冷却 40 秒 / 前方 5 格 ×5 倍, 落点裂缝 5 秒,
#   裂缝内每秒一次 1 倍基础攻击力。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_axe[item_model="sweetdream:fissure_axe",item_name={text:"崩裂",bold:true,color:gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"150","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"立即对自身前方 5 格的生物造成一次相当","color":"gray","italic":false},{"text":"于自身基础攻击力 ×5 的伤害并形成一个","color":"gray","italic":false},{"text":"持续 5 秒的裂缝。之后在裂缝处的生物将","color":"gray","italic":false},{"text":"每秒受到一次相当于释放者基础攻击力的","color":"gray","italic":false},{"text":"伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["fissure","axe","itemreplace"],skill:"sweetdream:fissure",tags:["base_atk"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
