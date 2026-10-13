# ============================================================
# sweetdream:equipment/sword/grayscale/give —— 给一件「灰度」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "grayscale" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["grayscale"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【主动】30 / 18 秒 -> 自身 2 格内 当前魔力 ×0.08 + 燃烧 3 秒; 已在燃烧 -> 改附加「流火」。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:grayscale" + items/*.json + models/ + 贴图。
# ============================================================
give @s iron_sword[item_name={text:"灰度",bold:true,color:gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"30","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"18 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后使自身 2 格内的生物受到一次相当","color":"gray","italic":false},{"text":"于自身当前魔力值 ×0.08 的伤害，之后使","color":"gray","italic":false},{"text":"其燃烧 3 秒。若已经处于燃烧状态则改为","color":"gray","italic":false},{"text":"使其附加「流火」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["grayscale","sword","itemreplace"],skill:"sweetdream:grayscale",tags:["liuhuo","cur_mana","debuff","apply"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
