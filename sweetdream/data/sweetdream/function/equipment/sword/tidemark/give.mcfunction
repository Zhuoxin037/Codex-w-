# ============================================================
# sweetdream:equipment/sword/tidemark/give —— 给一件「潮痕」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "tidemark" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["tidemark"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【主动】30 / 20 秒 -> 前方 4×2 范围 最大魔力 ×0.08, 之后随机一个受击者附加「渊海」。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:tidemark" + items/*.json + models/ + 贴图。
# ============================================================
give @s iron_sword[item_name={text:"潮痕",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"30","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对自身前方 4×2 范围内的生物造成","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.08 的伤害，","color":"gray","italic":false},{"text":"之后使受到伤害的随机一个生物附加","color":"gray","italic":false},{"text":"「渊海」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tidemark","sword","itemreplace"],skill:"sweetdream:tidemark",tags:["yuanhai","max_mana","apply"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
