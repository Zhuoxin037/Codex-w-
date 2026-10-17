# ============================================================
# sweetdream:equipment/armor/rain_trace/give —— 给一件「雨迹」（罕见 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "rain_trace" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["rain_trace"]}(部分匹配 + 独有标记)
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
give @s iron_boots[item_name={text:"雨迹",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +50。自身主动技能完成","color":"gray","italic":false},{"text":"实际位移后，在位移过的地方留下持续 5","color":"gray","italic":false},{"text":"秒的水迹。之后对在水迹处持续停留 2 秒","color":"gray","italic":false},{"text":"的生物附加「渊海」，并使其受到一次相","color":"gray","italic":false},{"text":"当于释放者基础攻击力 ×2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["rain_trace","boots","armor"],tags:["yuanhai","max_mana","base_atk","dash","apply"]},tooltip_display={hidden_components:["unbreakable"]}]
