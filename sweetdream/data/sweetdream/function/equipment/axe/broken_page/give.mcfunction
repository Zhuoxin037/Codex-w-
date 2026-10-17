# ============================================================
# sweetdream:equipment/axe/broken_page/give —— 给一件「断页」（稀有 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "broken_page" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["broken_page"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】iron_axe（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ============================================================
give @s iron_axe[item_name={text:"断页",bold:true,color:gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对准星前方 5 格内的一个生物造成","color":"gray","italic":false},{"text":"12 点固定伤害。若其附有「白昼梦」，则","color":"gray","italic":false},{"text":"消耗「白昼梦」，且本次伤害改为 30 点","color":"gray","italic":false},{"text":"固定真实伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["broken_page","axe","itemreplace"],skill:"sweetdream:broken_page",tags:["dream","flat","true_dmg","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
