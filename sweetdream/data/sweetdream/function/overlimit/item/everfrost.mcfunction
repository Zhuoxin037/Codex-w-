# ============================================================
# sweetdream:overlimit/item/everfrost —— 给一块「超限·永霜」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_everfrost :
#   进度 advancement/overlimit/everfrost 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[35.0f]}(八芒星, 编号 35)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「永霜」能敲(见 overlimit/api/fit: 副手 zx 必须含 everfrost 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·永霜",bold:true,color:light_purple},custom_model_data={floats:[35.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"永霜","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后永霜更名为「超限·永霜」，主动技","color":"gray","italic":false},{"text":"能变为：冰冻自身 5 格范围内的全部生物","color":"gray","italic":false},{"text":"3 秒，之后每秒对被冰冻的生物造成一次","color":"gray","italic":false},{"text":"相当于其最大生命值 ×0.03 的真实伤害","color":"gray","italic":false},{"text":"（最多 10 秒），并在结束后对被冰冻的","color":"gray","italic":false},{"text":"生物造成相当于自身当前魔力值 ×0.15 的","color":"gray","italic":false},{"text":"伤害。","color":"gray","italic":false}],custom_data={zx:["ol_everfrost"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
