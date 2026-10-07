# ============================================================
# sweetdream:equipment/sword/rogue_star/give —— 给一件「游星」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "rogue_star" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["rogue_star"]}(部分匹配 + 独有标记)
# 【数值要和 cast 对上】魔力 200 / 冷却 30 秒 / 锁定 3 个 / 半径 10 / 延迟 3 秒 /
#   爆炸半径 2 / 倍率 基础攻击力 ×4 / 保底 12。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s diamond_sword[item_name={text:"游星",bold:true,color:white},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"锁定自身 10 格范围内的 3 个生物，3 秒","color":"gray","italic":false},{"text":"后对其 2 格内的全部生物造成相当于自身","color":"gray","italic":false},{"text":"基础攻击力 ×4 的伤害。（保底 12 点伤","color":"gray","italic":false},{"text":"害）","color":"gray","italic":false}],unbreakable={},custom_data={zx:["rogue_star","sword","itemreplace"],skill:"sweetdream:rogue_star"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
