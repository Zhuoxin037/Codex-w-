# ============================================================
# sweetdream:equipment/sword/blind_candle/give —— 给一件「盲烛」（史诗 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "blind_candle" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["blind_candle"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 主动技能 ｜ ✦ 烛火
# 【底材】diamond_sword（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ============================================================
give @s diamond_sword[item_name={text:"盲烛",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次普通攻击命中了附有「夜火」的生物","color":"gray","italic":false},{"text":"后，对其 2.5 格内随机一个其他生物造成","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.06 的伤害。","color":"gray","italic":false},{"text":"若其也附有「夜火」，则该伤害提高为自","color":"gray","italic":false},{"text":"身最大魔力值 ×0.1。该效果 5 秒内最多","color":"gray","italic":false},{"text":"触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对前方 4×5 格范围内的全部生物造","color":"gray","italic":false},{"text":"成一次相当于自身最大魔力值 ×0.14 的伤","color":"gray","italic":false},{"text":"害。若命中了附有「夜火」的生物，则消","color":"gray","italic":false},{"text":"耗其中最近一个生物的「夜火」，并使自","color":"gray","italic":false},{"text":"身获得「烛火」，持续 8 秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 烛火","color":"gold","bold":true,"italic":false},{"text":"每次普通攻击后对目标 3 格内随机一个其","color":"gray","italic":false},{"text":"他生物造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.08 的伤害。若没有其他生物，则改为","color":"gray","italic":false},{"text":"对被攻击的生物造成一次相当于自身最大","color":"gray","italic":false},{"text":"魔力值 ×0.04 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["blind_candle","sword","itemreplace"],skill:"sweetdream:blind_candle",tags:["yehuo","max_mana","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
