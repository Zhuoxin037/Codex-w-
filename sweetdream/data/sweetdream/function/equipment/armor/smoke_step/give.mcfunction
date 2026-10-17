# ============================================================
# sweetdream:equipment/armor/smoke_step/give —— 给一件「烟履」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "smoke_step" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["smoke_step"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】iron_boots（稀有 = iron）
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
give @s iron_boots[item_name={text:"烟履",bold:true,color:gray},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +40。普通近战命中了原","color":"gray","italic":false},{"text":"本附有「流火」的生物后，为自身恢复 10","color":"gray","italic":false},{"text":"点魔力值，并获得 2 秒迅捷Ⅰ。该效果 3","color":"gray","italic":false},{"text":"秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 燧帽","color":"gray","italic":false},{"text":"● 烟履","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身对附有「流火」的生物造成的基础攻","color":"gray","italic":false},{"text":"击力类技能伤害提高 12%（独立乘区）。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["smoke_step","boots","armor"],tags:["liuhuo","max_mana","base_atk","buff","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]}]
