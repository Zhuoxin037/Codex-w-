# ============================================================
# sweetdream:overlimit/item/dusk_dawn —— 给一块「超限·黄昏黎明之交界」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_dusk_dawn :
#   进度 advancement/overlimit/dusk_dawn 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[31.0f]}(八芒星, 编号 31)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「黄昏黎明之交界」能敲(见 overlimit/api/fit: 副手 zx 必须含 dusk_dawn 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·黄昏黎明之交界",bold:true,color:light_purple},custom_model_data={floats:[31.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"黄昏黎明之交界","color":"blue"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后黄昏黎明之交界更名为「超限·黄昏","color":"gray","italic":false},{"text":"黎明之交界」，被动变为：自身魔力值上","color":"gray","italic":false},{"text":"限 +250，魔力值低于上限 80% 时每秒获","color":"gray","italic":false},{"text":"得 3% 魔力值，击杀生物后临时获得 200","color":"gray","italic":false},{"text":"魔力值上限持续 12 秒，若其带有通用效","color":"gray","italic":false},{"text":"果则额外获得 100×X 魔力值上限（X 为该","color":"gray","italic":false},{"text":"生物所有的效果数量）。","color":"gray","italic":false}],custom_data={zx:["ol_dusk_dawn"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
