# ============================================================
# sweetdream:overlimit/item/begonia —— 给一块「超限·海棠」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_begonia :
#   进度 advancement/overlimit/begonia 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[46.0f]}(八芒星, 编号 46)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「海棠」能敲(见 overlimit/api/fit: 副手 zx 必须含 海棠 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·海棠",bold:true,color:light_purple},custom_model_data={floats:[46.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"海棠","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后海棠更名为「超限·海棠」，基础属","color":"gray","italic":false},{"text":"性新加：若有生物在漩涡范围内死亡，则","color":"gray","italic":false},{"text":"对该漩涡进行增强：在漩涡内使用关于最","color":"gray","italic":false},{"text":"大魔力值的技能时造成的伤害提升 20%。","color":"gray","italic":false},{"text":"将漩涡范围扩大为 6 格，且爆炸后会对漩","color":"gray","italic":false},{"text":"涡内全部生物造成相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.25 的伤害并使处于中心的生物附加","color":"gray","italic":false},{"text":"「渊海」，之后该技能冷却时间 -12 秒。","color":"gray","italic":false}],custom_data={zx:["ol_begonia"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
