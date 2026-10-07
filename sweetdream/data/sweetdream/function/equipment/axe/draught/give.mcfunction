# ============================================================
# sweetdream:equipment/axe/draught/give —— 给一件「饮鸩」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "draught" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["draught"]}(部分匹配 + 独有标记)
# 【数值要和 cast 对上】魔力 160 / 冷却 80 秒 / 自伤 = 最大生命 ×0.8 /
#   换来的基础攻击力加成 = 实际受到的自伤值, 持续 10 秒。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_axe[item_name={text:"饮鸩",bold:true,color:dark_red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"160","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对自身造成相当于自身最大生命值","color":"gray","italic":false},{"text":"×0.8 的伤害，之后获得相当于自身受到的","color":"gray","italic":false},{"text":"伤害的基础攻击力加成，持续 10 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["draught","axe","itemreplace"],skill:"sweetdream:draught"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
