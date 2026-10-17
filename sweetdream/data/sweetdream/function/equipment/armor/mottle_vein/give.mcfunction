# ============================================================
# sweetdream:equipment/armor/mottle_vein/give —— 给一件「杂纹」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "mottle_vein" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["mottle_vein"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】diamond_leggings（史诗 = diamond）
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
give @s diamond_leggings[item_name={text:"杂纹",bold:true,color:dark_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +150。从自身第一次成功","color":"gray","italic":false},{"text":"消费状态标签开始，记录接下来 8 秒内消","color":"gray","italic":false},{"text":"费过的不同种类：流火、夜火、噬心、渊","color":"gray","italic":false},{"text":"海、白昼梦。同一种类只计一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"累计消耗 3 种后，清空记录，立即恢复","color":"gray","italic":false},{"text":"20 点魔力值，并获得 3 秒迅捷Ⅱ和抗性","color":"gray","italic":false},{"text":"提升Ⅰ；若消耗了「流火」则额外恢复 30","color":"gray","italic":false},{"text":"点魔力值；若消耗了「夜火」则下一次技","color":"gray","italic":false},{"text":"能伤害 +20%；若消耗了「噬心」则自身恢","color":"gray","italic":false},{"text":"复 15% 最大生命值；若消耗了「渊海」则","color":"gray","italic":false},{"text":"使自身 3 格内的全部生物击退 1 格；若","color":"gray","italic":false},{"text":"消耗了「白昼梦」则使自身下一次攻击到","color":"gray","italic":false},{"text":"的生物时停 1 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["mottle_vein","leggings","armor"],tags:["liuhuo","yehuo","shixin","yuanhai","dream","max_hp","max_mana","debuff","heal","buff","consume","indep_mul","timestop","dash"]},tooltip_display={hidden_components:["unbreakable"]}]
