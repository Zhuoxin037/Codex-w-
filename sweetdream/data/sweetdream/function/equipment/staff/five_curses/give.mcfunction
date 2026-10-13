# ============================================================
# sweetdream:equipment/staff/five_curses/give —— 给一件「五世恶咒」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "five_curses" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["five_curses"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【法杖: 普攻 + 主动】普攻 100, 伤害 自身当前魔力值 ×0.03; 每次命中叠一层「世咒」(第一~五世)。
#   主动 600 / 120 秒 -> 12 格内所有带「世咒」者推进一世; 已在第五世 -> 立即结算终世(比例 30%->80%);
#   因此击杀一个生物返 50 魔力, 每次技能最多返 300。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:five_curses" + items/*.json + models/ + 贴图。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"五世恶咒",bold:true,color:dark_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"100","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身当前魔力值 ×0.03","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 世咒","color":"gold","bold":true,"italic":false},{"text":"每次普攻命中后都会向目标施加一层","color":"gray","italic":false},{"text":"「世咒」。","color":"gray","italic":false},{"text":"● 第一世：虚弱Ⅲ，持续 3 秒。","color":"gray","italic":false},{"text":"● 第二世：缓慢Ⅳ，持续 3 秒。","color":"gray","italic":false},{"text":"● 第三世：受到的技能伤害提高 20%，持","color":"gray","italic":false},{"text":"   续 5 秒。","color":"gray","italic":false},{"text":"● 第四世：护甲及护甲韧性降低 50%，持","color":"gray","italic":false},{"text":"   续 5 秒。","color":"gray","italic":false},{"text":"● 第五世：记录目标在接下来最多 5 秒","color":"gray","italic":false},{"text":"   内受到的全部伤害。","color":"gray","italic":false},{"text":"● 终世：对其造成记录伤害的 30% 真实","color":"gray","italic":false},{"text":"   伤害，之后清除「世咒」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"600","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"120 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"对自身 12 格内所有至少拥有一层","color":"gray","italic":false},{"text":"「世咒」的生物立即推进至下一世。已处","color":"gray","italic":false},{"text":"于第五世的目标不会推进，而是立即结算","color":"gray","italic":false},{"text":"终世，并使此次结算比例由 30% 提高至","color":"gray","italic":false},{"text":"80%。若因此击杀一个生物，则返还 50 魔","color":"gray","italic":false},{"text":"力，每次技能最多返还 300 魔力。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["five_curses","staff","itemreplace"],skill:"sweetdream:five_curses",tags:["cur_mana","true_dmg","slow","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
