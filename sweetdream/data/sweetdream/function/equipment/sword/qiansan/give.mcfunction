# ============================================================
# sweetdream:equipment/sword/qiansan/give —— 给一件「千散」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "qiansan" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["qiansan"]}(部分匹配 + 独有标记)
# 【衍生物】由「万念」使用后切换而来, 也可以直接 give 出来测。
#   通道和万念相反: 万念吃当前魔力, 千散吃基础攻击力。
# 【数值要和 cast 对上】魔力 80 / 冷却 20 秒。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_sword[item_name={text:"千散",bold:true,color:dark_red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后切换为「万念」并对自身 3 格内的","color":"gray","italic":false},{"text":"全部生物造成一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"×2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["qiansan","sword","itemreplace"],skill:"sweetdream:qiansan"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
