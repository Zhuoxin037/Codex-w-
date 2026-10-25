# ============================================================
# sweetdream:overlimit/item/five_curses —— 给一块「超限·五世恶咒」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_five_curses :
#   进度 advancement/overlimit/five_curses 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[80.0f]}(八芒星, 编号 80)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「五世恶咒」能敲(见 overlimit/api/fit: 副手 zx 必须含 five_curses 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/five_curses -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·五世恶咒",bold:true,color:light_purple},custom_model_data={floats:[80.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"五世恶咒","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后五世恶咒更名为「超限·五世恶咒」，","color":"gray","italic":false},{"text":"普攻变为：伤害 自身当前魔力值 ×0.03。","color":"gray","italic":false},{"text":"「世咒」变为：每次普攻命中都会推进一","color":"gray","italic":false},{"text":"世「世咒」；在第五世再命中即结算终世。","color":"gray","italic":false},{"text":"第一世：虚弱Ⅲ，持续 5 秒。  第二世：","color":"gray","italic":false},{"text":"缓慢Ⅳ，持续 5 秒。  第三世：受到的技","color":"gray","italic":false},{"text":"能伤害提高 20%，持续 8 秒。 第四世：","color":"gray","italic":false},{"text":"护甲及护甲韧性降低 80%，持续 8 秒。第","color":"gray","italic":false},{"text":"五世：记录目标在接下来最多 12 秒内受","color":"gray","italic":false},{"text":"到的全部伤害。 终世：对其造成记录伤害","color":"gray","italic":false},{"text":"的 40% 真实伤害，之后清除「世咒」。主","color":"gray","italic":false},{"text":"动技能变为：对自身 12 格内所有至少拥","color":"gray","italic":false},{"text":"有一层「世咒」的生物立即推进至下一世","color":"gray","italic":false},{"text":"并强化下一世的效果。第二世改为缓慢Ⅴ，","color":"gray","italic":false},{"text":"持续 5 秒；第三世改为受到的技能伤害提","color":"gray","italic":false},{"text":"高 40%，持续 8 秒；第四世改为护甲及护","color":"gray","italic":false},{"text":"甲韧性清零，持续 8 秒，第五世改为记录","color":"gray","italic":false},{"text":"目标在接下来最多 15 秒受到的全部伤害。","color":"gray","italic":false},{"text":"已处于第五世的目标不会推进，而是立即","color":"gray","italic":false},{"text":"结算终世，并使此次结算比例由 40% 提高","color":"gray","italic":false},{"text":"至 100%。若因此击杀一个生物，则返还","color":"gray","italic":false},{"text":"60 魔力。","color":"gray","italic":false}],custom_data={zx:["ol_five_curses"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
