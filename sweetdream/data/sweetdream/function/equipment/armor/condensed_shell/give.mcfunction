# ============================================================
# sweetdream:equipment/armor/condensed_shell/give —— 给一件「凝壳」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "condensed_shell" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["condensed_shell"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 领域
# 【底材】diamond_chestplate（史诗 = diamond）
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
give @s diamond_chestplate[item_name={text:"凝壳",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +160。受到伤害后，若魔","color":"gray","italic":false},{"text":"力足够且术阵位有空缺，则消耗 80 魔力","color":"gray","italic":false},{"text":"并占用 1 个术阵位，在自身位置生成半径","color":"gray","italic":false},{"text":"3 格、持续 4 秒的领域。该效果 20 秒内","color":"gray","italic":false},{"text":"不可再次触发。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 领域","color":"gold","bold":true,"italic":false},{"text":"生物首次进入本次领域时冰冻 1 秒，每名","color":"gray","italic":false},{"text":"生物整次领域最多触发一次冰冻。领域每","color":"gray","italic":false},{"text":"秒对其中的生物造成一次相当于自身基础","color":"gray","italic":false},{"text":"攻击力 ×4 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["condensed_shell","chestplate","armor"],tags:["max_mana","base_atk","debuff","freeze","field","formation"]},tooltip_display={hidden_components:["unbreakable"]}]
