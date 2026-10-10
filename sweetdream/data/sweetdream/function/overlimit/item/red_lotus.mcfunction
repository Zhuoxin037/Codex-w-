# ============================================================
# sweetdream:overlimit/item/red_lotus —— 给一块「超限·红莲」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_red_lotus :
#   进度 advancement/overlimit/red_lotus 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[39.0f]}(八芒星, 编号 39)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「红莲」能敲(见 overlimit/api/fit: 副手 zx 必须含 红莲 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·红莲",bold:true,color:light_purple},custom_model_data={floats:[39.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"红莲","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后红莲更名为「超限·红莲」，主动技","color":"gray","italic":false},{"text":"能变为：使用后消耗自身 5 格内全部生物","color":"gray","italic":false},{"text":"的「流火」或「夜火」效果。每消耗一层","color":"gray","italic":false},{"text":"「流火」则对自身 6 格内全部生物造成一","color":"gray","italic":false},{"text":"次相当于自身基础攻击力 ×1.5 的伤害并","color":"gray","italic":false},{"text":"使其燃烧 2 秒，每消耗一层「夜火」则对","color":"gray","italic":false},{"text":"自身 6 格内全部生物造成两次相当于自身","color":"gray","italic":false},{"text":"基础攻击力 ×4 的伤害并使其燃烧 5 秒。","color":"gray","italic":false},{"text":"若本次共消耗了 6 层及以上「流火」及","color":"gray","italic":false},{"text":"「夜火」，则使自身 5 格内的敌人每秒都","color":"gray","italic":false},{"text":"会获得「流火」效果，持续 5 秒。","color":"gray","italic":false}],custom_data={zx:["ol_red_lotus"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
