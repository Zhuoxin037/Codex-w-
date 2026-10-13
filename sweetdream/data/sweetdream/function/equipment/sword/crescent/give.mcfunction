# ============================================================
# sweetdream:equipment/sword/crescent/give —— 给一件「缺月」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "crescent" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["crescent"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【被动 + 主动】被动: 主手持有缺月时按快捷栏里"正在冷却的其它主动技能"数量分三档(1 / 2 / ≥3)。
#   主动: 240 / 30 秒 -> 冻结快捷栏全部技能剩余冷却 6 秒, 每冻结 1 秒总剩余冷却 +1% 最终伤害
#   (最高 +150%); 6 秒结束时对 6 格内全部目标 最大魔力 ×0.12 + 基础攻击力 ×4, 之后解冻照常。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:crescent" + items/*.json + models/ + 贴图。
# ============================================================
give @s netherite_sword[item_name={text:"缺月",bold:true,color:white},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"主手持有缺月时，快捷栏中若有正在冷却","color":"gray","italic":false},{"text":"的主动技能（不包括该武器）则触发以下","color":"gray","italic":false},{"text":"效果","color":"gray","italic":false},{"text":"● 只有 1 个技能正在冷却：普通攻击额","color":"gray","italic":false},{"text":"   外造成相当于自身基础攻击力 ×2 的伤","color":"gray","italic":false},{"text":"   害。","color":"gray","italic":false},{"text":"● 有 2 个技能正在冷却：普通攻击在以","color":"gray","italic":false},{"text":"   上基础上再额外造成相当于基础攻击力","color":"gray","italic":false},{"text":"   ×2 的伤害，并使自身所有技能冷却时","color":"gray","italic":false},{"text":"   间 -0.5 秒。","color":"gray","italic":false},{"text":"● 有 3 个及以上技能正在冷却：缺月不","color":"gray","italic":false},{"text":"   再获得上述效果。普通攻击改为造成最","color":"gray","italic":false},{"text":"   大魔力 ×0.08，但每次攻击随机使一个","color":"gray","italic":false},{"text":"   正在冷却的技能剩余冷却 +1 秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"240","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用时，将当前快捷栏内所有技能的剩余","color":"gray","italic":false},{"text":"冷却时间暂时冻结 6 秒。玩家每冻结 1","color":"gray","italic":false},{"text":"秒总剩余冷却时间，本技能最终伤害就提","color":"gray","italic":false},{"text":"高 1%（最高 +150%）。6 秒结束时，对 6","color":"gray","italic":false},{"text":"格内全部目标造成相当于最大魔力 ×0.12+","color":"gray","italic":false},{"text":"基础攻击力 ×4 的伤害，之后被冻结的技","color":"gray","italic":false},{"text":"能继续正常冷却。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["crescent","sword","itemreplace"],skill:"sweetdream:crescent",tags:["base_atk","max_mana","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
