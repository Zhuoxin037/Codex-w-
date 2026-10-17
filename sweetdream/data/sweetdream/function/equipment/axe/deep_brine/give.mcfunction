# ============================================================
# sweetdream:equipment/axe/deep_brine/give —— 给一件「重溟」（史诗 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "deep_brine" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["deep_brine"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 主动技能
# 【底材】diamond_axe（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ============================================================
give @s diamond_axe[item_name={text:"重溟",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次普通攻击命中了附有「渊海」的生物","color":"gray","italic":false},{"text":"后，额外造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.05 的伤害，并使其获得 2 秒缓慢Ⅲ。","color":"gray","italic":false},{"text":"该效果对同一个生物 10 秒内最多触发一","color":"gray","italic":false},{"text":"次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"280","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"45 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后重击自身前方 5×4 格范围内的全部","color":"gray","italic":false},{"text":"生物，造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.1 的伤害。若命中了附有「渊海」的生","color":"gray","italic":false},{"text":"物，则消耗其中最多 2 个生物的「渊海」。","color":"gray","italic":false},{"text":"每消耗一个则在其位置生成一个半径 3 格、","color":"gray","italic":false},{"text":"持续 4 秒的领域。领域内的生物每秒受到","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.03 的伤害，","color":"gray","italic":false},{"text":"且持续被拉向中心。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["deep_brine","axe","itemreplace"],skill:"sweetdream:deep_brine",tags:["yuanhai","max_mana","debuff","slow","consume","attract","field"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
