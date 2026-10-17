# ============================================================
# sweetdream:equipment/armor/cross_dream/give —— 给一件「渡梦」（罕见 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "cross_dream" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["cross_dream"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】iron_boots（罕见 = iron）
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
give @s iron_boots[item_name={text:"渡梦",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120。受到附有","color":"gray","italic":false},{"text":"「白昼梦」的生物造成的近战伤害后，若","color":"gray","italic":false},{"text":"其仍存活且在自身 3 格内，则消耗其","color":"gray","italic":false},{"text":"「白昼梦」，使自身沿视线反方向水平后","color":"gray","italic":false},{"text":"撤最多 1.5 格，并获得 2 秒迅捷Ⅰ。遇","color":"gray","italic":false},{"text":"到障碍即停，该效果 10 秒内不可再次触","color":"gray","italic":false},{"text":"发。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["cross_dream","boots","armor"],tags:["dream","max_mana","dash","buff","consume"]},tooltip_display={hidden_components:["unbreakable"]}]
