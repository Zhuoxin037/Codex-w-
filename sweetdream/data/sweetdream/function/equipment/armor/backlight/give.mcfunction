# ============================================================
# sweetdream:equipment/armor/backlight/give —— 给一件「返照」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "backlight" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["backlight"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 回照
# 【底材】diamond_helmet（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ★ 盔甲同样不挂 item_model / equippable（外观未做）；底材自带原版
#   equippable，穿戴与护甲值照常。visual/armor_icon_held 的补绑名单是**按
#   id 枚举**的，本件不在名单里 => 不会被自动写上不存在的模型。
# ============================================================
give @s diamond_helmet[item_name={text:"返照",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +160。普通近战命中了附","color":"gray","italic":false},{"text":"有「夜火」且仍存活的生物后，若自身未","color":"gray","italic":false},{"text":"持有「回照」，则消耗其「夜火」，为自","color":"gray","italic":false},{"text":"身获得持续 5 秒的「回照」。该效果 20","color":"gray","italic":false},{"text":"秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 回照","color":"gold","bold":true,"italic":false},{"text":"自身下一次主动技能成功施放后，返还该","color":"gray","italic":false},{"text":"次实际消耗魔力的 25%，并使该技能冷却","color":"gray","italic":false},{"text":"时间 -8 秒，之后清除「回照」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["backlight","helmet","armor"],tags:["yehuo","max_mana","cur_mana","cd_down","consume"]},tooltip_display={hidden_components:["unbreakable"]}]
