# ============================================================
# sweetdream:overlimit/item/sickle_dreams —— 给一块「超限·引梦镰」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_sickle_dreams :
#   进度 advancement/overlimit/sickle_dreams 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[37.0f]}(八芒星, 编号 37)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「引梦镰」能敲(见 overlimit/api/fit: 副手 zx 必须含 sickle_dreams 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·引梦镰",bold:true,color:light_purple},custom_model_data={floats:[37.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"引梦镰","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后引梦镰更名为「超限·引梦镰」，主","color":"gray","italic":false},{"text":"动技能变为：使用后立即对自身前方 2×3","color":"gray","italic":false},{"text":"范围内的生物造成一次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.05 的伤害并附加「噬心」。若对","color":"gray","italic":false},{"text":"有「噬心」的生物造成伤害则本次伤害强","color":"gray","italic":false},{"text":"化为对自身前方 3×5 范围内的生物造成相","color":"gray","italic":false},{"text":"当于自身最大魔力值 ×0.25 的伤害并时停","color":"gray","italic":false},{"text":"2 秒，之后移除「噬心」。","color":"gray","italic":false}],custom_data={zx:["ol_sickle_dreams"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
